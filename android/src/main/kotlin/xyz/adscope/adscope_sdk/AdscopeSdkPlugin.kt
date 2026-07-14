package xyz.adscope.adscope_sdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.adscope_sdk.manager.AMPSPlatformViewManager
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil

/** AmpsSdkPlugin */
class AdscopeSdkPlugin : FlutterPlugin, ActivityAware {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        AMPSEventManager.getInstance().init(flutterPluginBinding.binaryMessenger)
        AMPSPlatformViewManager.getInstance().init(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AMPSEventManager.getInstance().release()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        FlutterPluginUtil.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // 配置变更（如旋转屏幕）导致旧 Activity 销毁，清空引用避免使用已销毁的 Activity
        FlutterPluginUtil.setActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // 配置变更后重新挂载新 Activity，必须更新引用，否则 getActivity() 返回 null
        FlutterPluginUtil.setActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        FlutterPluginUtil.setActivity(null)
    }
}