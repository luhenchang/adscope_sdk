package xyz.adscope.adscope_sdk.view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SplashFactory(binaryMessenger: BinaryMessenger, instance: StandardMessageCodec) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    val mBinaryMessenger: BinaryMessenger = binaryMessenger
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return AMPSSplashView(context, viewId, mBinaryMessenger, args)
    }
}