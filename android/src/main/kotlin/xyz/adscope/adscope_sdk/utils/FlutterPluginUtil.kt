package xyz.adscope.adscope_sdk.utils

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.os.Looper

import java.lang.ref.WeakReference

object FlutterPluginUtil {
    private var activityWeakRef: WeakReference<Activity>? = null

    /**
     * Update the current Activity reference (store as WeakReference)
     * Call this in your Flutter plugin's onAttachedToActivity/onDetachedFromActivity
     */
    @JvmStatic
    fun setActivity(activity: Activity?) {
        activityWeakRef = activity?.let { WeakReference(it) }
    }

    /**
     * Get the current Activity (may be null if destroyed)
     */
    @JvmStatic
    fun getActivity(): Activity? {
        // WeakReference.get() returns null if the Activity is garbage collected
        return activityWeakRef?.get()
    }

    /**
     * Get ApplicationContext (safe: ApplicationContext lives entire app lifecycle)
     */
    @JvmStatic
    fun getApplicationContext(): Context? {
        return try {
            // Priority 1: Get from Activity (if alive)
            getActivity()?.applicationContext
                ?: // Priority 2: Fallback (if no Activity, use system Context - rare)
                getSystemApplicationContext()
        } catch (t: Throwable) {
            t.printStackTrace()
            null
        }
    }

    /**
     * Safe UI thread execution (avoids Activity reference leaks)
     */
    @JvmStatic
    fun runOnUiThread(runnable: Runnable) {
        try {
            if (Looper.getMainLooper() == Looper.myLooper()) {
                runnable.run()
            } else {
                getActivity()?.runOnUiThread(runnable)
                    getApplicationContext()?.mainLooper?.let { looper ->
                        android.os.Handler(looper).post(runnable)
                    }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * Fallback to system ApplicationContext (rarely needed)
     * Only use if no Activity is available
     */
    @SuppressLint("PrivateApi")
    private fun getSystemApplicationContext(): Context? {
        return try {
            // Get ApplicationContext via system class (avoids static Context leaks)
            Class.forName("android.app.ActivityThread")
                .getMethod("currentApplication")
                .invoke(null) as? Context
        } catch (t: Throwable) {
            t.printStackTrace()
            null
        }
    }
}