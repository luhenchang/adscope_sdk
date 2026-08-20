package xyz.adscope.adscope_sdk.manager

import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AMPSAdCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.data.SPLASH_BOTTOM
import xyz.adscope.adscope_sdk.data.SPLASH_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.SplashBottomModule
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.adscope_sdk.utils.dpToPx
import xyz.adscope.adscope_sdk.view.SplashBottomViewFactory
import xyz.adscope.amps.ad.splash.AMPSSplashAd
import xyz.adscope.amps.ad.splash.AMPSSplashLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.common.v2.gsonlite.Gson
import java.util.concurrent.ConcurrentHashMap

class AMPSSplashManager private constructor() {
    private val splashAds = ConcurrentHashMap<String, AMPSSplashAd>()
    private val splashBottomModules = ConcurrentHashMap<String, SplashBottomModule>()

    companion object {
        @Volatile
        private var instance: AMPSSplashManager? = null

        fun getInstance(): AMPSSplashManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSSplashManager().also { instance = it }
            }
        }
    }

    private fun containerTag(instanceId: String) = "splash_main_container_tag_$instanceId"

    private fun createAdCallback(instanceId: String) = object : AMPSSplashLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(instanceId, AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            sendMessage(instanceId, AMPSAdCallBackChannelMethod.ON_RENDER_OK)
        }

        override fun onAmpsAdShow() {
            sendMessage(instanceId, AMPSAdCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            sendMessage(instanceId, AMPSAdCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            cleanupViewsAfterAdClosed(instanceId)
            splashBottomModules.remove(instanceId)
            sendMessage(instanceId, AMPSAdCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            cleanupViewsAfterAdClosed(instanceId)
            sendMessage(
                instanceId,
                AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }
    }

    fun getSplashAd(instanceId: String? = null): AMPSSplashAd? {
        if (instanceId != null) {
            return splashAds[instanceId]
        }
        return splashAds.values.lastOrNull()
    }

    private fun extractInstanceId(args: Map<String, Any>?): String? {
        return args?.get(SPLASH_INSTANCE_ID) as? String
    }

    @Suppress("UNCHECKED_CAST")
    private fun argsAsMap(call: MethodCall): Map<String, Any>? {
        return call.arguments as? Map<String, Any>
    }

    private fun resolveBottomMap(args: Map<String, Any>?): Map<String, Any>? {
        if (args == null) return null
        val nested = args[SPLASH_BOTTOM] as? Map<String, Any>
        if (nested != null) return nested
        return if (args["type"] == "parent") args else null
    }

    private fun cleanupViewsAfterAdClosed(instanceId: String) {
        val activity = FlutterPluginUtil.getActivity()
        val contentView = activity?.findViewById<ViewGroup>(android.R.id.content)
        contentView?.findViewWithTag<View>(containerTag(instanceId))?.let { viewToRemove ->
            contentView.removeView(viewToRemove)
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        val args = argsAsMap(call)
        val instanceId = extractInstanceId(args)
        when (call.method) {
            AMPSAdSdkMethodNames.SPLASH_CREATE -> {
                splashAdCreate(call, result)
            }

            AMPSAdSdkMethodNames.SPLASH_LOAD -> {
                if (instanceId == null) {
                    result.error("INVALID_ARGS", "splashInstanceId is required", null)
                    return
                }
                handleSplashLoad(instanceId, result)
            }

            AMPSAdSdkMethodNames.SPLASH_SHOW_AD -> {
                if (instanceId == null) {
                    result.error("INVALID_ARGS", "splashInstanceId is required", null)
                    return
                }
                handleSplashShowAd(instanceId, call, result)
            }

            AMPSAdSdkMethodNames.SPLASH_GET_ECPM -> {
                result.success(splashAds[instanceId]?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.SPLASH_GET_SEAT_ID -> {
                result.success(splashAds[instanceId]?.seatId)
            }

            AMPSAdSdkMethodNames.SPLASH_PRE_LOAD -> {
                splashAds[instanceId]?.preLoad()
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_ADD_PRE_LOAD_AD_INFO -> {
                splashAds[instanceId]?.addPreLoadAdInfo()
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                val ad = splashAds[instanceId]
                if (ad?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(ad.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
            }

            AMPSAdSdkMethodNames.SPLASH_IS_READY_AD -> {
                result.success(splashAds[instanceId]?.isReady ?: false)
            }

            AMPSAdSdkMethodNames.SPLASH_DESTROY -> {
                if (instanceId != null) {
                    splashAds.remove(instanceId)?.destroy()
                    splashBottomModules.remove(instanceId)
                    cleanupViewsAfterAdClosed(instanceId)
                }
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun splashAdCreate(call: MethodCall, result: Result) {
        val activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading splash ad.", null)
            return
        }
        val adOptionsMap = argsAsMap(call)
        val instanceId = extractInstanceId(adOptionsMap)
        if (instanceId.isNullOrEmpty()) {
            result.error("INVALID_ARGS", "splashInstanceId is required", null)
            return
        }
        val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
        SplashBottomModule.fromMap(resolveBottomMap(adOptionsMap))?.let { module ->
            if (module.initialized && module.height > 0) {
                splashBottomModules[instanceId] = module
            } else {
                splashBottomModules.remove(instanceId)
            }
        } ?: splashBottomModules.remove(instanceId)
        try {
            splashAds[instanceId] = AMPSSplashAd(activity, adOption, createAdCallback(instanceId))
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading splash ad: ${e.message}", e.toString())
        }
    }

    private fun handleSplashLoad(instanceId: String, result: Result) {
        val ad = splashAds[instanceId]
        if (ad == null) {
            result.error("LOAD_FAILED", "Splash ad instance not found: $instanceId", null)
            return
        }
        ad.loadAd()
        result.success(true)
    }

    private fun handleSplashShowAd(instanceId: String, call: MethodCall, result: Result) {
        val mSplashAd = splashAds[instanceId]
        val activity = FlutterPluginUtil.getActivity()
        if (mSplashAd == null) {
            result.error("SHOW_FAILED", "Splash ad not loaded.", null)
            return
        }
        if (activity == null) {
            result.error("SHOW_FAILED", "Activity not available for showing splash ad.", null)
            return
        }

        val contentView = activity.findViewById<ViewGroup>(android.R.id.content)
        if (contentView == null) {
            result.error("SHOW_FAILED", "Could not get contentView to show ad.", null)
            return
        }

        val tag = containerTag(instanceId)
        try {
            contentView.findViewWithTag<View>(tag)?.let {
                contentView.removeView(it)
            }
            val mainContainerLocal = RelativeLayout(activity)
            mainContainerLocal.tag = tag
            mainContainerLocal.layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )

            val splashBottomData = splashBottomModules[instanceId]

            var customBottomLayoutLocal: View? = null
            var customBottomLayoutId: Int = View.NO_ID

            // 条件：仅当 splashBottomData 初始化成功并且高度大于0时，才创建和添加底部视图
            if (splashBottomData != null && splashBottomData.height > 0) {
                customBottomLayoutLocal =
                    SplashBottomViewFactory.createSplashBottomLayout(activity, splashBottomData)

                // 额外的安全检查，确保工厂方法确实返回了一个视图
                if (customBottomLayoutLocal != null) {
                    val bottomLp = RelativeLayout.LayoutParams(
                        RelativeLayout.LayoutParams.MATCH_PARENT,
                        splashBottomData.height.dpToPx(activity)
                    )
                    bottomLp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                    customBottomLayoutLocal.layoutParams = bottomLp
                    customBottomLayoutLocal.id = View.generateViewId()
                    customBottomLayoutId = customBottomLayoutLocal.id

                    mainContainerLocal.addView(customBottomLayoutLocal) // 先添加底部自定义视图
                }
            }
            val adContainerLocal = FrameLayout(activity)
            val adContainerParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
            if (customBottomLayoutLocal != null && customBottomLayoutLocal.parent == mainContainerLocal && customBottomLayoutId != View.NO_ID) {
                adContainerParams.addRule(RelativeLayout.ABOVE, customBottomLayoutId)
            }
            adContainerLocal.layoutParams = adContainerParams
            mainContainerLocal.addView(adContainerLocal)
            contentView.addView(mainContainerLocal)
            if (mSplashAd.isReady) {
                mSplashAd.show(adContainerLocal)
                result.success(true)
            } else {
                contentView.removeView(mainContainerLocal)
                result.error("SHOW_FAILED", "Splash ad not ready to be shown.", null)
            }
        } catch (e: Exception) {
            contentView.findViewWithTag<View>(tag)?.let {
                contentView.removeView(it)
            }
            result.error("SHOW_EXCEPTION", "Error showing splash ad: ${e.message}", e.toString())
        }
    }

    private fun sendMessage(instanceId: String, method: String, args: Any? = null) {
        val payload: MutableMap<String, Any?> = mutableMapOf(SPLASH_INSTANCE_ID to instanceId)
        when (args) {
            null -> Unit
            is Map<*, *> -> {
                @Suppress("UNCHECKED_CAST")
                payload.putAll(args as Map<String, Any?>)
            }
            else -> payload["data"] = args
        }
        AMPSEventManager.getInstance().sendMessageToFlutter(method, payload)
    }
}
