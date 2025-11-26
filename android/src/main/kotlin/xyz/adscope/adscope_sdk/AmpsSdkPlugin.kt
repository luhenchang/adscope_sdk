package xyz.adscope.adscope_sdk

import com.example.amps_sdk.manager.AMPSEventManager
import com.example.amps_sdk.manager.AMPSPlatformViewManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** AmpsSdkPlugin */
class AmpsSdkPlugin :
    FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AMPSEventManager.getInstance().init(flutterPluginBinding.binaryMessenger)
        AMPSPlatformViewManager.getInstance().init(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        AMPSEventManager.getInstance().setContext(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        AMPSEventManager.getInstance().release()
    }
}
