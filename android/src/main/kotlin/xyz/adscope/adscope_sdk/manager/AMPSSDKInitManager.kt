package xyz.adscope.adscope_sdk.manager

import android.content.Context
import android.os.Handler
import android.os.Looper
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.AMPSInitChannelMethod
import xyz.adscope.adscope_sdk.data.AMPSInitConfigConverter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import xyz.adscope.adscope_sdk.data.AMPSInitConfigKey
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.adscope_sdk.utils.FlutterPluginUtil
import xyz.adscope.amps.AMPSSDK
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.init.AMPSInitConfig
import xyz.adscope.amps.init.inter.IAMPSInitCallback
import xyz.adscope.common.v2.log.SDKLog
import kotlin.synchronized

private val mainThreadHandler = Handler(Looper.getMainLooper())

class AMPSSDKInitManager private constructor() {

    companion object {
        @Volatile
        private var instance: AMPSSDKInitManager? = null

        fun getInstance(): AMPSSDKInitManager {
            return instance ?: synchronized(this) {
                instance ?: AMPSSDKInitManager().also { instance = it }
            }
        }
    }
    /**
     * 全局方法：根据 code 值获取 Java 枚举 LOG_LEVEL 实例
     * @param code 枚举对应的整数值（可为 null）
     * @return 匹配的 LOG_LEVEL 枚举，无匹配/空值时返回 null
     */
    fun getLogLevelByCode(code: Int?): SDKLog.LOG_LEVEL? {
        if (code == null) return null
        // 遍历枚举值匹配 code
        return SDKLog.LOG_LEVEL.entries.firstOrNull { it.value == code }
    }
    @Suppress("UNCHECKED_CAST")
    fun handleMethodCall(call: MethodCall, result: Result) {
        val method: String = call.method
        val flutterParams: Map<String, Any>? = call.arguments as? Map<String, Any>

        when (method) {
            AMPSAdSdkMethodNames.SET_LOG_LEVEL -> {
                if (call.arguments != null) {
                    getLogLevelByCode(call.arguments as Int)?.let {
                        SDKLog.setLogLevel(it)
                    }
                }
                result.success(null)
            }
            AMPSAdSdkMethodNames.INIT -> {
                val context = FlutterPluginUtil.getActivity()
                if (context != null && flutterParams != null) {
                    val isMediation =
                        flutterParams[AMPSInitConfigKey.IS_MEDIATION] as? Boolean ?: false
                    val ampsConfig = AMPSInitConfigConverter().convert(flutterParams)
                    initAMPSSDK(ampsConfig, context, isMediation)
                    result.success(true)
                } else {
                    if (context == null) {
                        result.error(
                            "CONTEXT_UNAVAILABLE",
                            "Android context is not available.",
                            null
                        )
                    } else {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Initialization arguments are missing or invalid.",
                            null
                        )
                    }
                }
            }
            AMPSAdSdkMethodNames.GET_SDK_VERSION -> {
                result.success(AMPSSDK.getSdkVersion())
            }

            AMPSAdSdkMethodNames.GET_INIT_STATUS -> {
                result.success(AMPSSDK.sdkInitStatus().code)
            }

            AMPSAdSdkMethodNames.SET_PERSONAL_RECOMMEND -> {
                AMPSSDK.setPersonalRecommend(call.arguments as Boolean)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    fun initAMPSSDK(ampsInitConfig: AMPSInitConfig?, context: Context, isMediation: Boolean) {
        val callback = object : IAMPSInitCallback {
            override fun successCallback() {
                mainThreadHandler.post {
                    sendMessage(AMPSInitChannelMethod.INIT_SUCCESS)
                }
            }

            override fun failCallback(p0: AMPSError?) {
                sendMessage(
                    AMPSInitChannelMethod.INIT_FAILED,
                    mapOf(
                        ErrorModel.CODE to (p0?.code?.toInt() ?: -1),
                        ErrorModel.MESSAGE to p0?.message
                    )
                )
            }
        }

        if (ampsInitConfig != null) {
            AMPSSDK.init(context, ampsInitConfig, callback)
        }
    }

    fun sendMessage(method: String, args: Any? = null) {
        FlutterPluginUtil.runOnUiThread {
            AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
        }
    }
}
