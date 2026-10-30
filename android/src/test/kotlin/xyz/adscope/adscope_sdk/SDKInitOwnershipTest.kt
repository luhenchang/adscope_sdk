package xyz.adscope.adscope_sdk

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Assert.assertEquals
import org.junit.Test
import org.mockito.Mockito.*
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.amps.AMPSSDK
import xyz.adscope.amps.init.AMPSInitConfig
import xyz.adscope.amps.init.inter.IAMPSInitCallback

class SDKInitOwnershipTest {
    @Test fun concurrentInitStartsNativeSdkOnceAndRepliesToBothOwners() {
        val callbacks = mutableListOf<IAMPSInitCallback>()
        mockStatic(AMPSSDK::class.java, withSettings().defaultAnswer { invocation ->
            if (invocation.method.name == "init") callbacks.add(invocation.getArgument(2))
            null
        }).use {
            val a = mock(BinaryMessenger::class.java)
            val b = mock(BinaryMessenger::class.java)
            val first = AMPSEventManager { it.run() }.also { it.init(a) }
            val second = AMPSEventManager { it.run() }.also { it.init(b) }
            val context = mock(Context::class.java)
            val config = mock(AMPSInitConfig::class.java)
            first.sdkInit.initAMPSSDK(config, context, false)
            second.sdkInit.initAMPSSDK(config, context, false)
            val count = callbacks.size
            callbacks.first().successCallback()
            assertEquals("Concurrent engines must share the native initialization", 1, count)
            verify(a).send(eq("adscope_sdk"), any(), isNull())
            verify(b).send(eq("adscope_sdk"), any(), isNull())
        }
    }

    @Test fun detachedInitRequesterIsDroppedWhileSiblingStillReceivesCompletion() {
        val callbacks = mutableListOf<IAMPSInitCallback>()
        mockStatic(AMPSSDK::class.java, withSettings().defaultAnswer { invocation ->
            if (invocation.method.name == "init") callbacks.add(invocation.getArgument(2))
            null
        }).use {
            val a = mock(BinaryMessenger::class.java)
            val b = mock(BinaryMessenger::class.java)
            val first = AMPSEventManager { it.run() }.also { it.init(a) }
            val second = AMPSEventManager { it.run() }.also { it.init(b) }
            val context = mock(Context::class.java)
            val config = mock(AMPSInitConfig::class.java)
            first.sdkInit.initAMPSSDK(config, context, false)
            second.sdkInit.initAMPSSDK(config, context, false)
            first.release()
            clearInvocations(a, b)
            callbacks.first().successCallback()
            verifyNoInteractions(a)
            verify(b).send(eq("adscope_sdk"), any(), isNull())
        }
    }
    @Test fun failedInitAllowsRetryAndStaleCompletionCannotFinishNewAttempt() {
        val callbacks = mutableListOf<IAMPSInitCallback>()
        mockStatic(AMPSSDK::class.java, withSettings().defaultAnswer { invocation ->
            if (invocation.method.name == "init") callbacks.add(invocation.getArgument(2))
            null
        }).use {
            val messenger = mock(BinaryMessenger::class.java)
            val owner = AMPSEventManager { it.run() }.also { it.init(messenger) }
            val context = mock(Context::class.java)
            val config = mock(AMPSInitConfig::class.java)
            owner.sdkInit.initAMPSSDK(config, context, false)
            callbacks[0].failCallback(null)
            owner.sdkInit.initAMPSSDK(config, context, false)
            assertEquals(2, callbacks.size)
            clearInvocations(messenger)
            callbacks[0].successCallback()
            verifyNoInteractions(messenger)
            callbacks[1].successCallback()
            verify(messenger).send(eq("adscope_sdk"), any(), isNull())
        }
    }
    @Test fun cachedEngineCanInitializeWithItsBindingApplicationContextBeforeActivityAttachment() {
        val contexts = mutableListOf<Context>()
        val callbacks = mutableListOf<IAMPSInitCallback>()
        mockStatic(AMPSSDK::class.java, withSettings().defaultAnswer { invocation ->
            if (invocation.method.name == "init") {
                contexts.add(invocation.getArgument(0))
                callbacks.add(invocation.getArgument(2))
            }
            null
        }).use {
            val binding = mock(io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding::class.java, RETURNS_DEEP_STUBS)
            val applicationContext = mock(Context::class.java)
            `when`(binding.applicationContext).thenReturn(applicationContext)
            val plugin = AdscopeSdkPlugin().also { it.onAttachedToEngine(binding) }
            val result = mock(io.flutter.plugin.common.MethodChannel.Result::class.java)
            val config = mock(AMPSInitConfig::class.java)
            mockConstruction(AMPSInitConfig.Builder::class.java) { builder, _ ->
                `when`(builder.build()).thenReturn(config)
            }.use {
                plugin.engine!!.onMethodCall(io.flutter.plugin.common.MethodCall(
                    xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames.INIT, mapOf("appId" to "14657")), result)
            }
            plugin.onDetachedFromEngine(binding)
            callbacks.forEach { it.successCallback() }
            assertEquals(listOf(applicationContext), contexts)
            verify(result).success(true)
        }
    }
}
