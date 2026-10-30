package xyz.adscope.adscope_sdk_example

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/** Second FlutterEngine. Initial route /engine-b runs the lab as engine B. */
class MultiEngineLabActivity : FlutterActivity() {
    override fun getInitialRoute(): String = "/engine-b"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MultiEngineLabHost.attach("B", this, flutterEngine)
    }

    override fun onDestroy() {
        MultiEngineLabHost.detach("B")
        super.onDestroy()
    }
}

object MultiEngineLabHost {
    private const val CHANNEL = "adscope_example_multi_engine"
    private val channels = mutableMapOf<String, MethodChannel>()
    private val activities = mutableMapOf<String, WeakReference<Activity>>()
    private var openingB = false

    fun attach(name: String, activity: Activity, flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channels[name] = channel
        activities[name] = WeakReference(activity)
        if (name == "B") openingB = false
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "openEngineB" -> {
                    if (name != "A" || activities["B"]?.get() != null || openingB) {
                        result.success(false)
                    } else {
                        openingB = true
                        activity.startActivity(Intent(activity, MultiEngineLabActivity::class.java))
                        result.success(true)
                    }
                }
                "closeEngineB" -> {
                    activities["B"]?.get()?.finish()
                    result.success(true)
                }
                "publish" -> {
                    val peer = if (name == "A") "B" else "A"
                    channels[peer]?.invokeMethod("peer", call.arguments)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        notifyPeer()
    }

    fun detach(name: String) {
        channels.remove(name)?.setMethodCallHandler(null)
        activities.remove(name)
        if (name == "B") openingB = false
        notifyPeer()
    }

    private fun notifyPeer() {
        val opened = activities["B"]?.get() != null
        channels["A"]?.invokeMethod("peerState", mapOf("opened" to opened))
        channels["B"]?.invokeMethod("peerState", mapOf("opened" to opened))
    }
}
