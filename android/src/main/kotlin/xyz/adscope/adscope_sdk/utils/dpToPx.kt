package xyz.adscope.adscope_sdk.utils
import android.content.Context
import android.util.TypedValue

// dp 到 px 的转换扩展函数
fun Number.dpToPx(context: Context): Int {
    val density = context.resources.displayMetrics.density
    return if (this == 0) 0 else (this.toFloat() * density + 0.5f).toInt()
}

fun Number.spToPx(context: Context): Float {
    return TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_SP,  // 单位为sp
        this.toFloat(),                     // 要转换的sp值
        context.resources.displayMetrics  // 设备的显示度量
    );
}