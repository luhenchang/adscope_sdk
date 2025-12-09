import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSRewardedVideoCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.reward.AMPSRewardVideoAd
import xyz.adscope.amps.ad.reward.AMPSRewardVideoLoadEventListener
import xyz.adscope.amps.common.AMPSError

/**
 * 插屏广告管理器 (单例)
 * 负责处理来自 Flutter 的方法调用
 */
class AMPSRewardedVideoManager private constructor() {
    private var rewardedVideoAd: AMPSRewardVideoAd? = null

    companion object {
        @Volatile
        private var instance: AMPSRewardedVideoManager? = null

        fun getInstance(): AMPSRewardedVideoManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSRewardedVideoManager().also { instance = it }
            }
        }
    }


    private val adCallback = object : AMPSRewardVideoLoadEventListener {

        override fun onAmpsAdLoad() {
            sendMessage(AMPSRewardedVideoCallBackChannelMethod.ON_LOAD_SUCCESS)
        }

        override fun onAmpsAdCached() {
            sendMessage(AMPSRewardedVideoCallBackChannelMethod.ON_AD_CACHED)
        }

        override fun onAmpsAdVideoClick() {
            sendMessage(AMPSRewardedVideoCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdVideoComplete() {
            sendMessage(AMPSRewardedVideoCallBackChannelMethod.ON_VIDEO_PLAY_END)
        }

        override fun onAmpsAdVideoError() {
            sendMessage(
                AMPSRewardedVideoCallBackChannelMethod.ON_VIDEO_PLAY_ERROR,
                mapOf(
                    ErrorModel.CODE to -1,
                    ErrorModel.MESSAGE to "video play error"
                )
            )
        }

        /**
         * 激励视频奖励回调
         *
         * @param isRewardValid 奖励是否有效  true 有效 false 无效
         * @param rewardType    奖励类型
         * @param extraInfo     返回的额外信息
         */
        override fun onAmpsAdRewardArrived(
            isRewardValid: Boolean,
            rewardType: Int,
            extraInfo: Map<String?, Any?>?
        ) {
            sendMessage(
                AMPSRewardedVideoCallBackChannelMethod.ON_AD_REWARD,
                mapOf(
                    "isRewardValid" to isRewardValid,
                    "rewardType" to rewardType,
                    "extraInfo" to extraInfo
                )
            )
        }

        override fun onAmpsAdShow() {
            sendMessage(AMPSRewardedVideoCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdDismiss() {
            sendMessage(AMPSRewardedVideoCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            sendMessage(
                AMPSRewardedVideoCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (p0?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to p0?.message
                )
            )
        }
    }

    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.REWARDED_VIDEO_CREATE -> createAd(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_LOAD -> handleRewardedVideoLoad(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_PRE_LOAD -> {
                rewardedVideoAd?.preLoad()
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_SHOW_AD -> handleRewardedVideoShowAd(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_ECPM -> {
                result.success(rewardedVideoAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_IS_READY_AD -> {
                result.success(rewardedVideoAd?.isReady)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_DESTROY_AD -> {
                rewardedVideoAd?.destroy()
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_ADD_PRE_LOAD_AD_INFO -> {
                rewardedVideoAd?.addPreLoadAdInfo()
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_MEDIA_EXTRA_INFO -> {
                result.success(rewardedVideoAd?.mediaExtraInfo)
            }

            else -> result.notImplemented()
        }
    }

    private fun createAd(
        call: MethodCall,
        result: Result
    ) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading splash ad.", null)
            return
        }
        val adOptionsMap = call.arguments<Map<String, Any>?>()
        val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
        rewardedVideoAd = AMPSRewardVideoAd(activity, adOption, adCallback)
        result.success(null)
    }

    private fun handleRewardedVideoLoad(call: MethodCall, result: Result) {
        try {
            rewardedVideoAd?.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading Rewarded ad: ${e.message}", e.toString())
        }
    }

    private fun handleRewardedVideoShowAd(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (rewardedVideoAd == null) {
            result.error("SHOW_FAILED", "Rewarded ad not loaded.", null)
            return
        }
        activity?.let { activity ->
            rewardedVideoAd?.apply {
                if (isReady) {
                    show(activity)
                    result.success(null)
                } else {
                    result.error("-1000", "ad not isLoaded", "Rewarded not loaded")
                }
            }
        }
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}
