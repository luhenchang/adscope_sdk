package xyz.adscope.adscope_sdk.utils

import org.json.JSONArray
import org.json.JSONObject

/** 渠道extras可能包含JSONObject，转成Flutter标准编解码器可接受的值。 */
internal fun flutterCodecValue(value: Any?): Any? {
    if (value == null || value === JSONObject.NULL) return null
    return when (value) {
        is String, is Boolean, is Int, is Long, is Double, is Float, is ByteArray -> value
        is Number -> value.toDouble()
        is CharSequence -> value.toString()
        is JSONObject -> value.keys().asSequence().associateWith { flutterCodecValue(value.opt(it)) }
        is JSONArray -> (0 until value.length()).map { flutterCodecValue(value.opt(it)) }
        is Map<*, *> -> value.entries.associate { it.key.toString() to flutterCodecValue(it.value) }
        is Iterable<*> -> value.map { flutterCodecValue(it) }
        is Array<*> -> value.map { flutterCodecValue(it) }
        else -> value.toString()
    }
}
