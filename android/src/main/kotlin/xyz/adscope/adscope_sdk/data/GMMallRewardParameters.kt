package xyz.adscope.adscope_sdk.data

import xyz.adscope.amps.common.AMPSConstants

/** 商城是可选的新 SDK 功能，读取实际 SDK 常量以兼容未接入商城的旧宿主。 */
internal object GMMallRewardParameters {
    fun merge(
        extraData: Map<String, String>?,
        userData: String?,
        sdkConstants: Class<*> = AMPSConstants::class.java
    ): HashMap<String, String>? {
        if (userData.isNullOrEmpty()) return extraData?.let { HashMap(it) }
        val key = try {
            sdkConstants.getField("AMPS_ADN_GM_SHOP_EXTRA_DATA").get(null) as? String
        } catch (error: ReflectiveOperationException) {
            null
        }
        if (key.isNullOrEmpty()) {
            throw UnsupportedOperationException(
                "Mall rewards require an AMPS SDK exposing AMPS_ADN_GM_SHOP_EXTRA_DATA " +
                    "and a GroMore adapter with mall support."
            )
        }
        return HashMap(extraData ?: emptyMap()).apply { put(key, userData) }
    }
}
