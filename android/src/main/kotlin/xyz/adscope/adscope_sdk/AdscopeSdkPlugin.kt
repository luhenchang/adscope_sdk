package xyz.adscope.adscope_sdk

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AMPSPlatformViewManager

/** Each registration owns its channel, Activity, ads, and platform view factories. */
class AdscopeSdkPlugin : FlutterPlugin, ActivityAware {
    internal var engine: AMPSEventManager? = null
        private set

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val owner = AMPSEventManager(binding.applicationContext)
        engine = owner
        owner.init(binding.binaryMessenger)
        AMPSPlatformViewManager(owner).init(binding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        engine?.release()
        engine = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        engine?.setActivity(binding.activity)
    }
    override fun onDetachedFromActivityForConfigChanges() { engine?.setActivity(null) }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }
    override fun onDetachedFromActivity() { engine?.setActivity(null) }
}
