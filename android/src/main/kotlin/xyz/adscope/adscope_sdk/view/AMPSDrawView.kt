package xyz.adscope.adscope_sdk.view

import android.content.Context
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import xyz.adscope.adscope_sdk.data.AD_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames.DRAW_SIZE_UPDATE
import xyz.adscope.adscope_sdk.data.NATIVE_HEIGHT
import xyz.adscope.adscope_sdk.data.NATIVE_WIDTH
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AdWrapperManager
import xyz.adscope.adscope_sdk.utils.dpToPx
import xyz.adscope.adscope_sdk.utils.pxToDp
import xyz.adscope.common.v2.dev.info.ScreenUtil


class AMPSDrawView(
    private val context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger,
    args: Any?
) : PlatformView, MethodChannel.MethodCallHandler {
    private var rootView: FrameLayout
    private val adId: String?

    init {
        val creationArgs = parseCreationArgs(args)
        adId = creationArgs[AD_ID] as? String
        rootView = createRootView(creationArgs)
        addAdViewToRoot()
    }

    /**
     * 解析从 Flutter 传递过来的初始化参数
     */
    private fun parseCreationArgs(args: Any?): Map<*, *> {
        return args as? Map<*, *> ?: emptyMap<Any, Any>()
    }

    /**
     * 创建根视图 FrameLayout 并设置其基本布局
     */
    private fun createRootView(args: Map<*, *>): FrameLayout {
        val nativeWidth = args[NATIVE_WIDTH] as? Double

        return FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
            val screenWidthPx = ScreenUtil.getScreenWidth(context)
            if (nativeWidth == null) {
                val adViewParams = FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    gravity = Gravity.CENTER
                }
                tag = adViewParams
            } else {
                val nativeWidthPx = nativeWidth.toInt().dpToPx(context)
                val adViewWidth = nativeWidthPx.coerceAtMost(screenWidthPx)
                val adViewParams = FrameLayout.LayoutParams(
                    adViewWidth,
                    FrameLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    gravity = Gravity.CENTER
                }
                tag = adViewParams
            }
        }
    }

    /**
     * 获取广告视图并添加到根视图中
     */
    private fun addAdViewToRoot() {
        val adId = this.adId ?: return
        runCatching {
            val drawView = AdWrapperManager.getInstance().getAdView(adId)
            val params = rootView.tag as? FrameLayout.LayoutParams
            if (drawView != null && params != null) {
                (drawView.parent as? FrameLayout)?.removeView(drawView)
                drawView.layoutParams = params
                rootView.addView(drawView)
                observeNativeViewSize(drawView)
            }
        }.onFailure {
            Log.e("AMPSNativeView", "Failed to add ad view for adId: $adId", it)
        }
    }

    /**
     * 监听 nativeView 的布局变化，获取宽高
     */
    private fun observeNativeViewSize(drawView: View) {
        // 避免重复添加监听
        drawView.viewTreeObserver.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                val width = drawView.width
                val height = drawView.height
                if (width > 0 && height > 0) {
                    AMPSEventManager.getInstance().sendMessageToFlutter(DRAW_SIZE_UPDATE,mapOf(
                        NATIVE_WIDTH to width.pxToDp(context),
                        NATIVE_HEIGHT to height.pxToDp(context),
                        AD_ID to adId
                    ))
                    // 3. 移除监听（避免重复回调）- 注意 API 版本兼容
                    drawView.viewTreeObserver.removeOnGlobalLayoutListener(this)
                }
            }
        })
    }

    override fun getView(): View {
        return rootView
    }

    override fun dispose() {
        adId?.let {
            AdWrapperManager.getInstance().removeAdItem(it)
        }
        rootView.removeAllViews()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.notImplemented()
    }
}