package xyz.adscope.adscope_sdk.manager

import android.view.View
import android.view.ViewGroup
import xyz.adscope.adscope_sdk.utils.flutterCodecValue
import xyz.adscope.amps.ad.unified.inter.AMPSUnifiedNativeItem
import java.lang.ref.WeakReference

internal interface AndroidMallHost {
    fun reload()
    fun syncVisibility()
    fun dispose()
}

/** 每个engine独立持有；获取信息不创建view，只有PlatformView挂载时才取渠道商城。 */
internal class AndroidMallStore {
    private data class Key(val owner: String, val adId: String)
    private class Entry(var item: AMPSUnifiedNativeItem) {
        var view: View? = null
        var attempted = false
        var visible = true
        var active: Boolean? = null
        var host: WeakReference<AndroidMallHost>? = null
    }
    private val entries = mutableMapOf<Key, Entry>()

    fun put(owner: String, adId: String, item: AMPSUnifiedNativeItem) {
        entries[Key(owner, adId)] = Entry(item)
    }
    fun item(owner: String, adId: String) = entries[Key(owner, adId)]?.item
    fun obtainView(owner: String, adId: String): View? {
        val entry = entries[Key(owner, adId)] ?: return null
        if (!entry.attempted) {
            entry.attempted = true
            entry.view = entry.item.nativeExpressAdView
        }
        return entry.view
    }
    fun attachHost(owner: String, adId: String, host: AndroidMallHost): Boolean {
        val entry = entries[Key(owner, adId)] ?: return false
        val previous = entry.host?.get()
        if (previous != null && previous !== host) return false
        entry.host = WeakReference(host)
        return true
    }
    fun isHost(owner: String, adId: String, host: AndroidMallHost) =
        entries[Key(owner, adId)]?.host?.get() === host

    fun didBind(owner: String, adId: String) {
        val entry = entries[Key(owner, adId)] ?: return
        // 曝光前的pause可能被SDK忽略；完成绑定后重新同步一次。
        entry.active = null
        val host = entry.host?.get()
        if (host != null) host.syncVisibility() else applyVisibility(entry, false)
    }
    fun detachHost(owner: String, adId: String, host: AndroidMallHost) {
        entries[Key(owner, adId)]?.let { if (it.host?.get() === host) it.host = null }
    }
    fun requestedVisible(owner: String, adId: String) = entries[Key(owner, adId)]?.visible == true
    fun setVisible(owner: String, adId: String, visible: Boolean) {
        val entry = entries[Key(owner, adId)] ?: return
        entry.visible = visible
        val host = entry.host?.get()
        if (host != null) host.syncVisibility() else applyVisibility(entry, false)
    }
    private fun applyVisibility(entry: Entry, visible: Boolean) {
        entry.view?.visibility = if (visible) View.VISIBLE else View.GONE
        if (entry.active == visible) return
        entry.active = visible
        // SDK轮播跟踪root容器，隐藏子view之外还需暂停item的轮播。
        if (visible) entry.item.resume() else entry.item.pause()
    }
    fun setEffectiveVisibility(owner: String, adId: String, visible: Boolean) {
        entries[Key(owner, adId)]?.let { applyVisibility(it, visible) }
    }
    fun info(owner: String, adId: String): Map<String, Any?> {
        val entry = entries[Key(owner, adId)]
        return mapOf("supportsMall" to (entry?.view != null),
            "viewCreated" to (entry?.view != null),
            "isValid" to (entry?.item?.isValid == true),
            "extras" to flutterCodecValue(entry?.item?.extras ?: emptyMap<String, Any>()))
    }
    fun replace(owner: String, adId: String, item: AMPSUnifiedNativeItem) {
        val entry = entries[Key(owner, adId)] ?: return
        applyVisibility(entry, false)
        entry.item = item
        entry.view = null
        entry.attempted = false
        entry.active = null
        val host = entry.host?.get()
        if (host != null) host.reload() else applyVisibility(entry, false)
    }
    fun removeOwner(owner: String) {
        entries.keys.filter { it.owner == owner }.toList().forEach { key ->
            val entry = entries.remove(key) ?: return@forEach
            applyVisibility(entry, false)
            entry.host?.get()?.dispose()
            entry.view?.let { view ->
                view.visibility = View.GONE
                (view.parent as? ViewGroup)?.removeView(view)
            }
        }
    }
    fun clear() { entries.keys.map { it.owner }.distinct().forEach(::removeOwner) }
}
