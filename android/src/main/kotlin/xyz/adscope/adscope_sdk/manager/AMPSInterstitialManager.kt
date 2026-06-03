package xyz.adscope.adscope_sdk.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSInterAdCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialAd
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.config.AMPSRequestParameters
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.concurrent.ConcurrentHashMap

/**
 * 插屏广告管理器 (单例)
 * 负责处理来自 Flutter 的方法调用
 */
class AMPSInterstitialManager private constructor() {
    private val interstitialAds = ConcurrentHashMap<String, AMPSInterstitialAd>()

    companion object {
        @Volatile
        private var instance: AMPSInterstitialManager? = null

        fun getInstance(): AMPSInterstitialManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSInterstitialManager().also { instance = it }
            }
        }
    }


    private fun createAdCallback(instanceId: String) = object : AMPSInterstitialLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_RENDER_OK)
        }

        override fun onAmpsAdShow() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                instanceId,
                AMPSInterAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }

        override fun onAmpsSkippedAd() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_VIDEO_SKIP_TO_END)
        }

        override fun onAmpsVideoPlayStart() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_VIDEO_PLAY_START)
        }

        override fun onAmpsVideoPlayEnd() {
            sendMessage(instanceId, AMPSInterAdCallBackChannelMethod.ON_VIDEO_PLAY_END)
        }

    }

    @Suppress("UNCHECKED_CAST")
    private fun argsAsMap(call: MethodCall): Map<String, Any>? = call.arguments as? Map<String, Any>

    private fun instanceIdFrom(call: MethodCall): String? = argsAsMap(call)?.get(AD_INSTANCE_ID) as? String

    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.INTERSTITIAL_CREATE -> interstitialAdCreate(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_LOAD -> handleInterstitialLoad(call, result)
            AMPSAdSdkMethodNames.INTERSTITIAL_SHOW_AD -> handleInterstitialShowAd(call, result) // 更改了参数传递
            AMPSAdSdkMethodNames.INTERSTITIAL_GET_ECPM -> {
                result.success(interstitialAds[instanceIdFrom(call)]?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_GET_SEAT_ID -> {
                result.success(interstitialAds[instanceIdFrom(call)]?.seatId)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_IS_READY_AD -> {
                result.success(interstitialAds[instanceIdFrom(call)]?.isReady ?: false)
            }
            AMPSAdSdkMethodNames.INTERSTITIAL_PRE_LOAD -> {
                interstitialAds[instanceIdFrom(call)]?.preLoad()
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_ADD_PRE_LOAD_AD_INFO -> {
                interstitialAds[instanceIdFrom(call)]?.addPreLoadAdInfo()
                result.success(null)
            }

            AMPSAdSdkMethodNames.INTERSTITIAL_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                val ad = interstitialAds[instanceIdFrom(call)]
                if (ad?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(ad.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
            }
            AMPSAdSdkMethodNames.INTERSTITIAL_DESTROY ->{
                val instanceId = instanceIdFrom(call)
                if (instanceId != null) {
                    interstitialAds.remove(instanceId)?.destroy()
                }
                result.success(null)
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
            val adOptionsMap = argsAsMap(call)
            val instanceId = adOptionsMap?.get(AD_INSTANCE_ID) as? String
            if (instanceId.isNullOrEmpty()) {
                result.error("LOAD_FAILED", "adInstanceId missing", null)
                return
            }
            val adOption: AMPSRequestParameters = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
            interstitialAds[instanceId] = AMPSInterstitialAd(activity, adOption, createAdCallback(instanceId))
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading Interstitial ad: ${e.message}", e.toString())
        }
    }
    
    private fun handleInterstitialLoad(call: MethodCall, result: Result) {
        interstitialAds[instanceIdFrom(call)]?.loadAd()
        result.success(true)
    }

    // handleInterstitialShowAd 现在也接收 MethodCall 和 Result，以便统一错误处理和参数获取
    private fun handleInterstitialShowAd(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        val ad = interstitialAds[instanceIdFrom(call)]
        if (ad == null) {
            result.error("SHOW_FAILED", "InterstitiaAd ad not loaded.", null)
            return
        }
       ad.show(activity)
       result.success(null)
    }

    private fun sendMessage(instanceId: String, method: String, args: Any? = null) {
        val payload = mutableMapOf<String, Any?>(AD_INSTANCE_ID to instanceId)
        if (args is Map<*, *>) {
            @Suppress("UNCHECKED_CAST")
            payload.putAll(args as Map<String, Any?>)
        } else if (args != null) {
            payload["data"] = args
        }
        AMPSEventManager.getInstance().sendMessageToFlutter(method, payload)
    }
}
