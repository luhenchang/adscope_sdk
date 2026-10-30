package xyz.adscope.adscope_sdk

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Test
import org.mockito.Mockito.*
import xyz.adscope.adscope_sdk.data.AD_INSTANCE_ID
import xyz.adscope.adscope_sdk.data.AMPSAdSdkMethodNames
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import xyz.adscope.amps.ad.interstitial.AMPSInterstitialAd
import xyz.adscope.amps.ad.reward.AMPSRewardVideoAd

class DetachedActivityShowTest {
    private fun putAd(manager: Any, field: String, ad: Any) {
        val storage = manager.javaClass.getDeclaredField(field).also { it.isAccessible = true }
        @Suppress("UNCHECKED_CAST")
        (storage.get(manager) as MutableMap<String, Any>)["same-id"] = ad
    }

    @Test fun rewardedShowWithoutOwningActivityCompletesWithErrorInsteadOfHanging() {
        val owner = AMPSEventManager { it.run() }
        val siblingActivity = mock(Activity::class.java)
        val sibling = AMPSEventManager { it.run() }.also { it.setActivity(siblingActivity) }
        val ad = mock(AMPSRewardVideoAd::class.java)
        putAd(owner.rewarded, "rewardedVideoAds", ad)
        val result = mock(MethodChannel.Result::class.java)
        owner.onMethodCall(MethodCall(AMPSAdSdkMethodNames.REWARDED_VIDEO_SHOW_AD,
            mapOf(AD_INSTANCE_ID to "same-id")), result)
        verify(result).error(eq("SHOW_FAILED"), anyString(), isNull())
        verifyNoMoreInteractions(result)
        verifyNoInteractions(ad)
        org.junit.Assert.assertSame(siblingActivity, sibling.getActivity())
    }

    @Test fun interstitialShowAfterActivityDetachDoesNotPassNullToNativeSdk() {
        val owner = AMPSEventManager { it.run() }
        owner.setActivity(mock(Activity::class.java))
        owner.setActivity(null)
        val ad = mock(AMPSInterstitialAd::class.java)
        putAd(owner.interstitial, "interstitialAds", ad)
        val result = mock(MethodChannel.Result::class.java)
        owner.onMethodCall(MethodCall(AMPSAdSdkMethodNames.INTERSTITIAL_SHOW_AD,
            mapOf(AD_INSTANCE_ID to "same-id")), result)
        verify(result).error(eq("SHOW_FAILED"), anyString(), isNull())
        verifyNoMoreInteractions(result)
        verifyNoInteractions(ad)
    }
}
