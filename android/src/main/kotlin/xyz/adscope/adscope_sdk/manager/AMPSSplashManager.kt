package xyz.adscope.adscope_sdk.manager

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
import xyz.adscope.adscope_sdk.data.SplashBottomModule
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.adscope_sdk.utils.dpToPx
import xyz.adscope.adscope_sdk.view.SplashBottomViewFactory
import xyz.adscope.amps.ad.splash.AMPSSplashAd
import xyz.adscope.amps.ad.splash.AMPSSplashLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.common.v2.gsonlite.Gson

class AMPSSplashManager private constructor() {
    private var mSplashAd: AMPSSplashAd? = null
    companion object {
        @Volatile
        private var instance: AMPSSplashManager? = null

        fun getInstance(): AMPSSplashManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSSplashManager().also { instance = it }
            }
        }
    }

    private val adCallback = object : AMPSSplashLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            sendMessage(AMPSAdCallBackChannelMethod.ON_RENDER_OK)
        }

        override fun onAmpsAdShow() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_SHOW)
        }

        override fun onAmpsAdClicked() {
            cleanupViewsAfterAdClosed()
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLICKED)
        }

        override fun onAmpsAdDismiss() {
            cleanupViewsAfterAdClosed()
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            cleanupViewsAfterAdClosed()
            sendMessage(
                AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf(
                    ErrorModel.CODE to (error?.code?.toInt() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                )
            )
        }

    }


    fun getSplashAd(): AMPSSplashAd? {
        return this.mSplashAd
    }

    /**
     * 清理广告关闭后相关的视图和资源。
     * @param
     */
    private fun cleanupViewsAfterAdClosed() {
        val activity = FlutterPluginUtil.getActivity()
        val contentView = activity?.findViewById<ViewGroup>(android.R.id.content)
        contentView?.findViewWithTag<View>("splash_main_container_tag")?.let { viewToRemove ->
            contentView.removeView(viewToRemove)
        }
        mSplashAd?.destroy()
        mSplashAd = null
        SplashBottomModule.current = null
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            AMPSAdSdkMethodNames.SPLASH_CREATE -> {
                splashAdCreate(call, result)
            }

            AMPSAdSdkMethodNames.SPLASH_LOAD -> handleSplashLoad(result)
            AMPSAdSdkMethodNames.SPLASH_SHOW_AD -> handleSplashShowAd(call, result) // 更改了参数传递
            AMPSAdSdkMethodNames.SPLASH_GET_ECPM -> {
                result.success(mSplashAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.SPLASH_PRE_LOAD -> {
                mSplashAd?.preLoad()
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_ADD_PRE_LOAD_AD_INFO -> {
                mSplashAd?.addPreLoadAdInfo()
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_GET_MEDIA_EXTRA_INFO -> {
                var mediaExtraInfo: String? = null
                if (mSplashAd?.mediaExtraInfo != null) {
                    mediaExtraInfo = Gson().toJson(mSplashAd?.mediaExtraInfo)
                }
                result.success(mediaExtraInfo)
            }

            AMPSAdSdkMethodNames.SPLASH_IS_READY_AD -> {
                result.success(mSplashAd?.isReady ?: false)
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
        val adOptionsMap = call.arguments<Map<String, Any>?>()
        val adOption = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
        try {
            mSplashAd = AMPSSplashAd(activity, adOption, adCallback)
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading splash ad: ${e.message}", e.toString())
        }
    }

    private fun handleSplashLoad(result: Result) {
        mSplashAd?.loadAd()
        result.success(true)
    }

    private fun handleSplashShowAd(call: MethodCall, result: Result) {
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

        try {
            contentView.findViewWithTag<View>("splash_main_container_tag")?.let {
                contentView.removeView(it)
            }
            val mainContainerLocal = RelativeLayout(activity)
            mainContainerLocal.tag = "splash_main_container_tag"
            mainContainerLocal.layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )

            val args = call.arguments<Map<String, Any>?>()
            val splashBottomData = SplashBottomModule.fromMap(args)
            SplashBottomModule.current = splashBottomData // 保持更新静态引用，如果其他地方需要

            // ---- 修改开始 ----
            var customBottomLayoutLocal: View? = null // 初始化为 null
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
            // --- 视图创建和添加结束 ---
            if (mSplashAd?.isReady == true) {
                mSplashAd?.show(adContainerLocal)
                result.success(true)
            } else {
                contentView.removeView(mainContainerLocal)
                result.error("SHOW_FAILED", "Splash ad not ready to be shown.", null)
            }
        } catch (e: Exception) {
            // 捕获创建或显示视图过程中的异常，并尝试清理
            contentView.findViewWithTag<View>("splash_main_container_tag")?.let {
                contentView.removeView(it)
            }
            result.error("SHOW_EXCEPTION", "Error showing splash ad: ${e.message}", e.toString())
        }
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}
