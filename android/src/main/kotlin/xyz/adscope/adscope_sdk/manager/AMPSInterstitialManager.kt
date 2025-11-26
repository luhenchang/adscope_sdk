package xyz.adscope.adscope_sdk.manager

import android.app.Activity
import xyz.adscope.adscope_sdk.data.AD_LOSS_REASON
import xyz.adscope.adscope_sdk.data.AD_SEC_PRICE
import xyz.adscope.adscope_sdk.data.AD_WIN_PRICE
import xyz.adscope.adscope_sdk.data.AMPSAdCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.StringConstants
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialAd
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.config.AMPSRequestParameters
import java.lang.ref.WeakReference

/**
 * 插屏广告管理器 (单例)
 * 负责处理来自 Flutter 的方法调用
 */
class AMPSInterstitialManager private constructor() {
    private var interstitialAd: AMPSInterstitialAd? = null
    private var currentActivityRef: WeakReference<Activity>? =
        WeakReference(AMPSEventManager.getInstance().getContext())

    companion object {
        @Volatile
        private var instance: AMPSInterstitialManager? = null

        fun getInstance(): AMPSInterstitialManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSInterstitialManager().also { instance = it }
            }
        }
    }

    private fun getCurrentActivity(): Activity? = currentActivityRef?.get()

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

        override fun onAmpsAdFailed(p0: AMPSError?) {
            sendMessage(
                AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf("code" to p0?.code, "message" to p0?.message)
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
        val args = call.arguments<Map<String, Any>?>()
        when (call.method) {
            AMPSAdSdkMethodNames.INTERSTITIAL_LOAD -> handleSplashLoad(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_SHOW_AD -> handleSplashShowAd(call, result) // 更改了参数传递
            AMPSAdSdkMethodNames.INTERSTITIAL_GET_ECPM -> {
                result.success(interstitialAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_NOTIFY_RTB_WIN -> {
                val winPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val secPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                //interstitialAd?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_NOTIFY_RTB_LOSS -> {
                val lossWinPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val lossSecPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                val lossReason =
                    args?.get(AD_LOSS_REASON) as? String ?: StringConstants.EMPTY_STRING
                //interstitialAd?.notifyRTBLoss(lossWinPrice.toInt(), lossSecPrice.toInt(), lossReason)
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_IS_READY_AD -> {
                result.success(interstitialAd?.isReady ?: false)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleSplashLoad(call: MethodCall, result: Result) {
        val activity = getCurrentActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading interstitia ad.", null)
            return
        }

        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val adOption: AMPSRequestParameters = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
            interstitialAd = AMPSInterstitialAd(activity, adOption, adCallback)
            interstitialAd?.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading interstitiaAd ad: ${e.message}", e.toString())
        }
    }

    // handleSplashShowAd 现在也接收 MethodCall 和 Result，以便统一错误处理和参数获取
    private fun handleSplashShowAd(call: MethodCall, result: Result) {
        val activity = getCurrentActivity()
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
