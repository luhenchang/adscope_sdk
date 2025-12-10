package xyz.adscope.adscope_sdk.manager

import android.app.Activity
import xyz.adscope.adscope_sdk.data.InitMethodNames
import xyz.adscope.adscope_sdk.data.SplashMethodNames
import xyz.adscope.adscope_sdk.data.InterstitialMethodNames
import xyz.adscope.adscope_sdk.data.NativeMethodNames
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.BannerMethodNames
import xyz.adscope.adscope_sdk.data.DrawMethodNames
import xyz.adscope.adscope_sdk.data.RewardedVideoMethodNames
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import java.lang.ref.WeakReference

class AMPSEventManager private constructor() : MethodCallHandler {

    private var channel: MethodChannel? = null
    private var mContext: WeakReference<Activity>? = null // 在 Android 中通常使用 Context

    companion object {
        private var sInstance: AMPSEventManager? = null
        fun getInstance(): AMPSEventManager {
            return sInstance ?: synchronized(this) {
                sInstance ?: AMPSEventManager().also { sInstance = it }
            }
        }
    }

    /**
     * 初始化 MethodChannel 并设置回调处理器
     * @param binaryMessenger Flutter引擎的BinaryMessenger
     */
    fun init(binaryMessenger: BinaryMessenger) {
        if (channel == null) {
            channel = MethodChannel(binaryMessenger, "adscope_sdk") // "amps_sdk" 是通道名称
            channel?.setMethodCallHandler(this) // 将当前类设置为回调处理器
        }
    }

    /**
     * 处理来自 Flutter 的方法调用
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            InitMethodNames.contains(call.method) -> {
                AMPSSDKInitManager.getInstance().handleMethodCall(call, result)
            }
            SplashMethodNames.contains(call.method) -> {
                AMPSSplashManager.getInstance().handleMethodCall(call, result)
            }
            InterstitialMethodNames.contains(call.method) -> {
                AMPSInterstitialManager.getInstance().handleMethodCall(call, result)
            }

            NativeMethodNames.contains(call.method) -> {
                AMPSNativeManager.getInstance().handleMethodCall(call, result)
            }
            RewardedVideoMethodNames.contains(call.method) -> {
                AMPSRewardedVideoManager.getInstance().handleMethodCall(call, result)
            }
            BannerMethodNames.contains(call.method) -> {
                AMPSBannerManager.getInstance().handleMethodCall(call, result)
            }

            DrawMethodNames.contains(call.method) -> {
                AMPSDrawManager.getInstance().handleMethodCall(call, result)
            }

            else -> {
                result.notImplemented() // 如果方法名未被识别
            }
        }
    }

    /**
     * 从原生端向 Flutter 发送消息
     * @param method 方法名
     * @param args 参数，可以是 null 或任何 Flutter 支持的类型
     */
    fun sendMessageToFlutter(method: String, args: Any?) {
        FlutterPluginUtil.runOnUiThread {
            channel?.invokeMethod(method, args)
        }
    }

    /**
     * 释放资源，清除 MethodChannel 的回调处理器和 Context
     */
    fun release() {
        channel?.setMethodCallHandler(null)
        channel = null // 可选，如果不再需要这个channel实例
        mContext = null
    }
}
