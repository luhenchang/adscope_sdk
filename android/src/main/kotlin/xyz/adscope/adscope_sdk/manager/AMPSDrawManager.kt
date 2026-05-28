package xyz.adscope.adscope_sdk.manager

import android.view.View
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AD_ID
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSDrawCallbackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.draw.AMPSDrawAd
import xyz.adscope.amps.ad.draw.AMPSDrawLoadEventListener
import xyz.adscope.amps.ad.draw.adapter.AMPSDrawAdExpressListener
import xyz.adscope.amps.ad.draw.adapter.AMPSDrawAdVideoListener
import xyz.adscope.amps.ad.draw.inter.AMPSDrawAdExpressInfo
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

class AMPSDrawManager private constructor() {
    private val drawAds = ConcurrentHashMap<String, AMPSDrawAd>()
    private val drawAdIdMapByInstance =
        ConcurrentHashMap<String, MutableMap<AMPSDrawAdExpressInfo, String>>()

    companion object {
        @Volatile
        private var instance: AMPSDrawManager? = null

        fun getInstance(): AMPSDrawManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSDrawManager().also { instance = it }
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun argsMap(call: MethodCall): Map<String, Any>? =
        call.arguments as? Map<String, Any>

    private fun instanceIdFrom(call: MethodCall): String? =
        argsMap(call)?.get(AD_INSTANCE_ID) as? String

    private fun drawIdMap(instanceId: String): MutableMap<AMPSDrawAdExpressInfo, String> =
        drawAdIdMapByInstance.getOrPut(instanceId) { mutableMapOf() }

    private fun buildAdCallback(instanceId: String) = object : AMPSDrawLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSDrawAdExpressInfo?>?) {
            val idMap = drawIdMap(instanceId)
            idMap.clear()
            val adIdList = adItems?.filterNotNull()?.map { item ->
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                idMap[item] = uniqueId
                uniqueId
            } ?: emptyList()
            sendMessage(
                instanceId,
                AMPSDrawCallbackChannelMethod.ON_LOAD_SUCCESS,
                mapOf("adIds" to adIdList)
            )
            adItems?.filterNotNull()?.forEach { item ->
                val uniqueId = idMap[item] ?: return@forEach
                item.setAMPSDrawAdExpressInfoListener(object : AMPSDrawAdExpressListener() {
                    override fun onAdShow() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_AD_SHOW,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onAdClicked() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_AD_CLICKED,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onAdClosed(view: View?) {
                        idMap.remove(item)
                        adDestroy(uniqueId)
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_AD_CLOSED,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onRenderFail(view: View?, msg: String?, code: Int) {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_RENDER_FAIL,
                            mapOf(
                                AD_ID to uniqueId,
                                ErrorModel.CODE to code,
                                ErrorModel.MESSAGE to msg
                            )
                        )
                    }

                    override fun onRenderSuccess(drawView: View?, width: Float, height: Float) {
                        if (drawView != null) {
                            AdWrapperManager.getInstance().addDrawAdItem(uniqueId, item)
                            AdWrapperManager.getInstance().addAdView(uniqueId, drawView)
                        }
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_RENDER_SUCCESS,
                            mapOf(AD_ID to uniqueId)
                        )
                    }
                })
                item.setAMPSDrawAdVideoListener(object : AMPSDrawAdVideoListener() {
                    override fun onVideoLoad() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_VIDEO_LOAD,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onVideoError(code: Int, msg: Int) {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_VIDEO_ERROR,
                            mapOf(
                                AD_ID to uniqueId,
                                ErrorModel.CODE to code,
                                "extraCode" to msg
                            )
                        )
                    }

                    override fun onVideoAdStartPlay() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_VIDEO_PLAY_START,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onVideoAdPaused() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_VIDEO_PLAY_PAUSE,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onVideoAdContinuePlay() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_VIDEO_AD_CONTINUE_PLAY,
                            mapOf(AD_ID to uniqueId)
                        )
                    }

                    override fun onProgressUpdate(current: Long, duration: Long) {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_PROGRESS_UPDATE,
                            mapOf(
                                AD_ID to uniqueId,
                                "current" to current,
                                "duration" to duration
                            )
                        )
                    }

                    override fun onVideoAdComplete() {
                        sendMessage(
                            instanceId,
                            AMPSDrawCallbackChannelMethod.ON_VIDEO_AD_COMPLETE,
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
                AMPSDrawCallbackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }
    }

    private fun adDestroy(uniqueId: String) {
        AdWrapperManager.getInstance().removeAdView(uniqueId)
        AdWrapperManager.getInstance().removeDrawAdItem(uniqueId)
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.DRAW_CREATE -> drawAdCreate(call, result)
            AMPSAdSdkMethodNames.DRAW_LOAD -> handleDrawLoad(call, result)
            AMPSAdSdkMethodNames.DRAW_GET_ECPM -> {
                val instanceId = instanceIdFrom(call)
                result.success(drawAds[instanceId]?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.DRAW_GET_MEDIA_EXTRA_INFO -> {
                val instanceId = instanceIdFrom(call)
                val ad = drawAds[instanceId]
                val mediaExtraInfo = ad?.mediaExtraInfo?.let { Gson().toJson(it) }
                result.success(mediaExtraInfo)
            }

            AMPSAdSdkMethodNames.DRAW_IS_READY_AD -> {
                val instanceId = instanceIdFrom(call)
                result.success(drawAds[instanceId]?.isReady ?: false)
            }

            AMPSAdSdkMethodNames.DRAW_DESTROY_AD -> {
                val instanceId = instanceIdFrom(call)
                if (instanceId != null) {
                    drawAdIdMapByInstance[instanceId]?.values?.forEach { adDestroy(it) }
                    drawAdIdMapByInstance.remove(instanceId)
                    drawAds.remove(instanceId)?.destroy()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.DRAW_PAUSE_AD -> {
                val instanceId = instanceIdFrom(call)
                drawAds[instanceId]?.pause()
                result.success(null)
            }

            AMPSAdSdkMethodNames.DRAW_RESUME_AD -> {
                val instanceId = instanceIdFrom(call)
                drawAds[instanceId]?.resume()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun drawAdCreate(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading draw ad.", null)
            return
        }
        val adOptionsMap = call.arguments<Map<String, Any>?>()
        val instanceId = adOptionsMap?.get(AD_INSTANCE_ID) as? String
        if (instanceId.isNullOrEmpty()) {
            result.error("LOAD_FAILED", "adInstanceId missing", null)
            return
        }
        val adOption = AdOptionsModule.getNativeAdOptionFromMap(adOptionsMap, activity)
        try {
            drawAds[instanceId] = AMPSDrawAd(activity, adOption, buildAdCallback(instanceId))
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading draw ad: ${e.message}", e.toString())
        }
    }

    private fun handleDrawLoad(call: MethodCall, result: Result) {
        val instanceId = instanceIdFrom(call)
        drawAds[instanceId]?.loadAd()
        result.success(true)
    }

    private fun sendMessage(instanceId: String, method: String, args: Map<String, Any?>) {
        val payload = mutableMapOf<String, Any?>(AD_INSTANCE_ID to instanceId)
        payload.putAll(args)
        AMPSEventManager.getInstance().sendMessageToFlutter(method, payload)
    }
}
