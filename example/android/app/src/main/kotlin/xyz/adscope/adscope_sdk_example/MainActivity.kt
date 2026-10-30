package xyz.adscope.adscope_sdk_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MultiEngineLabHost.attach("A", this, flutterEngine)
    }

    override fun onDestroy() {
        MultiEngineLabHost.detach("A")
        super.onDestroy()
    }
}
