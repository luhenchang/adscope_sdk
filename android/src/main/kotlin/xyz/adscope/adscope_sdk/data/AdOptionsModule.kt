package xyz.adscope.adscope_sdk.data

import android.app.Activity
import android.content.Context
import xyz.adscope.adscope_sdk.utils.dpToPx
import xyz.adscope.amps.config.AMPSRequestParameters
import xyz.adscope.amps.tool.util.AMPSScreenUtil

// 定义键名常量
object AdOptionKeys {
    const val KEY_SPACE_ID = "spaceId"
    const val KEY_TIMEOUT_INTERVAL = "timeoutInterval"
    const val KEY_EXPRESS_SIZE = "expressSize"
    const val KEY_USER_ID = "userId"
    const val KEY_EXTRA = "extra"
}

object AdOptionsModule {

    @Suppress("UNCHECKED_CAST")
    fun getAdOptionFromMap(map: Map<String, Any?>?, context: Activity): AMPSRequestParameters {
        val builder = AMPSRequestParameters.Builder()
        if (map == null) {
            return builder.build()
        }

        val spaceId = map[AdOptionKeys.KEY_SPACE_ID] as? String ?: ""
        val timeoutInterval = map[AdOptionKeys.KEY_TIMEOUT_INTERVAL] as? Number
        val userId = map[AdOptionKeys.KEY_USER_ID] as? String
        val extra = map[AdOptionKeys.KEY_EXTRA] as? String
        val expressSize = map[AdOptionKeys.KEY_EXPRESS_SIZE] as? ArrayList<Int>

        builder.setSpaceId(spaceId)
        if (userId != null) {
            builder.setUserId(userId)
        }
        if (extra != null) {
            builder.setExtraData(extra)
        }
        if (timeoutInterval != null) {
            builder.setTimeOut(timeoutInterval.toInt())
        }
        builder.setWidth(AMPSScreenUtil.getScreenWidth(context))
        builder.setHeight(AMPSScreenUtil.getScreenHeight(context))
        if (expressSize != null && expressSize.isNotEmpty()) {
            if (expressSize[0] > 0) {
                builder.setWidth(expressSize[0].dpToPx(context))
            }
            if (expressSize[1] > 0) {
                builder.setHeight(expressSize[1].dpToPx(context))
            }
        }
        return builder.build()
    }

    @Suppress("UNCHECKED_CAST")
    fun getNativeAdOptionFromMap(map: Map<String, Any?>?, context: Context): AMPSRequestParameters {
        val builder = AMPSRequestParameters.Builder()
        if (map == null) {
            return builder.build()
        }

        val spaceId = map[AdOptionKeys.KEY_SPACE_ID] as? String ?: ""
        val timeoutInterval = map[AdOptionKeys.KEY_TIMEOUT_INTERVAL] as? Number
        val express = map[AdOptionKeys.KEY_EXPRESS_SIZE] as? ArrayList<Double>
        val userId = map[AdOptionKeys.KEY_USER_ID] as? String
        val extra = map[AdOptionKeys.KEY_EXTRA] as? String


        builder.setSpaceId(spaceId)
        if (userId != null) {
            builder.setUserId(userId)
        }
        if (extra != null) {
            builder.setExtraData(extra)
        }
        if (timeoutInterval != null) {
            builder.setTimeOut(timeoutInterval.toInt())
        }
        if (express != null && express.isNotEmpty()) {
            builder.setWidth(express[0].dpToPx(context))
        }
        if (express != null && express.size > 1) {
            builder.setHeight(express[1].dpToPx(context))
        }
        return builder.build()
    }
}
