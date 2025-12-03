package xyz.adscope.adscope_sdk.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AMPSAdCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialAd
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.config.AMPSRequestParameters

/**
 * 插屏广告管理器 (单例)
 * 负责处理来自 Flutter 的方法调用
 */
class AMPSInterstitialManager private constructor() {
    private var interstitialAd: AMPSInterstitialAd? = null

    companion object {
        @Volatile
        private var instance: AMPSInterstitialManager? = null

        fun getInstance(): AMPSInterstitialManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSInterstitialManager().also { instance = it }
            }
        }
    }


    private val adCallback = object : AMPSInterstitialLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            // 在旧代码中，这里也有 ON_RENDER_OK，如果 SDK 行为如此，则保留
            sendMessage(AMPSAdCallBackChannelMethod.ON_RENDER_OK)
        }

        override fun onAmpsAdShow() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLOSED)
            interstitialAd?.destroy()
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }

        override fun onAmpsSkippedAd() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_VIDEO_SKIP_TO_END)
        }

        override fun onAmpsVideoPlayStart() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_VIDEO_PLAY_START)
        }

        override fun onAmpsVideoPlayEnd() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_VIDEO_PLAY_END)
        }

    }

    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.INTERSTITIAL_CREATE -> interstitialAdCreate(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_LOAD -> handleInterstitialLoad(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_SHOW_AD -> handleInterstitialShowAd(call, result) // 更改了参数传递
            AMPSAdSdkMethodNames.INTERSTITIAL_GET_ECPM -> {
                result.success(interstitialAd?.ecpm ?: 0)
            }
            AMPSAdSdkMethodNames.INTERSTITIAL_IS_READY_AD -> {
                result.success(interstitialAd?.isReady ?: false)
            }
            AMPSAdSdkMethodNames.INTERSTITIAL_PRE_LOAD -> {
                interstitialAd?.preLoad()
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_ADD_PRE_LOAD_AD_INFO -> {
                interstitialAd?.addPreLoadAdInfo()
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_ADD_PRE_GET_MEDIA_EXTRA_INFO -> {
                val extraInfo = interstitialAd?.mediaExtraInfo
                if (extraInfo != null) {
                    result.success(extraInfo)
                } else {
                    result.success(null)
                }
            }

            else -> result.notImplemented()
        }
    }
    
    private fun interstitialAdCreate(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading Interstitial ad.", null)
            return
        }
        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val adOption: AMPSRequestParameters = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
            interstitialAd = AMPSInterstitialAd(activity, adOption, adCallback)
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading Interstitial ad: ${e.message}", e.toString())
        }
    }
    
    private fun handleInterstitialLoad(call: MethodCall, result: Result) {
        interstitialAd?.loadAd()
        result.success(true)
    }

    // handleInterstitialShowAd 现在也接收 MethodCall 和 Result，以便统一错误处理和参数获取
    private fun handleInterstitialShowAd(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (interstitialAd == null) {
            result.error("SHOW_FAILED", "InterstitiaAd ad not loaded.", null)
            return
        }
       interstitialAd?.show(activity)
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}
