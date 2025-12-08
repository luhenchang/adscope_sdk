package xyz.adscope.adscope_sdk.view

import android.content.Context
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import xyz.adscope.adscope_sdk.data.AD_ID
import xyz.adscope.adscope_sdk.data.NATIVE_WIDTH
import xyz.adscope.adscope_sdk.data.NativeUnifiedModule
import xyz.adscope.adscope_sdk.manager.AdUnifiedWrapperManager
import xyz.adscope.adscope_sdk.manager.AdWrapperManager
import xyz.adscope.adscope_sdk.utils.asActivity
import xyz.adscope.adscope_sdk.utils.dpToPx
import xyz.adscope.amps.ad.unified.view.AMPSUnifiedRootContainer

private const val TAG = "AMPSUnifiedView"
private const val UNIFIED_WIDGET_KEY = "unifiedWidget"

class AMPSUnifiedView(
    private val context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger,
    args: Any?
) : PlatformView {
    // 但由于构造函数中需要对 rootView 进行 addView，因此保留非延迟初始化
    private val unifiedView = FrameLayout(context).apply {
        layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.WRAP_CONTENT
        )
    }

    private val adId: String?
    private val unifiedModule: NativeUnifiedModule?
    private val rootView: FrameLayout

    init {
        // 1. 参数解析
        val creationArgs = parseCreationArgs(args)
        adId = creationArgs[AD_ID] as? String
        @Suppress("UNCHECKED_CAST")
        val unifiedMap = creationArgs[UNIFIED_WIDGET_KEY] as? Map<String, Any>

        // 2. 提前进行必要的数据检查
        if (unifiedMap == null) {
            Log.e(TAG, "Initialization failed: 'unifiedWidget' map is missing or invalid.")
            unifiedModule = null
            rootView = createEmptyRootView() // 创建一个空的或占位的 rootView
        } else {
            unifiedModule = NativeUnifiedModule(unifiedMap)
            // 3. 根视图创建
            val wrapper = AdUnifiedWrapperManager.getInstance().getAdItem(adId ?: "")
            if (wrapper?.isValid == false) {
                Log.e(TAG, "Initialization failed: 'adId' is missing or invalid.")
                rootView = createEmptyRootView()
            }else {
                if (wrapper?.isExpressAd == false) {
                    rootView = createRootView(unifiedMap)
                    unifiedView.addView(rootView)
                    // 4. 加载广告
                    addAdViewToRoot()
                } else {
                    rootView = createExpressRootView(unifiedMap)
                    unifiedView.addView(rootView)
                    AdWrapperManager.getInstance().getAdView(adId ?: "")?.let { adView ->
                        adView.layoutParams = rootView.tag as? FrameLayout.LayoutParams
                        rootView.addView(adView)
                    }
                }
            }

        }
    }

    /**
     * 解析从 Flutter 传递过来的初始化参数。
     */
    @Suppress("UNCHECKED_CAST")
    private fun parseCreationArgs(args: Any?): Map<String, Any> {
        return args as? Map<String, Any> ?: emptyMap()
    }

    /**
     * 创建一个空的或占位的根视图，用于错误处理场景。
     */
    private fun createEmptyRootView(): AMPSUnifiedRootContainer {
        return AMPSUnifiedRootContainer(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                1
            )
        }
    }

    /**
     * 创建根视图 AMPSUnifiedRootContainer 并设置其基本布局。
     */
    private fun createRootView(args: Map<*, *>): AMPSUnifiedRootContainer {
        val nativeWidthDp = args[NATIVE_WIDTH] as? Double
        val adViewWidthPx = nativeWidthDp?.dpToPx(context)
            ?: FrameLayout.LayoutParams.MATCH_PARENT

        return AMPSUnifiedRootContainer(context).apply {
            val containerLayout = FrameLayout.LayoutParams(
                adViewWidthPx,
                FrameLayout.LayoutParams.MATCH_PARENT
            ).apply {
                gravity = Gravity.CENTER_HORIZONTAL
            }
            layoutParams = containerLayout
            val adViewParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ).apply {
                gravity = Gravity.CENTER
            }
            tag = adViewParams // tag 的类型改为 FrameLayout.LayoutParams，避免后续强制转换失败
        }
    }

    /**
     * 创建根视图 FrameLayout 并设置其基本布局
     */
    private fun createExpressRootView(args: Map<*, *>): FrameLayout {
        val nativeWidth = args[NATIVE_WIDTH] as? Double

        return FrameLayout(context).apply {
            // FrameLayout 本身填充父容器
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )

            val adViewWidth = nativeWidth?.toInt()?.dpToPx(context)
                ?: FrameLayout.LayoutParams.MATCH_PARENT // 默认填充宽度

            val adViewParams = FrameLayout.LayoutParams(
                adViewWidth,
                FrameLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
            tag = adViewParams
        }
    }
    /**
     * 获取广告视图并添加到根视图中。
     * 优化点：使用 Elvis 运算符和 'let' 链式调用简化空值检查。
     */
    private fun addAdViewToRoot() {
        val currentAdId = adId ?: return
        val module = unifiedModule ?: return
        val adItem = AdUnifiedWrapperManager.getInstance().getAdItem(currentAdId) ?: return

        // 确保 tag 是正确的 FrameLayout.LayoutParams 类型
        val params = rootView.tag as? FrameLayout.LayoutParams ?: run {
            Log.e(TAG, "Layout params not found in rootView tag for adId: $currentAdId")
            return
        }

        runCatching {
            // 使用 let 避免嵌套，同时确保 nativeView 渲染成功
            AmpsUnifiedFrameLayout(context).let { it ->
                it.render(module, adItem, params, currentAdId)?.let { renderResult ->
                    rootView.addView(it)
                    adItem.bindAdToRootContainer(
                        context.asActivity(),
                        rootView as AMPSUnifiedRootContainer?,
                        renderResult.clickableViews,
                        renderResult.creativeViews
                    )
                }
            }
        }.onFailure {
            Log.e(TAG, "Failed to add ad view for adId: $currentAdId", it)
        }
    }

    override fun getView(): View = unifiedView // 简化 getter

    override fun dispose() {
        adId?.let { id ->
            AdUnifiedWrapperManager.getInstance().removeAdItem(id) // 清理 Manager 资源
            AdWrapperManager.getInstance().removeAdView(id)
        }
        rootView.removeAllViews()
    }
}
