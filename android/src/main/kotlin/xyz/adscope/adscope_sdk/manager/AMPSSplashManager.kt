package xyz.adscope.adscope_sdk.manager

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import xyz.adscope.adscope_sdk.view.SplashBottomViewFactory
import xyz.adscope.adscope_sdk.utils.dpToPx
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AD_LOSS_REASON
import xyz.adscope.adscope_sdk.data.AD_SEC_PRICE
import xyz.adscope.adscope_sdk.data.AD_WIN_PRICE
import xyz.adscope.adscope_sdk.data.AMPSAdCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AdOptionsModule
import xyz.adscope.adscope_sdk.data.SplashBottomModule
import xyz.adscope.adscope_sdk.data.StringConstants
import xyz.adscope.amps.ad.splash.AMPSSplashAd
import xyz.adscope.amps.ad.splash.AMPSSplashLoadEventListener
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.config.AMPSRequestParameters
import java.lang.ref.WeakReference

class AMPSSplashManager private constructor() {
    private var mSplashAd: AMPSSplashAd? = null
    private var currentActivityRef: WeakReference<Activity>? =
        WeakReference(AMPSEventManager.getInstance().getContext())

    companion object {
        @Volatile
        private var instance: AMPSSplashManager? = null

        fun getInstance(): AMPSSplashManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSSplashManager().also { instance = it }
            }
        }
    }

    private fun getCurrentActivity(): Activity? = currentActivityRef?.get()

    private val adCallback = object : AMPSSplashLoadEventListener {
        override fun onAmpsAdLoaded() {
            sendMessage(AMPSAdCallBackChannelMethod.ON_LOAD_SUCCESS)
            // 在旧代码中，这里也有 ON_RENDER_OK，如果 SDK 行为如此，则保留
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
            cleanupViewsAfterAdClosed() // false表示非点击关闭
            sendMessage(AMPSAdCallBackChannelMethod.ON_AD_CLOSED)
        }

        override fun onAmpsAdFailed(error: AMPSError?) {
            sendMessage(
                AMPSAdCallBackChannelMethod.ON_LOAD_FAILURE,
                mapOf("code" to error?.code, "message" to error?.message)
            )
        }

    }

    /**
     * 清理广告关闭后相关的视图和资源。
     * @param
     */
    private fun cleanupViewsAfterAdClosed() {
        val activity = getCurrentActivity()
        val decorView = activity?.window?.decorView as? ViewGroup
        decorView?.findViewWithTag<View>("splash_main_container_tag")?.let { viewToRemove ->
            decorView.removeView(viewToRemove)
        }

        mSplashAd = null
        SplashBottomModule.current = null
    }

    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        val args = call.arguments<Map<String, Any>?>()
        when (call.method) {
            AMPSAdSdkMethodNames.SPLASH_LOAD -> handleSplashLoad(call, result)
            AMPSAdSdkMethodNames.SPLASH_SHOW_AD -> handleSplashShowAd(call, result) // 更改了参数传递
            AMPSAdSdkMethodNames.SPLASH_GET_ECPM -> {
                result.success(mSplashAd?.ecpm ?: 0)
            }

            AMPSAdSdkMethodNames.SPLASH_NOTIFY_RTB_WIN -> {
                val winPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val secPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                //mSplashAd?.notifyRTBWin(winPrice.toInt(), secPrice.toInt())
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_NOTIFY_RTB_LOSS -> {
                val lossWinPrice = args?.get(AD_WIN_PRICE) as? Number ?: 0
                val lossSecPrice = args?.get(AD_SEC_PRICE) as? Number ?: 0
                val lossReason =
                    args?.get(AD_LOSS_REASON) as? String ?: StringConstants.EMPTY_STRING
                //mSplashAd?.notifyRTBLoss(lossWinPrice.toInt(), lossSecPrice.toInt(), lossReason)
                result.success(null)
            }

            AMPSAdSdkMethodNames.SPLASH_IS_READY_AD -> {
                result.success(mSplashAd?.isReady ?: false)
            }

            else -> result.notImplemented()
        }
    }

    private fun handleSplashLoad(call: MethodCall, result: Result) {
        val activity = getCurrentActivity()
        if (activity == null) {
            result.error("LOAD_FAILED", "Activity not available for loading splash ad.", null)
            return
        }

        try {
            val adOptionsMap = call.arguments<Map<String, Any>?>()
            val adOption: AMPSRequestParameters = AdOptionsModule.getAdOptionFromMap(adOptionsMap, activity)
            mSplashAd = AMPSSplashAd(activity, adOption, adCallback)
            mSplashAd?.loadAd()
            result.success(true)
        } catch (e: Exception) {
            result.error("LOAD_EXCEPTION", "Error loading splash ad: ${e.message}", e.toString())
        }
    }

    // handleSplashShowAd 现在也接收 MethodCall 和 Result，以便统一错误处理和参数获取
    private fun handleSplashShowAd(call: MethodCall, result: Result) {
        val activity = getCurrentActivity()
        if (mSplashAd == null) {
            result.error("SHOW_FAILED", "Splash ad not loaded.", null)
            return
        }
        if (activity == null) {
            result.error("SHOW_FAILED", "Activity not available for showing splash ad.", null)
            return
        }

        val decorView = activity.window.decorView as? ViewGroup
        if (decorView == null) {
            result.error("SHOW_FAILED", "Could not get decorView to show ad.", null)
            return
        }

        try {
            // --- 动态创建视图，不作为成员变量 ---
            decorView.findViewWithTag<View>("splash_main_container_tag")?.let {
                decorView.removeView(it)
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
            if (splashBottomData!=null && splashBottomData.height > 0) {
                customBottomLayoutLocal = SplashBottomViewFactory.createSplashBottomLayout(activity, splashBottomData)

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
                } else {
                    println("AMPSSplashManager: SplashBottomViewFactory returned null, no bottom view will be added.")
                }
            } else {
                println("AMPSSplashManager: SplashBottomData not initialized or height is 0, no bottom view will be added.")
            }
            // ---- 修改结束 ----
            val adContainerLocal = FrameLayout(activity)
            val adContainerParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.MATCH_PARENT,
                RelativeLayout.LayoutParams.MATCH_PARENT
            )
            // 如果 customBottomLayoutLocal 被成功创建并添加到 mainContainerLocal，
            // 并且它有一个有效的 ID，则将广告容器置于其上方。
            if (customBottomLayoutLocal != null && customBottomLayoutLocal.parent == mainContainerLocal && customBottomLayoutId != View.NO_ID) {
                adContainerParams.addRule(RelativeLayout.ABOVE, customBottomLayoutId)
            }
            // 否则 (没有底部视图或底部视图无效)，adContainer 将默认填充整个 mainContainerLocal (因为宽高都是 MATCH_PARENT)
            adContainerLocal.layoutParams = adContainerParams
            mainContainerLocal.addView(adContainerLocal) // 再添加广告容器

            decorView.addView(mainContainerLocal)
            // --- 视图创建和添加结束 ---
            if (mSplashAd?.isReady == true) {
                mSplashAd?.show(adContainerLocal)
                result.success(true)
            } else {
                decorView.removeView(mainContainerLocal)
                result.error("SHOW_FAILED", "Splash ad not ready to be shown.", null)
            }
        } catch (e: Exception) {
            // 捕获创建或显示视图过程中的异常，并尝试清理
            decorView.findViewWithTag<View>("splash_main_container_tag")?.let {
                decorView.removeView(it)
            }
            result.error("SHOW_EXCEPTION", "Error showing splash ad: ${e.message}", e.toString())
        }
    }

    private fun sendMessage(method: String, args: Any? = null) {
        AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
    }
}
