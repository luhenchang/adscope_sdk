package xyz.adscope.adscope_sdk.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSBannerCallbackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.banner.AMPSBannerAd
import xyz.adscope.amps.ad.banner.AMPSBannerLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.concurrent.ConcurrentHashMap

class AMPSBannerManager private constructor() {
    private val bannerAds = ConcurrentHashMap<String, AMPSBannerAd>()

    companion object {
        @Volatile
        private var instance: AMPSBannerManager? = null

        fun getInstance(): AMPSBannerManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSBannerManager().also { instance = it }
            }
        }
    }

    private fun createAdCallback(instanceId: String) = object : AMPSBannerLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(instanceId, AMPSBannerCallbackChannelMethod.ON_LOAD_SUCCESS)
        }

        override fun onAmpsAdShow() {
            sendMessage(instanceId, AMPSBannerCallbackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            sendMessage(instanceId, AMPSBannerCallbackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            sendMessage(instanceId, AMPSBannerCallbackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                instanceId,
                AMPSBannerCallbackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }

    }

    @Suppress("UNCHECKED_CAST")
    private fun argsAsMap(call: MethodCall): Map<String, Any>? = call.arguments as? Map<String, Any>
    private fun instanceIdFrom(call: MethodCall): String? = argsAsMap(call)?.get(AD_INSTANCE_ID) as? String


    fun getBannerAd(instanceId: String? = null): AMPSBannerAd? {
        if (!instanceId.isNullOrEmpty()) {
            return bannerAds[instanceId]
        }
        return bannerAds.values.lastOrNull()
    }


    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.BANNER_CREATE -> {
                splashAdCreate(call, result)
            }

            AMPSAdSdkMethodNames.BANNER_LOAD -> handleSplashLoad(call, result)
            AMPSAdSdkMethodNames.BANNER_GET_ECPM -> {
                result.success(bannerAds[instanceIdFrom(call)]?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.BANNER_GET_SEAT_ID -> {
                result.success(bannerAds[instanceIdFrom(call)]?.seatId)
            }

            AMPSAdSdkMethodNames.BANNER_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                val ad = bannerAds[instanceIdFrom(call)]
                if (ad?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(ad.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
            }

            AMPSAdSdkMethodNames.BANNER_IS_READY_AD -> {
                result.success(bannerAds[instanceIdFrom(call)]?.isReady ?: false)
            }

            AMPSAdSdkMethodNames.BANNER_DESTROY_AD -> {
                val instanceId = instanceIdFrom(call)
                if (instanceId != null) {
                    bannerAds.remove(instanceId)?.destroy()
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun splashAdCreate(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading banner ad.", null)
            return
        }
        val adOptionsMap = argsAsMap(call)
        val instanceId = adOptionsMap?.get(AD_INSTANCE_ID) as? String
        if (instanceId.isNullOrEmpty()) {
            result.error("LOAD_FAILED", "adInstanceId missing", null)
            return
        }
        val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
        try {
            bannerAds[instanceId] = AMPSBannerAd(activity, adOption, createAdCallback(instanceId))
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading banner ad: ${e.message}", e.toString())
        }
    }

    private fun handleSplashLoad(call: MethodCall, result: Result) {
        bannerAds[instanceIdFrom(call)]?.loadAd()
        result.success(true)
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