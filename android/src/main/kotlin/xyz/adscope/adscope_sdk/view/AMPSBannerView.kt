package xyz.adscope.adscope_sdk.view

import android.content.Context
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import xyz.adscope.adscope_sdk.data.NATIVE_HEIGHT
import xyz.adscope.adscope_sdk.data.NATIVE_WIDTH
import xyz.adscope.adscope_sdk.manager.AMPSBannerManager
import xyz.adscope.adscope_sdk.utils.dpToPx

const val BannerTAG = "AMPSBannerView"
class AMPSBannerView(
    private val context: Context,
    viewId: Int,
    binaryMessenger: BinaryMessenger,
    args: Any?
) : PlatformView {
    private val platformViewContainer: FrameLayout = FrameLayout(context)
    init {
        val creationArgs = parseCreationArgs(args)
        val adContainer = FrameLayout(context).apply {
            layoutParams = createAdContainerParams(creationArgs)
        }

        // 3. Add the ad container to the main platform view.
        platformViewContainer.addView(adContainer)

        // 4. Show the ad inside the dedicated, centered container.
        showAdInContainer(adContainer)
    }

    /**
     * Parses creation arguments from Flutter.
     */
    private fun parseCreationArgs(args: Any?): Map<*, *> {
        return args as? Map<*, *> ?: emptyMap<Any, Any>()
    }

    /**
     * Creates LayoutParams for the ad container, setting its size and centering it.
     */
    private fun createAdContainerParams(args: Map<*, *>): FrameLayout.LayoutParams {
        val nativeWidth = args[NATIVE_WIDTH] as? Double
        val nativeHeight = args[NATIVE_HEIGHT] as? Double
        val widthPx = nativeWidth?.takeIf { it > 0 }?.toInt()?.dpToPx(context)
            ?: FrameLayout.LayoutParams.WRAP_CONTENT
        val heightPx = nativeHeight?.takeIf { it > 0 }?.toInt()?.dpToPx(context)
            ?: FrameLayout.LayoutParams.WRAP_CONTENT

        return FrameLayout.LayoutParams(widthPx, heightPx).apply {
            gravity = Gravity.LEFT
        }
    }

    /**
     * Gets the banner ad from the manager and shows it in the provided container.
     */
    private fun showAdInContainer(container: FrameLayout) {
        runCatching {
            AMPSBannerManager.getInstance().getBannerAd()?.show(container)
        }.onFailure {
            Log.e(BannerTAG, "Failed to show banner ad", it)
        }
    }

    override fun getView(): View {
        return platformViewContainer
    }

    override fun dispose() {
        platformViewContainer.removeAllViews()
    }
}
