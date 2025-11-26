package xyz.adscope.adscope_sdk.utils

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper

fun Context.asActivity(): Activity? {
    var currentContext = this
    while (currentContext is ContextWrapper) {
        if (currentContext is Activity) {
            return currentContext
        }
        currentContext = currentContext.baseContext
    }
    return null
}