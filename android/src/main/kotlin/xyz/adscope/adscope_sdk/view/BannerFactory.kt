package xyz.adscope.adscope_sdk.view

import android.content.Context
import xyz.adscope.adscope_sdk.manager.AMPSEventManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class BannerFactory(binaryMessenger: BinaryMessenger, instance: StandardMessageCodec, private val engine: AMPSEventManager) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    val mBinaryMessenger: BinaryMessenger = binaryMessenger
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return AMPSBannerView(context, viewId, mBinaryMessenger, args, engine)
    }
}