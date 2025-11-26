package xyz.adscope.adscope_sdk.manager // 根据你的项目结构调整包名

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

//import com.example.amps_sdk.view.SplashFactory
//import com.example.amps_sdk.view.InterstitialFactory
//import com.example.amps_sdk.view.NativeFactory
//import com.example.amps_sdk.view.UnifiedFactory

class AMPSPlatformViewManager private constructor() {
    companion object {
        @Volatile
        private var sInstance: AMPSPlatformViewManager? = null

        fun getInstance(): AMPSPlatformViewManager {
            return sInstance ?: synchronized(this) {
                sInstance ?: AMPSPlatformViewManager().also { sInstance = it }
            }
        }
    }

    /**
     * 初始化并注册平台视图工厂。
     * 通常在 Flutter 插件的 onAttachedToEngine 方法中调用。
     *
     * @param binding FlutterPluginBinding，用于访问 BinaryMessenger 和 PlatformViewRegistry。
     */
    fun init(binding: FlutterPluginBinding) {
        val platformViewRegistry = binding.platformViewRegistry
        val binaryMessenger = binding.binaryMessenger

        // 注册 Splash 视图工厂
//        platformViewRegistry.registerViewFactory(
//            AMPSPlatformViewRegistry.AMPS_SDK_SPLASH_VIEW_ID,
//            SplashFactory(binaryMessenger, StandardMessageCodec.INSTANCE)
//        )
//
//        // 注册 Interstitial 视图工厂
//        platformViewRegistry.registerViewFactory(
//            AMPSPlatformViewRegistry.AMPS_SDK_INTERSTITIAL_VIEW_ID,
//            InterstitialFactory(binaryMessenger, StandardMessageCodec.INSTANCE)
//        )
//
//        // 注册 Native 视图工厂
//        platformViewRegistry.registerViewFactory(
//            AMPSPlatformViewRegistry.AMPS_SDK_NATIVE_VIEW_ID,
//            NativeFactory(binaryMessenger, StandardMessageCodec.INSTANCE)
//        )
//
//        // 注册 Unified 视图工厂
//        platformViewRegistry.registerViewFactory(
//            AMPSPlatformViewRegistry.AMPS_SDK_UNIFIED_VIEW_ID,
//            UnifiedFactory(binaryMessenger, StandardMessageCodec.INSTANCE)
//        )
    }
}

