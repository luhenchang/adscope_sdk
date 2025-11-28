package xyz.adscope.adscope_sdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AMPSPlatformViewManager
/** AmpsSdkPlugin */
class AdscopeSdkPlugin : FlutterPlugin, ActivityAware {
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