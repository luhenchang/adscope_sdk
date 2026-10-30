package xyz.adscope.adscope_sdk_example

import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

/** Debug-only host for example/android/multi_engine_probe.dart. */
class MultiEngineProbeActivity : FlutterActivity() {
    override fun getInitialRoute(): String = if (intent.getBooleanExtra("engineB", false)) "/B" else "/A"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val name = if (intent.getBooleanExtra("engineB", false)) "B" else "A"
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "adscope_multi_engine_probe")
        ProbeCoordinator.attach(name, this, channel)
        channel.setMethodCallHandler { call, result ->
            if (call.method == "event") {
                @Suppress("UNCHECKED_CAST")
                ProbeCoordinator.event(name, call.arguments as? Map<String, Any?> ?: emptyMap())
                result.success(null)
            } else result.notImplemented()
        }
    }

    override fun onDestroy() {
        val name = if (intent.getBooleanExtra("engineB", false)) "B" else "A"
        super.onDestroy()
        Log.i("MultiEngineProbe", "Activity destroyed: engine=$name, finishesAndDestroysEngine=${isFinishing}")
    }

    private object ProbeCoordinator {
        private val main = Handler(Looper.getMainLooper())
        private val channels = mutableMapOf<String, MethodChannel>()
        private val activities = mutableMapOf<String, WeakReference<MultiEngineProbeActivity>>()
        private var stage = 0
        private var allRendered = true

        fun attach(name: String, activity: MultiEngineProbeActivity, channel: MethodChannel) {
            if (name == "A") { stage = 0; allRendered = true; channels.clear(); activities.clear() }
            channels[name] = channel
            activities[name] = WeakReference(activity)
        }

        fun event(name: String, data: Map<String, Any?>) {
            Log.i("MultiEngineProbe", data.toString())
            val outcome = data["event"]
            if (outcome != "renderOk" && outcome != "loadFail" && outcome != "renderFail") return
            if (outcome != "renderOk") allRendered = false
            when {
                stage == 0 && name == "A" -> {
                    stage = 1
                    main.postDelayed({
                        activities["A"]?.get()?.let {
                            it.startActivity(Intent(it, MultiEngineProbeActivity::class.java).putExtra("engineB", true))
                        }
                    }, 1500)
                }
                stage == 1 && name == "B" -> {
                    stage = 2
                    main.postDelayed({ channels["A"]?.invokeMethod("reload", "shared_initial") }, 1500)
                }
                stage == 2 && name == "A" && data["instanceId"] == "shared_initial" -> {
                    stage = 3
                    main.postDelayed({
                        activities["B"]?.get()?.finish()
                        activities.remove("B")
                        channels.remove("B")
                        main.postDelayed({ channels["A"]?.invokeMethod("reload", "shared_initial") }, 2000)
                    }, 1500)
                }
                stage == 3 && name == "A" && data["instanceId"] == "shared_initial" -> {
                    stage = 4
                    val result = if (allRendered) "RENDER_PASS" else "CALLBACK_ROUTING_PASS"
                    Log.i("MultiEngineProbe", "$result: A callback, B callback, A callback for recreated shared_initial with B alive, A callback for same ID after B engine detach; allRendered=$allRendered")
                }
            }
        }
    }
}
