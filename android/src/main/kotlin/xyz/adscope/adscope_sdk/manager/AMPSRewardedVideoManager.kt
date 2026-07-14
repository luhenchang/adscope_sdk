package xyz.adscope.adscope_sdk.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSRewardedVideoCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.reward.AMPSRewardVideoAd
import xyz.adscope.amps.ad.reward.AMPSRewardVideoLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.concurrent.ConcurrentHashMap

/**
 * 插屏广告管理器 (单例)
 * 负责处理来自 Flutter 的方法调用
 */
class AMPSRewardedVideoManager private constructor() {
    private val rewardedVideoAds = ConcurrentHashMap<String, AMPSRewardVideoAd>()

    companion object {
        @Volatile
        private var instance: AMPSRewardedVideoManager? = null

        fun getInstance(): AMPSRewardedVideoManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSRewardedVideoManager().also { instance = it }
            }
        }
    }


    private fun createAdCallback(instanceId: String) = object : AMPSRewardVideoLoadEventListener {

        override fun onAmpsAdLoad() {
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_LOAD_SUCCESS)
        }

        override fun onAmpsAdCached() {
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_CACHED)
        }

        override fun onAmpsAdVideoClick() {
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdVideoComplete() {
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_VIDEO_PLAY_END)
        }

        override fun onAmpsAdVideoError() {
            sendMessage(
                instanceId,
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
                instanceId,
                AMPSRewardedVideoCallBackChannelMethod.ON_AD_REWARD,
                mapOf(
                    "isRewardValid" to isRewardValid,
                    "rewardType" to rewardType,
                    "extraInfo" to extraInfo
                )
            )
        }

        override fun onAmpsAdShow() {
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdDismiss() {
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            // code 可能非数字、message 可能为 null，必须做安全兜底，否则异常会导致 Flutter 收不到失败回调
            val code = try {
                p0?.code?.toInt() ?: -1
            } catch (e: Exception) {
                -1
            }
            sendMessage(
                instanceId,
                AMPSRewardedVideoCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to code,
                    ErrorModel.MESSAGE to (p0?.message ?: "load failed")
                )
            )
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
                result.error("REWARD_EXCEPTION", "Error handling ${call.method}: ${e.message}", e.toString())
            } catch (ignored: Exception) {
                // result 已被回调过，忽略二次回调异常
            }
        }
    }

    private fun handleMethodCallInternal(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.REWARDED_VIDEO_CREATE -> createAd(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_LOAD -> handleRewardedVideoLoad(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_PRE_LOAD -> {
                val rewardedVideoAd = rewardedVideoAds[instanceIdFrom(call)]
                if (rewardedVideoAd == null) {
                    // 实例不存在必须显式报错，避免 Dart 端误以为预加载成功
                    result.error("PRELOAD_FAILED", "Rewarded ad instance not found, create may have failed.", null)
                } else {
                    rewardedVideoAd.preLoad()
                    result.success(null)
                }
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_SHOW_AD -> handleRewardedVideoShowAd(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_ECPM -> {
                result.success(rewardedVideoAds[instanceIdFrom(call)]?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_SEAT_ID -> {
                result.success(rewardedVideoAds[instanceIdFrom(call)]?.seatId)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_IS_READY_AD -> {
                // isReady 为 null 时返回 false，避免 Dart 端 Future<bool> 收到 null 抛类型异常
                result.success(rewardedVideoAds[instanceIdFrom(call)]?.isReady ?: false)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_DESTROY_AD -> {
                val instanceId = instanceIdFrom(call)
                if (instanceId != null) {
                    rewardedVideoAds.remove(instanceId)?.destroy()
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_ADD_PRE_LOAD_AD_INFO -> {
                rewardedVideoAds[instanceIdFrom(call)]?.addPreLoadAdInfo()
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                val ad = rewardedVideoAds[instanceIdFrom(call)]
                if (ad?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(ad.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
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
            result.error("CREATE_FAILED", "Activity not available for creating rewarded ad.", null)
            return
        }
        val adOptionsMap = argsAsMap(call)
        val instanceId = adOptionsMap?.get(AD_INSTANCE_ID) as? String
        if (instanceId.isNullOrEmpty()) {
            result.error("CREATE_FAILED", "adInstanceId missing", null)
            return
        }
        try {
            val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
            rewardedVideoAds[instanceId] = AMPSRewardVideoAd(activity, adOption, createAdCallback(instanceId))
            result.success(null)
        } catch (e: Exception) {
            // 创建异常必须回调 error，Dart 端会转为 onLoadFailure 通知业务方
            result.error("CREATE_EXCEPTION", "Error creating Rewarded ad: ${e.message}", e.toString())
        }
    }

    private fun handleRewardedVideoLoad(call: MethodCall, result: Result) {
        try {
            val rewardedVideoAd = rewardedVideoAds[instanceIdFrom(call)]
            if (rewardedVideoAd == null) {
                // 实例不存在（create 失败或已销毁），必须显式报错，避免静默失败
                result.error("LOAD_FAILED", "Rewarded ad instance not found, create may have failed.", null)
                return
            }
            rewardedVideoAd.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading Rewarded ad: ${e.message}", e.toString())
        }
    }

    private fun handleRewardedVideoShowAd(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        val rewardedVideoAd = rewardedVideoAds[instanceIdFrom(call)]
        if (rewardedVideoAd == null) {
            result.error("SHOW_FAILED", "Rewarded ad not loaded.", null)
            return
        }
        if (activity == null) {
            // activity 为空时也必须回调 result，否则 Flutter 侧 Future 永远不会完成
            result.error("SHOW_FAILED", "Activity not available for showing rewarded ad.", null)
            return
        }
        try {
            rewardedVideoAd.apply {
                if (isReady) {
                    show(activity)
                    result.success(null)
                } else {
                    result.error("-1000", "ad not isLoaded", "Rewarded not loaded")
                }
            }
        } catch (e: Exception) {
            // show 过程异常必须回调 error，否则 Flutter 侧 Future 永远挂起且收不到任何消息
            result.error("SHOW_EXCEPTION", "Error showing Rewarded ad: ${e.message}", e.toString())
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
