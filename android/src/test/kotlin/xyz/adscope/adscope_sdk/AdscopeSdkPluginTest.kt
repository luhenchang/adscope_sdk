package xyz.adscope.adscope_sdk

import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import org.junit.Test
import org.mockito.Mockito.*

class AdscopeSdkPluginTest {
    private fun binding(messenger: BinaryMessenger): FlutterPluginBinding {
        val binding = mock(FlutterPluginBinding::class.java, RETURNS_DEEP_STUBS)
        `when`(binding.binaryMessenger).thenReturn(messenger)
        return binding
    }

    @Test fun eachEngineRegistersItsOwnChannel() {
        val first = mock(BinaryMessenger::class.java)
        val second = mock(BinaryMessenger::class.java)
        AdscopeSdkPlugin().onAttachedToEngine(binding(first))
        AdscopeSdkPlugin().onAttachedToEngine(binding(second))
        verify(first).setMessageHandler(eq("adscope_sdk"), any())
        verify(second).setMessageHandler(eq("adscope_sdk"), any())
    }

    @Test fun detachingFirstEngineOnlyUnregistersItsOwnChannel() {
        val first = mock(BinaryMessenger::class.java)
        val second = mock(BinaryMessenger::class.java)
        val firstBinding = binding(first)
        val firstPlugin = AdscopeSdkPlugin()
        firstPlugin.onAttachedToEngine(firstBinding)
        AdscopeSdkPlugin().onAttachedToEngine(binding(second))
        clearInvocations(first, second)
        firstPlugin.onDetachedFromEngine(firstBinding)
        verify(first).setMessageHandler("adscope_sdk", null)
        verifyNoInteractions(second)
    }
}

class EngineOwnershipTest {
    @Test fun identicalAdIdsAreScopedToEngineAndDetachOnlyClearsOwner() {
        val first = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val second = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val firstView = mock(android.view.View::class.java)
        val secondView = mock(android.view.View::class.java)
        first.wrappers.addAdView("same-id", firstView)
        second.wrappers.addAdView("same-id", secondView)
        org.junit.Assert.assertSame(firstView, first.wrappers.getAdView("same-id"))
        org.junit.Assert.assertSame(secondView, second.wrappers.getAdView("same-id"))
        first.release()
        org.junit.Assert.assertNull(first.wrappers.getAdView("same-id"))
        org.junit.Assert.assertSame(secondView, second.wrappers.getAdView("same-id"))
    }

    @Test fun everyAdManagerAndUnifiedStoreBelongsToItsEngine() {
        val first = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val second = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        listOf(first.sdkInit to second.sdkInit, first.splash to second.splash,
            first.native to second.native, first.draw to second.draw,
            first.banner to second.banner, first.interstitial to second.interstitial,
            first.rewarded to second.rewarded, first.unifiedWrappers to second.unifiedWrappers,
            first.unifiedViews to second.unifiedViews).forEach { (a, b) ->
            org.junit.Assert.assertNotSame(a, b)
        }
    }

    @Test fun callbacksUseOriginMessengerAndQueuedCallbacksAreDroppedAfterDetach() {
        val queued = mutableListOf<Runnable>()
        val first = xyz.adscope.adscope_sdk.manager.AMPSEventManager { queued.add(it) }
        val second = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val a = mock(BinaryMessenger::class.java)
        val b = mock(BinaryMessenger::class.java)
        first.init(a)
        second.init(b)
        clearInvocations(a, b)
        first.sendMessageToFlutter("loadOk", mapOf("adInstanceId" to "same-id"))
        second.sendMessageToFlutter("loadOk", mapOf("adInstanceId" to "same-id"))
        verify(b).send(eq("adscope_sdk"), any(), isNull())
        verifyNoInteractions(a)
        first.release()
        clearInvocations(a, b)
        queued.forEach { it.run() }
        verifyNoInteractions(a, b)
        second.sendMessageToFlutter("loadOk", null)
        verify(b).send(eq("adscope_sdk"), any(), isNull())
    }

    @Test fun identicalAdInstanceIdsKeepSeparateSdkAdsAndDestroyOnlyDetachedEngine() {
        val first = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val second = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val firstAd = mock(xyz.adscope.amps.ad.banner.AMPSBannerAd::class.java)
        val secondAd = mock(xyz.adscope.amps.ad.banner.AMPSBannerAd::class.java)
        val field = xyz.adscope.adscope_sdk.manager.AMPSBannerManager::class.java
            .getDeclaredField("bannerAds").also { it.isAccessible = true }
        @Suppress("UNCHECKED_CAST")
        fun ads(owner: xyz.adscope.adscope_sdk.manager.AMPSEventManager) =
            field.get(owner.banner) as MutableMap<String, xyz.adscope.amps.ad.banner.AMPSBannerAd>
        ads(first)["same-instance-id"] = firstAd
        ads(second)["same-instance-id"] = secondAd
        org.junit.Assert.assertSame(firstAd, first.banner.getBannerAd("same-instance-id"))
        org.junit.Assert.assertSame(secondAd, second.banner.getBannerAd("same-instance-id"))
        first.release()
        verify(firstAd).destroy()
        verifyNoInteractions(secondAd)
        org.junit.Assert.assertSame(secondAd, second.banner.getBannerAd("same-instance-id"))
        org.junit.Assert.assertNull(first.banner.getBannerAd("same-instance-id"))
    }

    @Test fun nativeLoadCallbackAfterDetachCannotRepopulateOwnerStores() {
        val owner = xyz.adscope.adscope_sdk.manager.AMPSEventManager { it.run() }
        val manager = owner.native
        val method = manager.javaClass.getDeclaredMethod("buildNativeCallback", String::class.java)
            .also { it.isAccessible = true }
        val callback = method.invoke(manager, "same-instance-id") as
            xyz.adscope.amps.ad.nativead.AMPSNativeLoadEventListener
        owner.release()
        callback.onAmpsAdLoad(listOf(mock(xyz.adscope.amps.ad.nativead.inter.AMPSNativeAdExpressInfo::class.java)))
        val field = manager.javaClass.getDeclaredField("nativeAdIdMapByInstance")
            .also { it.isAccessible = true }
        org.junit.Assert.assertTrue((field.get(manager) as Map<*, *>).isEmpty())
    }

    @Test fun activityDetachAndConfigReattachAreScopedToPlugin() {
        val bindingA = mock(FlutterPluginBinding::class.java, RETURNS_DEEP_STUBS)
        val bindingB = mock(FlutterPluginBinding::class.java, RETURNS_DEEP_STUBS)
        val a = AdscopeSdkPlugin().also { it.onAttachedToEngine(bindingA) }
        val b = AdscopeSdkPlugin().also { it.onAttachedToEngine(bindingB) }
        val activityA = mock(android.app.Activity::class.java)
        val activityB = mock(android.app.Activity::class.java)
        val activityBindingA = mock(io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding::class.java)
        val activityBindingB = mock(io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding::class.java)
        `when`(activityBindingA.activity).thenReturn(activityA)
        `when`(activityBindingB.activity).thenReturn(activityB)
        a.onAttachedToActivity(activityBindingA)
        b.onAttachedToActivity(activityBindingB)
        a.onDetachedFromActivityForConfigChanges()
        org.junit.Assert.assertNull(a.engine!!.getActivity())
        org.junit.Assert.assertSame(activityB, b.engine!!.getActivity())
        a.onReattachedToActivityForConfigChanges(activityBindingA)
        org.junit.Assert.assertSame(activityA, a.engine!!.getActivity())
        a.onDetachedFromActivity()
        org.junit.Assert.assertNull(a.engine!!.getActivity())
        org.junit.Assert.assertSame(activityB, b.engine!!.getActivity())
    }
}
