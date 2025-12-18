package xyz.adscope.adscope_sdk.manager

import android.content.Context
import android.view.View
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import xyz.adscope.adscope_sdk.data.AD_ID
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
import kotlin.collections.mapOf
@Suppress("UNCHECKED_CAST")
class AMPSNativeManager {
    //原生广告
    private var mNativeAd: AMPSNativeAd? = null

    //自渲染广告
    private var mUnifiedAd: AMPSUnifiedNativeAd? = null

    // 用于存储广告项与唯一ID的映射关系
    private val adIdMap = mutableMapOf<AMPSNativeAdExpressInfo, String>()
    private val adCallback = object : AMPSNativeLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSNativeAdExpressInfo?>?) {
            // 清除之前的映射
            adIdMap.clear()
            // 为每个有效广告项生成唯一ID并建立映射
            val adIdList = adItems?.filterNotNull()?.map { item ->
                // 生成UUID作为唯一标识
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                adIdMap[item] = uniqueId
                uniqueId
            }
            sendMessage(AMPSNativeCallBackChannelMethod.LOAD_OK, adIdList)
            adItems?.filterNotNull()?.forEach { item ->
                // 从映射中获取当前广告项的唯一ID
                val uniqueId = adIdMap[item]
                if (uniqueId != null) {
                    item.setAMPSNativeAdExpressListener(object : AMPSNativeAdExpressListener() {
                        override fun onAdShow() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_SHOW, uniqueId)
                        }

                        override fun onAdClicked() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLICKED, uniqueId)
                        }

                        override fun onAdClosed(p0: View?) {
                            adIdMap.remove(item)
                            adDestroy(uniqueId)
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLOSED, uniqueId)
                        }

                        override fun onRenderFail(p0: View?, p1: String?, p2: Int) {
                            sendMessage(
                                AMPSNativeCallBackChannelMethod.RENDER_FAILED,
                                mapOf(
                                    AD_ID to uniqueId,
                                    CODE to p2,
                                    MESSAGE to p1
                                )
                            )
                        }

                        override fun onRenderSuccess(p0: View?, p1: Float, p2: Float) {
                            if (p0 != null) {
                                AdWrapperManager.getInstance().addAdItem(uniqueId, item)
                                AdWrapperManager.getInstance().addAdView(uniqueId, p0)
                            }
                            sendMessage(AMPSNativeCallBackChannelMethod.RENDER_SUCCESS, uniqueId)
                        }
                    })
                    item.render()
                }
            }
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                mapOf(
                    CODE to (error?.code?.toInt() ?: -1),
                    MESSAGE to error?.message
                )
            )
        }
    }

    private val adUnifiedIdMap = mutableMapOf<AMPSUnifiedNativeItem, String>()
    private val adUnifiedCallback = object : AMPSUnifiedNativeLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSUnifiedNativeItem?>?) {
            // 清除之前的映射
            adUnifiedIdMap.clear()
            // 为每个有效广告项生成唯一ID并建立映射
            val adIdList = adItems?.filterNotNull()?.map { item ->
                // 生成UUID作为唯一标识
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                adUnifiedIdMap[item] = uniqueId
                uniqueId
            }
            sendMessage(AMPSNativeCallBackChannelMethod.LOAD_OK, adIdList)
            adItems?.filterNotNull()?.forEach { item ->
                // 从映射中获取当前广告项的唯一ID
                val uniqueId = adUnifiedIdMap[item] ?: return
                setDownLoadListener(item, uniqueId)
                item.setNegativeFeedbackListener{
                    sendMessage(AMPSNativeCallBackChannelMethod.ON_COMPLAIN_SUCCESS, uniqueId)
                }
                if (item.isExpressAd) {
                    item.setNativeAdExpressListener(object : AMPSNativeAdExpressListener() {
                        override fun onAdShow() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_SHOW, uniqueId)
                        }

                        override fun onAdClicked() {
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLICKED, uniqueId)
                        }

                        override fun onAdClosed(p0: View?) {
                            adUnifiedIdMap.remove(item)
                            adDestroy(uniqueId)
                            sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLOSED, uniqueId)
                        }

                        override fun onRenderFail(p0: View?, p1: String?, p2: Int) {
                            sendMessage(
                                AMPSNativeCallBackChannelMethod.RENDER_FAILED,
                                mapOf(
                                    AD_ID to uniqueId,
                                    CODE to p2,
                                    MESSAGE to p1
                                )
                            )
                        }

                        override fun onRenderSuccess(p0: View?, p1: Float, p2: Float) {
                            if (p0 != null) {
                                AdWrapperManager.getInstance().addAdView(uniqueId, p0)
                            }
                            sendMessage(AMPSNativeCallBackChannelMethod.RENDER_SUCCESS, uniqueId)
                        }
                    })
                    item.render()
                    return
                }
                setNoExpressAdListener(uniqueId, item)
            }
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            sendMessage(
                AMPSNativeCallBackChannelMethod.LOAD_FAIL,
                mapOf(
                    CODE to (p0?.code?.toInt() ?: -1),
                    MESSAGE to p0?.message
                )
            )
        }
    }

    private fun setDownLoadListener(
        item: AMPSUnifiedNativeItem,
        uniqueId: String?
    ) {
        item.setDownloadListener(object : AMPSUnifiedDownloadListener {
            override fun onDownloadPaused(position: Int) {
                sendMessage(
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_PAUSED,
                    mapOf("position" to position, "adId" to uniqueId)
                )
            }

            override fun onDownloadStarted() {
                sendMessage(DownLoadCallBackChannelMethod.ON_DOWNLOAD_STARTED, uniqueId)
            }

            override fun onDownloadProgressUpdate(position: Int) {
                sendMessage(
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_PROGRESS_UPDATE,
                    mapOf("position" to position, "adId" to uniqueId)

                )
            }

            override fun onDownloadFinished() {
                sendMessage(
                    DownLoadCallBackChannelMethod.ON_DOWNLOAD_FINISHED,
                    uniqueId
                )
            }

            override fun onDownloadFailed() {
                sendMessage(DownLoadCallBackChannelMethod.ON_DOWNLOAD_FAILED, uniqueId)
            }

            override fun onInstalled() {
                sendMessage(DownLoadCallBackChannelMethod.ON_INSTALLED, uniqueId)
            }
        })
    }

    private fun setNoExpressAdListener(
        uniqueId: String?,
        item: AMPSUnifiedNativeItem
    ) {
        if (uniqueId != null) {
            item.setNativeAdEventListener(object : AMPSUnifiedAdEventListener {
                override fun onADExposed() {
                    sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_SHOW, uniqueId)
                    sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE, uniqueId)
                }

                override fun onADClicked() {
                    sendMessage(AMPSNativeCallBackChannelMethod.ON_AD_CLICKED, uniqueId)
                }

                override fun onADExposeError(p0: Int, p1: String?) {
                    sendMessage(
                        AMPSNativeCallBackChannelMethod.ON_AD_EXPOSURE_FAIL,
                        mapOf(AD_ID to uniqueId, CODE to p0, MESSAGE to p1)
                    )
                }
            })
            AdUnifiedWrapperManager.getInstance().addAdItem(uniqueId, item)
            sendMessage(AMPSNativeCallBackChannelMethod.RENDER_SUCCESS, uniqueId)
        }
    }

    companion object {
        @Volatile
        private var instance: AMPSNativeManager? = null

        fun getInstance(): AMPSNativeManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSNativeManager().also { instance = it }
            }
        }
    }

    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments
        when (call.method) {
            AMPSAdSdkMethodNames.NATIVE_CREATE -> {
                createAd(call, result)
            }

            AMPSAdSdkMethodNames.NATIVE_LOAD -> {
                handleLoadAd(call, result)
            }

            AMPSAdSdkMethodNames.NATIVE_GET_ECPM -> {
                val params = args as HashMap<String, Any>
                val nativeType = params[NATIVE_TYPE] as? Int ?: 0
                val mAdId = params[AD_ID] as? String ?: ""
                if (nativeType == 0) {
                    val foundWrapper = getAdWrapperByAdId(mAdId)
                    val mEcpm = foundWrapper?.ecpm ?: 0
                    result.success(mEcpm)
                } else {
                    val foundWrapper = getAdUnifiedByAdId(mAdId)
                    val mEcpm = foundWrapper?.ecpm ?: 0
                    result.success(mEcpm)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_IS_READY_AD -> {
                if ((call.arguments as Int) == NativeType.NATIVE.value) {
                    result.success(mNativeAd?.isReady ?: false)
                } else {
                    result.success(mUnifiedAd?.isReady ?: false)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_IS_NATIVE_EXPRESS -> {
                val lossParams = args as HashMap<String, Any>
                val nativeType = lossParams[NATIVE_TYPE] as? Int ?: 0
                val adId = lossParams[AD_ID] as? String ?: ""
                if (nativeType == 0) {
                    result.success(true)
                } else {
                    val foundWrapper = getAdUnifiedByAdId(adId)
                    val isNativeExpress = foundWrapper?.isExpressAd ?: false
                    result.success(isNativeExpress)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_UNIFIED_GET_DOWNLOAD -> {
                val params = args as HashMap<String, Any>
                val nativeType = params[NATIVE_TYPE] as? Int ?: 0
                val adId = params[AD_ID] as? String ?: ""
                if (nativeType == NativeType.NATIVE.value) {
                    result.success(null)
                } else {
                    val appDetail = getAdUnifiedByAdId(adId)?.appDetail
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
                if ((call.arguments as Int) == NativeType.NATIVE.value) {
                    mNativeAd?.resume()
                } else {
                    mUnifiedAd?.resume()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_PAUSE -> {
                if ((call.arguments as Int) == NativeType.NATIVE.value) {
                    mNativeAd?.pause()
                } else {
                    mUnifiedAd?.pause()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_DESTROY -> {
                if ((call.arguments as Int) == NativeType.NATIVE.value) {
                    adIdMap.forEach { enty ->
                        adDestroy(enty.value)
                    }
                    mNativeAd?.destroy()
                } else {
                    adUnifiedIdMap.forEach { enty ->
                        adDestroy(enty.value)
                    }
                    mUnifiedAd?.destroy()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.NATIVE_PATTERN -> {
                val vdConfigParams = args as HashMap<String, Any>
                val adId = vdConfigParams[AD_ID] as? String ?: ""
                val nativeType = vdConfigParams[NATIVE_TYPE] as? Int ?: 0
                if (nativeType == 0) {
                    result.success(-1)
                } else {
                    val foundWrapper = getAdUnifiedByAdId(adId)
                    val adPattern = foundWrapper?.adPattern?.ordinal ?: 0
                    result.success(adPattern)
                }
            }

            AMPSAdSdkMethodNames.NATIVE_GET_MEDIA_EXTRA_INFO -> {
                val vdConfigParams = args as HashMap<String, Any>
                val nativeType = vdConfigParams[NATIVE_TYPE] as? Int ?: 0
                if (nativeType == 0) {
                    var mediaExtraInfo: String? = null
                    if (mNativeAd?.mediaExtraInfo != null) {
                        mediaExtraInfo = Gson().toJson(mNativeAd?.mediaExtraInfo)
                    }
                    result.success(mediaExtraInfo)
                } else {
                    var mediaExtraInfo: String? = null
                    if (mUnifiedAd?.mediaExtraInfo != null) {
                        mediaExtraInfo = Gson().toJson(mUnifiedAd?.mediaExtraInfo)
                    }
                    result.success(mediaExtraInfo)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun createAd(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading native ad.", null)
            return
        }
        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val nativeType = (adOptionsMap?.get(NATIVE_TYPE) ?: NativeType.NATIVE.value) as Int
            val adOption: AMPSRequestParameters =
                AdOptionsModule.getNativeAdOptionFromMap(adOptionsMap, activity)
            if (nativeType == NativeType.NATIVE.value) {
                mNativeAd = AMPSNativeAd(activity as Context, adOption, adCallback)
            } else {
                mUnifiedAd = AMPSUnifiedNativeAd(activity as Context, adOption, adUnifiedCallback)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading native ad: ${e.message}", e.toString())
        }
    }

    private fun getAdWrapperByAdId(targetAdId: String): AMPSNativeAdExpressInfo? {
        return AdWrapperManager.getInstance().getAdItem(targetAdId)
    }

    private fun getAdUnifiedByAdId(targetAdId: String): AMPSUnifiedNativeItem? {
        return AdUnifiedWrapperManager.getInstance().getAdItem(targetAdId)
    }

    private fun handleLoadAd(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        if ((call.arguments as Int) == NativeType.NATIVE.value) {
            mNativeAd?.loadAd()
        } else {
            mUnifiedAd?.loadAd()
        }
        result.success(null)
    }

    private fun adDestroy(uniqueId: String) {
        AdUnifiedWrapperManager.getInstance().removeAdItem(uniqueId)
        AdUnifiedWrapperManager.getInstance().removeAdView(uniqueId)
        AdWrapperManager.getInstance().removeAdItem(uniqueId)
        AdWrapperManager.getInstance().removeAdView(uniqueId)
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}