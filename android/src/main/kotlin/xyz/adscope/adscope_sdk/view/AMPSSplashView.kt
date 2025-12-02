package xyz.adscope.adscope_sdk.view

import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import xyz.adscope.adscope_sdk.data.SPLASH_BOTTOM
import xyz.adscope.adscope_sdk.data.SplashBottomModule
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AMPSSplashManager
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.ad.splash.AMPSSplashAd

class AMPSSplashView(
    private val context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger,
    args: Any?
) : PlatformView {

    private var mSplashAd: AMPSSplashAd? = null
    private var customBottomLayoutView: View? = null

    // 根视图，根据逻辑动态构建
    private val rootPlatformView: ViewGroup

    // 广告容器
    private val adContainerInPlatformView: FrameLayout = FrameLayout(context)


    init {
        val creationArgsMap = args as? Map<*, *>?
        var activity = FlutterPluginUtil.getActivity()
        if (activity == null) {
            activity = context as Activity
        }
        val splashBottomData =
            creationArgsMap?.get(SPLASH_BOTTOM)
                ?.let { SplashBottomModule.fromMap(it as? Map<String, Any>?) }
        if (splashBottomData == null) {
            rootPlatformView = adContainerInPlatformView
        } else {
            rootPlatformView = setupViews(splashBottomData)
            mSplashAd = AMPSSplashManager.getInstance().getSplashAd()
        }
        mSplashAd?.show(adContainerInPlatformView)
    }

    /**
     * 根据参数构建根视图 (rootPlatformView) 的层级结构。
     */
    private fun setupViews(splashBottomData: SplashBottomModule): ViewGroup {
        SplashBottomModule.current = splashBottomData // 如需全局访问，则更新
        // 尝试创建底部自定义视图
        customBottomLayoutView = splashBottomData?.takeIf { it.height > 0 }?.let { data ->
            SplashBottomViewFactory.createSplashBottomLayout(context, data)?.apply {
                id = View.generateViewId()
                visibility = View.GONE // 初始隐藏
                layoutParams = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    (data.height * context.resources.displayMetrics.density).toInt()
                ).apply {
                    addRule(RelativeLayout.ALIGN_PARENT_BOTTOM)
                }
            }
        }

        // 如果成功创建了底部视图，则使用 RelativeLayout 作为根布局
        return customBottomLayoutView?.let { bottomView ->
            RelativeLayout(context).apply {
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
                )

                // 设置广告容器，使其位于底部视图之上
                adContainerInPlatformView.layoutParams = RelativeLayout.LayoutParams(
                    RelativeLayout.LayoutParams.MATCH_PARENT,
                    RelativeLayout.LayoutParams.MATCH_PARENT
                ).apply {
                    addRule(RelativeLayout.ABOVE, bottomView.id)
                }

                addView(adContainerInPlatformView)
                addView(bottomView)
            }
        } ?: adContainerInPlatformView
    }

    /**
     * 清理广告相关资源，用于 onDismiss 和 dispose。
     */
    private fun cleanupAdResources() {
        adContainerInPlatformView.removeAllViews()
        mSplashAd?.destroy()
        mSplashAd = null
    }

    override fun getView(): View = rootPlatformView

    override fun dispose() {
        cleanupAdResources()
        SplashBottomModule.current = null
    }
}
