package xyz.adscope.adscope_sdk.manager

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSRewardedVideoCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AdOptionKeys
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.amps.ad.reward.AMPSRewardVideoAd
import xyz.adscope.amps.ad.reward.AMPSRewardVideoLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.config.AMPSRequestParameters
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.concurrent.ConcurrentHashMap

/**
 * 激励视频广告管理器（每个 FlutterEngine 独立持有）
 * 负责处理来自 Flutter 的方法调用
 */
class AMPSRewardedVideoManager(private val engine: AMPSEventManager) {
    private val rewardedVideoAds = ConcurrentHashMap<String, AMPSRewardVideoAd>()
    private val rewardedVideoAdOptions = ConcurrentHashMap<String, AMPSRequestParameters>()

    private fun createAdCallback(instanceId: String) = object : AMPSRewardVideoLoadEventListener {

        override fun onAmpsAdLoad() {
            if (engine.isReleased) return
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_LOAD_SUCCESS)
        }

        override fun onAmpsAdCached() {
            if (engine.isReleased) return
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_CACHED)
        }

        override fun onAmpsAdVideoClick() {
            if (engine.isReleased) return
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdVideoComplete() {
            if (engine.isReleased) return
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_VIDEO_PLAY_END)
        }

        override fun onAmpsAdVideoError() {
            if (engine.isReleased) return
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
            if (engine.isReleased) return
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
            if (engine.isReleased) return
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdDismiss() {
            if (engine.isReleased) return
            sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(p0: AMPSError?) {
            if (engine.isReleased) return
            sendMessage(
                instanceId,
                AMPSRewardedVideoCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (p0?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to p0?.message
                )
            )
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun argsAsMap(call: MethodCall): Map<String, Any>? = call.arguments as? Map<String, Any>
    private fun instanceIdFrom(call: MethodCall): String? = argsAsMap(call)?.get(AD_INSTANCE_ID) as? String

    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.REWARDED_VIDEO_CREATE -> createAd(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_LOAD -> handleRewardedVideoLoad(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_PRE_LOAD -> {
                rewardedVideoAds[instanceIdFrom(call)]?.preLoad()
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_SHOW_AD -> handleRewardedVideoShowAd(call, result)
            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_ECPM -> {
                result.success(rewardedVideoAds[instanceIdFrom(call)]?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_SEAT_ID -> {
                result.success(rewardedVideoAds[instanceIdFrom(call)]?.seatId)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_IS_READY_AD -> {
                result.success(rewardedVideoAds[instanceIdFrom(call)]?.isReady)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_DESTROY_AD -> {
                val instanceId = instanceIdFrom(call)
                if (instanceId != null) {
                    rewardedVideoAds.remove(instanceId)?.destroy()
                    rewardedVideoAdOptions.remove(instanceId)
                }
                result.success(null)
            }

            AMPSAdSdkMethodNames.REWARDED_VIDEO_SET_EXTRA_DATA_MAP -> {
                handleSetExtraDataMap(call, result)
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
        val activity = engine.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading splash ad.", null)
            return
        }
        val adOptionsMap = argsAsMap(call)
        val instanceId = adOptionsMap?.get(AD_INSTANCE_ID) as? String
        if (instanceId.isNullOrEmpty()) {
            result.error("LOAD_FAILED", "adInstanceId missing", null)
            return
        }
        val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
        rewardedVideoAdOptions[instanceId] = adOption
        rewardedVideoAds[instanceId] = AMPSRewardVideoAd(activity, adOption, createAdCallback(instanceId))
        result.success(null)
    }

    private fun handleSetExtraDataMap(call: MethodCall, result: Result) {
        val instanceId = instanceIdFrom(call)
        if (instanceId.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "adInstanceId missing", null)
            return
        }
        val adOption = rewardedVideoAdOptions[instanceId]
        if (adOption == null) {
            result.error("UPDATE_FAILED", "Reward ad instance not found", instanceId)
            return
        }
        val extraDataMap = toStringMap(argsAsMap(call)?.get(AdOptionKeys.KEY_EXTRA_DATA_MAP))
        adOption.extraDataMap = extraDataMap
        result.success(null)
    }

    private fun toStringMap(raw: Any?): HashMap<String, String>? {
        val map = raw as? Map<*, *> ?: return null
        val result = HashMap<String, String>()
        for ((key, value) in map) {
            if (key != null && value != null) {
                result[key.toString()] = value.toString()
            }
        }
        return result
    }

    private fun handleRewardedVideoLoad(call: MethodCall, result: Result) {
        try {
            rewardedVideoAds[instanceIdFrom(call)]?.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading Rewarded ad: ${e.message}", e.toString())
        }
    }

    private fun handleRewardedVideoShowAd(call: MethodCall, result: Result) {
        val activity = engine.getActivity()
        val rewardedVideoAd = rewardedVideoAds[instanceIdFrom(call)]
        if (rewardedVideoAd == null) {
            result.error("SHOW_FAILED", "Rewarded ad not loaded.", null)
            return
        }
        if (activity == null) {
            result.error("SHOW_FAILED", "Activity not available for showing rewarded ad.", null)
            return
        }
        if (rewardedVideoAd.isReady) {
            rewardedVideoAd.show(activity)
            result.success(null)
        } else {
            result.error("-1000", "ad not isLoaded", "Rewarded not loaded")
        }
    }

    private fun sendMessage(instanceId: String, method: String, args: Any? = null) {
        val payload = mutableMapOf<String, Any?>(AD_INSTANCE_ID to instanceId)
        if (args is Map<*, *>) {
            @Suppress("UNCHECKED_CAST")
            payload.putAll(args as Map<String, Any?>)
        } else if (args != null) {
            payload["data"] = args
        }
        engine.sendMessageToFlutter(method, payload)
    }

    fun release() {
        rewardedVideoAds.values.toList().forEach { runCatching { it.destroy() } }
        rewardedVideoAds.clear()
        rewardedVideoAdOptions.clear()
    }
}
