package xyz.adscope.adscope_sdk.manager

import android.app.Activity
import android.content.Context
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

/** One Flutter engine owns this channel, Activity, managers, and view stores. */
class AMPSEventManager(
    private var applicationContext: Context? = null,
    private val dispatch: (Runnable) -> Unit = FlutterPluginUtil::runOnUiThread
) : MethodCallHandler {

    private var channel: MethodChannel? = null
    private var activity: WeakReference<Activity>? = null
    @Volatile var isReleased = false
        private set
    val unifiedViews = java.util.concurrent.ConcurrentHashMap<String, WeakReference<xyz.adscope.adscope_sdk.view.AMPSUnifiedView>>()
    // Detach releases only managers used by this engine, without creating SDK objects.
    private val cleanup = mutableListOf<() -> Unit>()
    private fun <T> owned(factory: () -> T, release: (T) -> Unit): Lazy<T> = lazy {
        factory().also { value -> cleanup.add { release(value) } }
    }
    val sdkInit by lazy { AMPSSDKInitManager(this) }
    val splash by owned({ AMPSSplashManager(this) }, { it.release() })
    val interstitial by owned({ AMPSInterstitialManager(this) }, { it.release() })
    val native by owned({ AMPSNativeManager(this) }, { it.release() })
    val rewarded by owned({ AMPSRewardedVideoManager(this) }, { it.release() })
    val banner by owned({ AMPSBannerManager(this) }, { it.release() })
    val draw by owned({ AMPSDrawManager(this) }, { it.release() })
    val wrappers by owned({ AdWrapperManager() }, { it.release() })
    val unifiedWrappers by owned({ AdUnifiedWrapperManager() }, { it.release() })

    fun setActivity(value: Activity?) { activity = value?.let { WeakReference(it) } }
    fun getActivity(): Activity? = activity?.get()
    fun getApplicationContext(): Context? = applicationContext ?: getActivity()?.applicationContext

    /**
     * 初始化 MethodChannel 并设置回调处理器
     * @param binaryMessenger Flutter引擎的BinaryMessenger
     */
    fun init(binaryMessenger: BinaryMessenger) {
        check(!isReleased) { "Engine has been detached" }
        if (channel == null) {
            channel = MethodChannel(binaryMessenger, "adscope_sdk") // "amps_sdk" 是通道名称
            channel?.setMethodCallHandler(this) // 将当前类设置为回调处理器
        }
    }

    /**
     * 处理来自 Flutter 的方法调用
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        if (isReleased) { result.error("ENGINE_DETACHED", "Flutter engine is detached", null); return }
        when {
            InitMethodNames.contains(call.method) -> {
                sdkInit.handleMethodCall(call, result)
            }
            SplashMethodNames.contains(call.method) -> {
                splash.handleMethodCall(call, result)
            }
            InterstitialMethodNames.contains(call.method) -> {
                interstitial.handleMethodCall(call, result)
            }

            NativeMethodNames.contains(call.method) -> {
                native.handleMethodCall(call, result)
            }
            RewardedVideoMethodNames.contains(call.method) -> {
                rewarded.handleMethodCall(call, result)
            }
            BannerMethodNames.contains(call.method) -> {
                banner.handleMethodCall(call, result)
            }

            DrawMethodNames.contains(call.method) -> {
                draw.handleMethodCall(call, result)
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
        dispatch(Runnable {
            if (!isReleased) channel?.invokeMethod(method, args)
        })
    }

    /**
     * 释放资源，清除 MethodChannel 的回调处理器和 Context
     */
    fun release() {
        isReleased = true
        AMPSInitCoordinator.detach(this)
        channel?.setMethodCallHandler(null)
        channel = null // 可选，如果不再需要这个channel实例
        setActivity(null)
        applicationContext = null
        cleanup.toList().forEach { runCatching { it() } }
        cleanup.clear()
        unifiedViews.clear()
    }
}
