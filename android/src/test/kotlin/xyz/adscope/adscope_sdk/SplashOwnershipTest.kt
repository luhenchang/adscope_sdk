package xyz.adscope.adscope_sdk

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Test
import org.mockito.Mockito.*
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.data.SPLASH_INSTANCE_ID
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.amps.ad.splash.AMPSSplashAd

class SplashOwnershipTest {
    private fun withSplashShown(check: (AMPSEventManager, ViewGroup, View, View) -> Unit) {
        val owner = AMPSEventManager { it.run() }
        val activity = mock(Activity::class.java)
        val content = mock(ViewGroup::class.java)
        val siblingOverlay = mock(View::class.java)
        `when`(activity.findViewById<ViewGroup>(android.R.id.content)).thenReturn(content)
        `when`(content.findViewWithTag<View>(anyString())).thenReturn(siblingOverlay)
        owner.setActivity(activity)
        val ad = mock(AMPSSplashAd::class.java)
        `when`(ad.isReady).thenReturn(true)
        val manager = owner.splash
        val field = manager.javaClass.getDeclaredField("splashAds").also { it.isAccessible = true }
        @Suppress("UNCHECKED_CAST")
        (field.get(manager) as MutableMap<String, AMPSSplashAd>)["same-id"] = ad
        mockConstruction(RelativeLayout::class.java) { view, _ ->
            `when`(view.parent).thenReturn(content)
        }.use { containers ->
            mockConstruction(FrameLayout::class.java).use {
                mockConstruction(ViewGroup.LayoutParams::class.java).use {
                    mockConstruction(RelativeLayout.LayoutParams::class.java).use {
                        manager.handleMethodCall(MethodCall(AMPSAdSdkMethodNames.SPLASH_SHOW_AD,
                            mapOf(SPLASH_INSTANCE_ID to "same-id")), mock(MethodChannel.Result::class.java))
                        check(owner, content, containers.constructed().single(), siblingOverlay)
                    }
                }
            }
        }
    }

    @Test fun detachRemovesOwnedSplashOverlayEvenAfterActivityIsCleared() = withSplashShown { owner, content, overlay, _ ->
        owner.release()
        verify(content).removeView(overlay)
    }

    @Test fun sameIdInSharedActivityDoesNotRemoveSiblingOverlay() = withSplashShown { _, content, _, sibling ->
        verify(content, never()).removeView(sibling)
    }
}
