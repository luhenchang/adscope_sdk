package xyz.adscope.adscope_sdk.utils

import android.os.Handler
import android.os.Looper

/** Stateless UI dispatch shared by the engine-local owners. */
object FlutterPluginUtil {
    @JvmStatic
    fun runOnUiThread(runnable: Runnable) {
        if (Looper.getMainLooper() == Looper.myLooper()) {
            runnable.run()
        } else {
            Handler(Looper.getMainLooper()).post(runnable)
        }
    }
}
