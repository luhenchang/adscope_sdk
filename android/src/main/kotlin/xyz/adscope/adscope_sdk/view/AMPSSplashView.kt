package xyz.adscope.adscope_sdk.view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import xyz.adscope.adscope_sdk.data.AMPSAdCallBackChannelMethod
import xyz.adscope.adscope_sdk.data.SPLASH_BOTTOM
import xyz.adscope.adscope_sdk.data.SplashBottomModule
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AMPSSplashManager
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
    private var rootPlatformView: ViewGroup

    // 广告容器
    private val adContainerInPlatformView: FrameLayout = FrameLayout(context)


    init {
        val creationArgsMap = args as? Map<*, *>?
        //1. 首先，从 Manager 获取已经加载好的广告实例
        mSplashAd = AMPSSplashManager.getInstance().getSplashAd()
        if (mSplashAd?.isReady == true) {
            // 2. 解析底部视图数据
            val splashBottomData =
                creationArgsMap?.get(SPLASH_BOTTOM)
                    ?.let { SplashBottomModule.fromMap(it as? Map<String, Any>?) }

            // 3. 根据有无底部数据，构建根视图
            rootPlatformView = if (splashBottomData != null) {
                // 如果有数据，setupViews 会返回一个包含广告容器和底部视图的 RelativeLayout
                setupViews(splashBottomData)
            } else {
                // 如果没有数据，根视图就是广告容器本身
                adContainerInPlatformView
            }

            // 4. 【关键】在专门的广告容器中显示广告，而不是在根视图中
            mSplashAd?.show(adContainerInPlatformView)
        } else {
            rootPlatformView = FrameLayout(context).apply {
                layoutParams = ViewGroup.LayoutParams(0, 0)
            }
            AMPSEventManager.getInstance().sendMessageToFlutter(
                AMPSAdCallBackChannelMethod.ON_AD_CLOSED,null)
        }

    }

    /**
     * 根据参数构建根视图 (rootPlatformView) 的层级结构。
     */
    private fun setupViews(splashBottomData: SplashBottomModule): ViewGroup {
        SplashBottomModule.current = splashBottomData // 如需全局访问，则更新
        // 尝试创建底部自定义视图
        customBottomLayoutView = splashBottomData.takeIf { it.height > 0 }?.let { data ->
            SplashBottomViewFactory.createSplashBottomLayout(context, data)?.apply {
                id = View.generateViewId()
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
        // 1. 销毁广告实例，这是最重要的
        mSplashAd?.destroy()
        mSplashAd = null
        // 2. 清理视图层级，防止内存泄漏
        // adContainerInPlatformView 内部的子视图是广告SDK添加的，removeAllViews 是好的
        adContainerInPlatformView.removeAllViews()
        // 如果根视图是 RelativeLayout，需要将子视图移除
        rootPlatformView.removeAllViews()
        SplashBottomModule.current = null
    }

    override fun getView(): View = rootPlatformView

    override fun dispose() {
        cleanupAdResources()
    }
}
