package xyz.adscope.adscope_sdk.view

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AndroidMallHost
import xyz.adscope.amps.ad.unified.view.AMPSUnifiedRootContainer

class MallFactory(private val engine: AMPSEventManager) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val map = args as? Map<*, *> ?: emptyMap<Any, Any>()
        return MallHostView(context, engine, map["adInstanceId"] as? String ?: "",
            map["adId"] as? String ?: "", map["visible"] as? Boolean ?: true)
    }
}

private class MallHostView(
    context: Context,
    private val engine: AMPSEventManager,
    private val owner: String,
    private val adId: String,
    visible: Boolean
) : AMPSUnifiedRootContainer(context), PlatformView, AndroidMallHost {
    private var ready = false
    private var disposed = false
    private var mall: View? = null
    private var updatingVisibility = false
    private var appliedRequestedVisibility: Boolean? = null
    private val store get() = engine.native.mallStore

    init {
        ready = true
        if (!store.attachHost(owner, adId, this)) {
            showError("商城不存在或已被其他组件挂载", report = false)
        } else {
            store.setVisible(owner, adId, visible)
            reload()
        }
    }
    override fun getView(): View = this
    private fun showError(message: String, report: Boolean = true) {
        if (report) store.setEffectiveVisibility(owner, adId, false)
        removeAllViews()
        addView(TextView(context).apply { text = message }, FrameLayout.LayoutParams(-1, -1))
        if (report) engine.native.mallFailed(owner, message)
    }
    override fun reload() {
        if (disposed || engine.isReleased) return
        mall?.visibility = View.GONE
        removeAllViews()
        mall = null
        val item = store.item(owner, adId) ?: return showError("商城广告已释放")
        val activity = engine.getActivity() ?: return showError("商城所属Activity不可用")
        try {
            val view = store.obtainView(owner, adId) ?: return showError("广告位未返回商城视图，请使用商城专用广告位")
            if (view.parent != null && view.parent !== this) return showError("同一个商城不能重复挂载")
            mall = view
            addView(view, FrameLayout.LayoutParams(-1, -1))
            item.bindAdToRootContainer(activity, this, listOf(this), null)
            store.didBind(owner, adId)
        } catch (error: Exception) { showError("商城挂载失败：${error.message}") }
    }
    override fun syncVisibility() {
        if (!ready || disposed || updatingVisibility || !store.isHost(owner, adId, this)) return
        updatingVisibility = true
        try {
            val requested = store.requestedVisible(owner, adId)
            // SDK监测的是root；仅隐藏商城子view无法阻止首次绑定启动轮播。
            // 只在业务显隐改变时设置root，避免覆盖Android系统对root的显隐。
            if (appliedRequestedVisibility != requested) {
                appliedRequestedVisibility = requested
                visibility = if (requested) View.VISIBLE else View.GONE
            }
            store.setEffectiveVisibility(owner, adId,
                mall != null && requested && isAttachedToWindow && isShown)
        } finally { updatingVisibility = false }
    }
    override fun onAttachedToWindow() { super.onAttachedToWindow(); syncVisibility() }
    override fun onDetachedFromWindow() {
        if (store.isHost(owner, adId, this)) store.setEffectiveVisibility(owner, adId, false)
        super.onDetachedFromWindow()
    }
    override fun onWindowVisibilityChanged(visibility: Int) { super.onWindowVisibilityChanged(visibility); syncVisibility() }
    override fun onVisibilityChanged(changedView: View, visibility: Int) { super.onVisibilityChanged(changedView, visibility); syncVisibility() }
    override fun dispose() {
        if (disposed) return
        disposed = true
        if (store.isHost(owner, adId, this)) store.setEffectiveVisibility(owner, adId, false)
        mall?.visibility = View.GONE
        removeAllViews()
        mall = null
        if (!engine.isReleased) store.detachHost(owner, adId, this)
    }
}
