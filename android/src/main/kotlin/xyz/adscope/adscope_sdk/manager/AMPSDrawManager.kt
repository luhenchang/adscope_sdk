package xyz.adscope.adscope_sdk.manager

import android.view.View
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
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

class AMPSDrawManager private constructor() {
    private var mDrawAd: AMPSDrawAd? = null
    private val adIdMap = mutableMapOf<AMPSDrawAdExpressInfo, String>()

    companion object {
        @Volatile
        private var instance: AMPSDrawManager? = null

        fun getInstance(): AMPSDrawManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSDrawManager().also { instance = it }
            }
        }
    }

    private val adCallback = object : AMPSDrawLoadEventListener() {
        override fun onAmpsAdLoad(adItems: List<AMPSDrawAdExpressInfo?>?) {
            adIdMap.clear()
            val adIdList = adItems?.filterNotNull()?.map { item ->
                val uniqueId = UUID.randomUUID().toString().replace("-", "")
                adIdMap[item] = uniqueId
                uniqueId
            }
            sendMessage(AMPSDrawCallbackChannelMethod.ON_LOAD_SUCCESS, adIdList)
            adItems?.filterNotNull()?.forEach { item ->
                val uniqueId = adIdMap[item]
                if (uniqueId != null) {
                    item.setAMPSDrawAdExpressInfoListener(object : AMPSDrawAdExpressListener() {
                        override fun onAdShow() {
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_AD_SHOW, uniqueId)
                        }

                        override fun onAdClicked() {
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_AD_CLICKED, uniqueId)
                        }

                        override fun onAdClosed(view: View?) {
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_AD_CLOSED, uniqueId)
                        }

                        override fun onRenderFail(
                            view: View?,
                            msg: String?,
                            code: Int
                        ) {
                            sendMessage(
                                AMPSDrawCallbackChannelMethod.ON_RENDER_FAIL,
                                mapOf(
                                    ErrorModel.CODE to code,
                                    ErrorModel.MESSAGE to msg
                                )
                            )
                        }

                        override fun onRenderSuccess(
                            drawView: View?,
                            width: Float,
                            height: Float
                        ) {
                            if (drawView != null) {
                                AdWrapperManager.getInstance().addDrawAdItem(uniqueId, item)
                                AdWrapperManager.getInstance().addAdView(uniqueId, drawView)
                            }
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_RENDER_SUCCESS, uniqueId)
                        }
                    })
                    item.setAMPSDrawAdVideoListener(object : AMPSDrawAdVideoListener() {
                        override fun onVideoLoad() {
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_VIDEO_LOAD, uniqueId)
                        }

                        override fun onVideoError(code: Int, msg: Int) {
                            sendMessage(
                                AMPSDrawCallbackChannelMethod.ON_VIDEO_ERROR,
                                mapOf(
                                    "adId" to uniqueId,
                                    "errorCode" to code,
                                    "extraCode" to msg
                                )
                            )
                        }

                        override fun onVideoAdStartPlay() {
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_VIDEO_PLAY_START, uniqueId)
                        }

                        override fun onVideoAdPaused() {
                            sendMessage(AMPSDrawCallbackChannelMethod.ON_VIDEO_PLAY_PAUSE, uniqueId)
                        }

                        override fun onVideoAdContinuePlay() {
                            sendMessage(
                                AMPSDrawCallbackChannelMethod.ON_VIDEO_AD_CONTINUE_PLAY,
                                uniqueId
                            )
                        }

                        override fun onProgressUpdate(current: Long, duration: Long) {
                            sendMessage(
                                AMPSDrawCallbackChannelMethod.ON_PROGRESS_UPDATE, mapOf(
                                    "adId" to uniqueId,
                                    "current" to current,
                                    "duration" to duration
                                )
                            )
                        }

                        override fun onVideoAdComplete() {
                            sendMessage(
                                AMPSDrawCallbackChannelMethod.ON_VIDEO_AD_COMPLETE,
                                uniqueId
                            )
                        }
                    })
                    item.render()
                }
            }
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                AMPSDrawCallbackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }
    }


    fun getBannerAd(): AMPSDrawAd? {
        return this.mDrawAd
    }

    /**
     * 清理广告关闭后相关的视图和资源。
     * @param
     */
    private fun cleanupViewsAfterAdClosed() {
        mDrawAd?.destroy()
        mDrawAd = null
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.DRAW_CREATE -> {
                splashAdCreate(call, result)
            }

            AMPSAdSdkMethodNames.DRAW_LOAD -> handleSplashLoad(result)
            AMPSAdSdkMethodNames.DRAW_GET_ECPM -> {
                result.success(mDrawAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.DRAW_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                if (mDrawAd?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(mDrawAd?.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
            }

            AMPSAdSdkMethodNames.DRAW_IS_READY_AD -> {
                result.success(mDrawAd?.isReady ?: false)
            }

            AMPSAdSdkMethodNames.DRAW_DESTROY_AD -> {
                mDrawAd?.destroy()
                result.success(null)
            }

            AMPSAdSdkMethodNames.DRAW_PAUSE_AD -> {
                mDrawAd?.pause()
                result.success(null)
            }

            AMPSAdSdkMethodNames.DRAW_RESUME_AD -> {
                mDrawAd?.resume()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun splashAdCreate(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading draw ad.", null)
            return
        }
        val adOptionsMap = call.arguments<Map<String, Any>?>()
        val adOption = AdOptionsModule.getNativeAdOptionFromMap(adOptionsMap, activity)
        try {
            mDrawAd = AMPSDrawAd(activity, adOption, adCallback)
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading draw ad: ${e.message}", e.toString())
        }
    }

    private fun handleSplashLoad(result: Result) {
        mDrawAd?.loadAd()
        result.success(true)
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}