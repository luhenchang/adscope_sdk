package xyz.adscope.adscope_sdk.view

import android.content.Context
import android.graphics.Color
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
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames.NATIVE_SIZE_UPDATE
import xyz.adscope.adscope_sdk.data.NATIVE_HEIGHT
import xyz.adscope.adscope_sdk.data.NATIVE_WIDTH
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AdWrapperManager
import xyz.adscope.adscope_sdk.utils.dpToPx
import xyz.adscope.adscope_sdk.utils.pxToDp
import xyz.adscope.common.v2.dev.info.ScreenUtil


class AMPSNativeView(
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
            val nativeView = AdWrapperManager.getInstance().getAdView(adId)
            val params = rootView.tag as? FrameLayout.LayoutParams
            if (nativeView != null && params != null) {
                (nativeView.parent as? FrameLayout)?.removeView(nativeView)
                nativeView.layoutParams = params
                rootView.addView(nativeView)
                observeNativeViewSize(nativeView)
            }
        }.onFailure {
            Log.e("AMPSNativeView", "Failed to add ad view for adId: $adId", it)
        }
    }

    /**
     * 监听 nativeView 的布局变化，获取宽高
     */
    private fun observeNativeViewSize(nativeView: View) {
        // 避免重复添加监听
        nativeView.viewTreeObserver.addOnGlobalLayoutListener(object : ViewTreeObserver.OnGlobalLayoutListener {
            override fun onGlobalLayout() {
                val width = nativeView.width
                val height = nativeView.height
                if (width > 0 && height > 0) {
                    AMPSEventManager.getInstance().sendMessageToFlutter(NATIVE_SIZE_UPDATE,mapOf(
                        NATIVE_WIDTH to width.pxToDp(context),
                        NATIVE_HEIGHT to height.pxToDp(context),
                        AD_ID to adId
                    ))
                    // 3. 移除监听（避免重复回调）- 注意 API 版本兼容
                    nativeView.viewTreeObserver.removeOnGlobalLayoutListener(this)
                }
            }
        })
    }

    override fun getView(): View {
        return rootView
    }

    override fun dispose() {
        rootView.removeAllViews()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.notImplemented()
    }
}