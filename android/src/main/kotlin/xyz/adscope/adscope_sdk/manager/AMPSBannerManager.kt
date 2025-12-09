package xyz.adscope.adscope_sdk.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSBannerCallbackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.banner.AMPSBannerAd
import xyz.adscope.amps.ad.banner.AMPSBannerLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.Objects

class AMPSBannerManager private constructor() {
    private var mBannerAd: AMPSBannerAd? = null

    companion object {
        @Volatile
        private var instance: AMPSBannerManager? = null

        fun getInstance(): AMPSBannerManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSBannerManager().also { instance = it }
            }
        }
    }

    private val adCallback = object : AMPSBannerLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(AMPSBannerCallbackChannelMethod.ON_LOAD_SUCCESS)
        }

        override fun onAmpsAdShow() {
            sendMessage(AMPSBannerCallbackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            sendMessage(AMPSBannerCallbackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            cleanupViewsAfterAdClosed()
            sendMessage(AMPSBannerCallbackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                AMPSBannerCallbackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }

    }


    fun getBannerAd(): AMPSBannerAd? {
        return this.mBannerAd
    }

    /**
     * 清理广告关闭后相关的视图和资源。
     * @param
     */
    private fun cleanupViewsAfterAdClosed() {
        mBannerAd?.destroy()
        mBannerAd = null
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.BANNER_CREATE -> {
                splashAdCreate(call, result)
            }

            AMPSAdSdkMethodNames.BANNER_LOAD -> handleSplashLoad(result)
            AMPSAdSdkMethodNames.BANNER_GET_ECPM -> {
                result.success(mBannerAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.BANNER_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                if (mBannerAd?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(mBannerAd?.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
            }

            AMPSAdSdkMethodNames.BANNER_IS_READY_AD -> {
                result.success(mBannerAd?.isReady ?: false)
            }

            AMPSAdSdkMethodNames.BANNER_DESTROY_AD -> {
                mBannerAd?.destroy()
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
        val adOptionsMap = call.arguments<Map<String, Any>?>()
        val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
        try {
            mBannerAd = AMPSBannerAd(activity, adOption, adCallback)
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading banner ad: ${e.message}", e.toString())
        }
    }

    private fun handleSplashLoad(result: Result) {
        mBannerAd?.loadAd()
        result.success(true)
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}

class AppInfoName{
    val name:String = "哈哈"
    val age:Int = 11
}