package xyz.adscope.adscope_sdk.manager

import android.content.Context
import android.view.View
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import xyz.adscope.adscope_sdk.data.AD_ID
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSNativeCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.DownLoadCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.ErrorModel.CODE
import xyz.adscope.adscope_sdk.data.ErrorModel.MESSAGE
import xyz.adscope.adscope_sdk.data.NATIVE_TYPE
import xyz.adscope.adscope_sdk.data.NativeType
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.nativead.AMPSNativeAd
import xyz.adscope.amps.ad.nativead.AMPSNativeLoadEventListener
import xyz.adscope.amps.ad.nativead.adapter.AMPSNativeAdExpressListener
import xyz.adscope.amps.ad.nativead.inter.AMPSNativeAdExpressInfo
import xyz.adscope.amps.ad.unified.AMPSUnifiedNativeAd
import xyz.adscope.amps.ad.unified.AMPSUnifiedNativeLoadEventListener
import xyz.adscope.amps.ad.unified.inter.AMPSUnifiedAdEventListener
import xyz.adscope.amps.ad.unified.inter.AMPSUnifiedDownloadListener
import xyz.adscope.amps.ad.unified.inter.AMPSUnifiedNativeItem
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.config.AMPSRequestParameters
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

@Suppress("UNCHECKED_CAST")
class AMPSNativeManager {
    private val nativeAds = ConcurrentHashMap<String, AMPSNativeAd>()
    private val unifiedAds = ConcurrentHashMap<String, AMPSUnifiedNativeAd>()

    // 每个实例对应一个 adItem→adId 映射，保证多实例 destroy 时只清自家的项。
    private val nativeAdIdMapByInstance =
        ConcurrentHashMap<String, MutableMap<AMPSNativeAdExpressInfo, String>>()
    private val unifiedAdIdMapByInstance =
        ConcurrentHashMap<String, MutableMap<AMPSUnifiedNativeItem, String>>()

    companion object {
        @Volatile
        private var instance: AMPSNativeManager? = null

        fun getInstance(): AMPSNativeManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSNativeManager().also { instance = it }
            }
        }
    }

    private fun argsMap(call: MethodCall): Map<String, Any>? =
        call.arguments as? Map<String, Any>

    private fun instanceIdFrom(call: MethodCall): String? =
        argsMap(call)?.get(AD_INSTANCE_ID) as? String

    private fun nativeTypeFrom(call: MethodCall): Int =
        (argsMap(call)?.get(NATIVE_TYPE) as? Int) ?: NativeType.NATIVE.value

    private fun nativeIdMap(instanceId: String): MutableMap<AMPSNativeAdExpressInfo, String> =
        nativeAdIdMapByInstance.getOrPut(instanceId) { mutableMapOf() }

    private fun unifiedIdMap(instanceId: String): MutableMap<AMPSUnifiedNativeItem, String> =
        unifiedAdIdMapByInstance.getOrPut(instanceId) { mutableMapOf() }

    private fun buildNativeCallback(instanceId: String) = object : AMPSNativeLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSNativeAdExpressInfo?>?) {
            val idMap = nativeIdMap(instanceId)
            idMap.clear()
            val adIdList = adItems?.filterNotNull()?.map { item ->
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                idMap[item] = uniqueId
                uniqueId
            } ?: emptyList()
            sendMessage(instanceId, AMPSNativeCallBackChannelMethod.LOAD_OK, mapOf("adIds" to adIdList))
            adItems?.filterNotNull()?.forEach { item ->
                val uniqueId = idMap[item] ?: return@forEach
                item.setAMPSNativeAdExpressListener(object : AMPSNativeAdExpressListener() {
                    override fun onAdShow() {
                        sendMessage(instanceId, AMPSNativeCallBackChannelMethod.ON_AD_SHOW, mapOf(AD_ID to uniqueId))
                    }

                    override fun onAdClicked() {
                        sendMessage(instanceId, AMPSNativeCallBackChannelMethod.ON_AD_CLICKED, mapOf(AD_ID to uniqueId))
                    }

                    override fun onAdClosed(p0: View?) {
                        idMap.remove(item)
                        adDestroy(uniqueId)
                        sendMessage(instanceId, AMPSNativeCallBackChannelMethod.ON_AD_CLOSED, mapOf(AD_ID to uniqueId))
                    }

                    override fun onRenderFail(p0: View?, p1: String?, p2: Int) {
                        sendMessage(
                            instanceId,
                            AMPSNativeCallBackChannelMethod.RENDER_FAILED,
                            mapOf(AD_ID to uniqueId, CODE to p2, MESSAGE to p1)
                        )
                    }

                    override fun onRenderSuccess(p0: View?, p1: Float, p2: Float) {
                        if (p0 != null) {
                            AdWrapperManager.getInstance().addAdItem(uniqueId, item)
                            AdWrapperManager.getInstance().addAdView(uniqueId, p0)
                        }
                        sendMessage(
                            instanceId,
                            AMPSNativeCallBackChannelMethod.RENDER_SUCCESS,
                            mapOf(AD_ID to uniqueId)
                        )
                    }
                })
                item.render()
            }
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                instanceId,
                AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                mapOf(CODE to (error?.code?.toInt() ?: -1), MESSAGE to error?.message)
            )
        }
    }

    private fun buildUnifiedCallback(instanceId: String) = object : AMPSUnifiedNativeLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSUnifiedNativeItem?>?) {
            val idMap = unifiedIdMap(instanceId)
            idMap.clear()
            val adIdList = adItems?.filterNotNull()?.map { item ->
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                idMap[item] = uniqueId
                uniqueId
            } ?: emptyList()
            sendMessage(instanceId, AMPSNativeCallBackChannelMethod.LOAD_OK, mapOf("adIds" to adIdList))
            adItems?.filterNotNull()?.forEach { item ->
                val uniqueId = idMap[item] ?: return@forEach
                setDownLoadListener(instanceId, item, uniqueId)
                item.setNegativeFeedbackListener {
                    sendMessage(
                        instanceId,
                        AMPSNativeCallBackChannelMethod.ON_COMPLAIN_SUCCESS,
                        mapOf(AD_ID to uniqueId)
                    )
                }
                if (item.isExpressAd) {
                    item.setNativeAdExpressListener(object : AMPSNativeAdExpressListener() {
                        override fun onAdShow() {
                            sendMessage(
                                instanceId,
                                AMPSNativeCallBackChannelMethod.ON_AD_SHOW,
                                mapOf(AD_ID to uniqueId)
                            )
                        }

                        override fun onAdClicked() {
                            sendMessage(
                                instanceId,
                                AMPSNativeCallBackChannelMethod.ON_AD_CLICKED,
                                mapOf(AD_ID to uniqueId)
                            )
                        }

                        override fun onAdClosed(p0: View?) {
                            idMap.remove(item)
                            adDestroy(uniqueId)
                            sendMessage(
                                instanceId,
                                AMPSNativeCallBackChannelMethod.ON_AD_CLOSED,
                                mapOf(AD_ID to uniqueId)
                            )
                        }

                        override fun onRenderFail(p0: View?, p1: String?, p2: Int) {
                            sendMessage(
                                instanceId,
                                AMPSNativeCallBackChannelMethod.RENDER_FAILED,
                                mapOf(AD_ID to uniqueId, CODE to p2, MESSAGE to p1)
                            )
                        }

                        override fun onRenderSuccess(p0: View?, p1: Float, p2: Float) {
                            if (p0 != null) {
                                AdWrapperManager.getInstance().addAdView(uniqueId, p0)
                            }
                            sendMessage(
                                instanceId,
                                AMPSNativeCallBackChannelMethod.RENDER_SUCCESS,
                                mapOf(AD_ID to uniqueId)
                            )
                        }
                    })
                    item.render()
                    return@forEach
                }
                setNoExpressAdListener(instanceId, uniqueId, item)
            }
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            sendMessage(
                instanceId,
                AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                mapOf(CODE to (p0?.code?.toInt() ?: -1), MESSAGE to p0?.message)
            )
        }
    }

    private fun setDownLoadListener(
        instanceId: String,
        item: AMPSUnifiedNativeItem,
        uniqueId: String?
    ) {
        item.setDownloadListener(object : AMPSUnifiedDownloadListener {
            override fun onDownloadPaused(position: Int) {
                sendMessage(
                    instanceId,
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_PAUSED,
                    mapOf("position" to position, AD_ID to uniqueId)
                )
            }

            override fun onDownloadStarted() {
                sendMessage(
                    instanceId,
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_STARTED,
                    mapOf(AD_ID to uniqueId)
                )
            }

            override fun onDownloadProgressUpdate(position: Int) {
                sendMessage(
                    instanceId,
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_PROGRESS_UPDATE,
                    mapOf("position" to position, AD_ID to uniqueId)
                )
            }

            override fun onDownloadFinished() {
                sendMessage(
                    instanceId,
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_FINISHED,
                    mapOf(AD_ID to uniqueId)
                )
            }

            override fun onDownloadFailed() {
                sendMessage(
                    instanceId,
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_FAILED,
                    mapOf(AD_ID to uniqueId)
                )
            }

            override fun onInstalled() {
                sendMessage(
                    instanceId,
                    DownLoadCallBackChannelMethod.ON_INSTALLED,
                    mapOf(AD_ID to uniqueId)
                )
            }
        })
    }

    private fun setNoExpressAdListener(
        instanceId: String,
        uniqueId: String?,
        item: AMPSUnifiedNativeItem
    ) {
        if (uniqueId != null) {
            item.setNativeAdEventListener(object : AMPSUnifiedAdEventListener {
                override fun onADExposed() {
                    sendMessage(
                        instanceId,
                        AMPSNativeCallBackChannelMethod.ON_AD_SHOW,
                        mapOf(AD_ID to uniqueId)
                    )
                    sendMessage(
                        instanceId,
                        AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE,
                        mapOf(AD_ID to uniqueId)
                    )
                }

                override fun onADClicked() {
                    sendMessage(
                        instanceId,
                        AMPSNativeCallBackChannelMethod.ON_AD_CLICKED,
                        mapOf(AD_ID to uniqueId)
                    )
                }

                override fun onADExposeError(p0: Int, p1: String?) {
                    sendMessage(
                        instanceId,
                        AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE_FAIL,
                        mapOf(AD_ID to uniqueId, CODE to p0, MESSAGE to p1)
                    )
                }
            })
            AdUnifiedWrapperManager.getInstance().addAdItem(uniqueId, item)
            sendMessage(
                instanceId,
                AMPSNativeCallBackChannelMethod.RENDER_SUCCESS,
                mapOf(AD_ID to uniqueId)
            )
        }
    }

    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.NATIVE_CREATE -> {
                createAd(call, result)
            }

            AMPSAdSdkMethodNames.NATIVE_LOAD -> {
                handleLoadAd(call, result)
            }

            AMPSAdSdkMethodNames.NATIVE_GET_ECPM -> {
                val mAdId = argsMap(call)?.get(AD_ID) as? String ?: ""
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    val foundWrapper = AdWrapperManager.getInstance().getAdItem(mAdId)
                    result.success(foundWrapper?.ecpm ?: 0)
                } else {
                    val foundWrapper = AdUnifiedWrapperManager.getInstance().getAdItem(mAdId)
                    result.success(foundWrapper?.ecpm ?: 0)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_IS_READY_AD -> {
                val instanceId = instanceIdFrom(call)
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    result.success(nativeAds[instanceId]?.isReady ?: false)
                } else {
                    result.success(unifiedAds[instanceId]?.isReady ?: false)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_IS_NATIVE_EXPRESS -> {
                val adId = argsMap(call)?.get(AD_ID) as? String ?: ""
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    result.success(true)
                } else {
                    val foundWrapper = AdUnifiedWrapperManager.getInstance().getAdItem(adId)
                    result.success(foundWrapper?.isExpressAd ?: false)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_UNIFIED_GET_DOWNLOAD -> {
                val adId = argsMap(call)?.get(AD_ID) as? String ?: ""
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    result.success(null)
                } else {
                    val appDetail = AdUnifiedWrapperManager.getInstance().getAdItem(adId)?.appDetail
                    var infoMap: Map<String, String?>? = null
                    if (appDetail != null) {
                        infoMap = mapOf(
                            "appName" to appDetail.appName,
                            "appVersion" to appDetail.appVersion,
                            "appDeveloper" to appDetail.appDeveloper,
                            "appPermission" to appDetail.appPermissionInfo,
                            "appPrivacy" to appDetail.appPrivacyPolicy,
                            "appIntro" to appDetail.appDescription,
                            "downloadCountDesc" to appDetail.downloadCountDesc,
                            "appScore" to appDetail.appScore,
                            "appPrice" to appDetail.appPrice,
                            "appSize" to appDetail.appSize,
                            "appPackageName" to appDetail.appPackageName,
                            "appIconUrl" to appDetail.appIconUrl
                        )
                    }
                    result.success(infoMap)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_RESUME -> {
                val instanceId = instanceIdFrom(call)
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    nativeAds[instanceId]?.resume()
                } else {
                    unifiedAds[instanceId]?.resume()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_PAUSE -> {
                val instanceId = instanceIdFrom(call)
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    nativeAds[instanceId]?.pause()
                } else {
                    unifiedAds[instanceId]?.pause()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_DESTROY -> {
                val instanceId = instanceIdFrom(call)
                if (instanceId != null) {
                    if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                        nativeAdIdMapByInstance[instanceId]?.values?.forEach { adDestroy(it) }
                        nativeAdIdMapByInstance.remove(instanceId)
                        nativeAds.remove(instanceId)?.destroy()
                    } else {
                        unifiedAdIdMapByInstance[instanceId]?.values?.forEach { adDestroy(it) }
                        unifiedAdIdMapByInstance.remove(instanceId)
                        unifiedAds.remove(instanceId)?.destroy()
                    }
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_PATTERN -> {
                val adId = argsMap(call)?.get(AD_ID) as? String ?: ""
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    result.success(-1)
                } else {
                    val foundWrapper = AdUnifiedWrapperManager.getInstance().getAdItem(adId)
                    val adPattern = foundWrapper?.adPattern?.ordinal ?: 0
                    result.success(adPattern)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_GET_MEDIA_EXTRA_INFO -> {
                val instanceId = instanceIdFrom(call)
                if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
                    val ad = nativeAds[instanceId]
                    val mediaExtraInfo = ad?.mediaExtraInfo?.let { Gson().toJson(it) }
                    result.success(mediaExtraInfo)
                } else {
                    val ad = unifiedAds[instanceId]
                    val mediaExtraInfo = ad?.mediaExtraInfo?.let { Gson().toJson(it) }
                    result.success(mediaExtraInfo)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun createAd(call: MethodCall, result: MethodChannel.Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading native ad.", null)
            return
        }
        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val instanceId = adOptionsMap?.get(AD_INSTANCE_ID) as? String
            if (instanceId.isNullOrEmpty()) {
                result.error("LOAD_FAILED", "adInstanceId missing", null)
                return
            }
            val nativeType = (adOptionsMap[NATIVE_TYPE] as? Int) ?: NativeType.NATIVE.value
            val adOption: AMPSRequestParameters =
                AdOptionsModule.getNativeAdOptionFromMap(adOptionsMap, activity)
            if (nativeType == NativeType.NATIVE.value) {
                nativeAds[instanceId] =
                    AMPSNativeAd(activity as Context, adOption, buildNativeCallback(instanceId))
            } else {
                unifiedAds[instanceId] =
                    AMPSUnifiedNativeAd(activity as Context, adOption, buildUnifiedCallback(instanceId))
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading native ad: ${e.message}", e.toString())
        }
    }

    private fun handleLoadAd(call: MethodCall, result: MethodChannel.Result) {
        val instanceId = instanceIdFrom(call)
        if (nativeTypeFrom(call) == NativeType.NATIVE.value) {
            nativeAds[instanceId]?.loadAd()
        } else {
            unifiedAds[instanceId]?.loadAd()
        }
        result.success(null)
    }

    private fun adDestroy(uniqueId: String) {
        AdUnifiedWrapperManager.getInstance().removeAdItem(uniqueId)
        AdUnifiedWrapperManager.getInstance().removeAdView(uniqueId)
        AdWrapperManager.getInstance().removeAdItem(uniqueId)
        AdWrapperManager.getInstance().removeAdView(uniqueId)
    }

    private fun sendMessage(instanceId: String, method: String, args: Map<String, Any?>) {
        val payload = mutableMapOf<String, Any?>(AD_INSTANCE_ID to instanceId)
        payload.putAll(args)
        AMPSEventManager.getInstance().sendMessageToFlutter(method, payload)
    }
}
