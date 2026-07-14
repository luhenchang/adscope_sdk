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
            // code 可能非数字、message 可能为 null，必须做安全兜底，否则异常会导致 Flutter 收不到失败回调
            val code = try {
                error?.code?.toInt() ?: -1
            } catch (e: Exception) {
                -1
            }
            sendMessage(
                instanceId,
                AMPSInterAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to code,
                    ErrorModel.MESSAGE to (error?.message ?: "load failed")
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
        // 兜底捕获：任何未处理异常都必须回调 result，否则 Flutter 侧 Future 永远不会完成
        try {
            handleMethodCallInternal(call, result)
        } catch (e: Exception) {
            try {
                result.error("INTERSTITIAL_EXCEPTION", "Error handling ${call.method}: ${e.message}", e.toString())
            } catch (ignored: Exception) {
                // result 已被回调过，忽略二次回调异常
            }
        }
    }

    private fun handleMethodCallInternal(call: MethodCall, result: Result) {
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
                val ad = interstitialAds[instanceIdFrom(call)]
                if (ad == null) {
                    // 实例不存在必须显式报错，避免 Dart 端误以为预加载成功
                    result.error("PRELOAD_FAILED", "Interstitial ad instance not found, create may have failed.", null)
                } else {
                    ad.preLoad()
                    result.success(null)
                }
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
        val ad = interstitialAds[instanceIdFrom(call)]
        if (ad == null) {
            // 实例不存在（create 失败或已销毁），必须显式报错，避免静默失败
            result.error("LOAD_FAILED", "Interstitial ad instance not found, create may have failed.", null)
            return
        }
        try {
            ad.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading Interstitial ad: ${e.message}", e.toString())
        }
    }

    // handleInterstitialShowAd 现在也接收 MethodCall 和 Result，以便统一错误处理和参数获取
    private fun handleInterstitialShowAd(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        val ad = interstitialAds[instanceIdFrom(call)]
        if (ad == null) {
            result.error("SHOW_FAILED", "InterstitiaAd ad not loaded.", null)
            return
        }
        if (activity == null) {
            // activity 为空时也必须回调 result，否则 Flutter 侧 Future 永远不会完成
            result.error("SHOW_FAILED", "Activity not available for showing Interstitial ad.", null)
            return
        }
        try {
            ad.show(activity)
            result.success(null)
        } catch (e: Exception) {
            // show 过程异常必须回调 error，否则 Flutter 侧收不到任何消息
            result.error("SHOW_EXCEPTION", "Error showing Interstitial ad: ${e.message}", e.toString())
        }
    }

    private fun sendMessage(instanceId: String, method: String, args: Any? = null) {
        try {
            val payload = mutableMapOf<String, Any?>(AD_INSTANCE_ID to instanceId)
            if (args is Map<*, *>) {
                @Suppress("UNCHECKED_CAST")
                payload.putAll(args as Map<String, Any?>)
            } else if (args != null) {
                payload["data"] = args
            }
            AMPSEventManager.getInstance().sendMessageToFlutter(method, payload)
        } catch (e: Exception) {
            // 回传 Flutter 失败不应把异常抛回 AMPS SDK 回调线程
        }
    }
}
