package xyz.adscope.adscope_sdk.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory

data class FlutterAssetBitmap(
    val bitmap: Bitmap,
    val assetScale: Float,
)

object FlutterAssetLoader {
    fun loadImage(context: Context, imagePath: String?): FlutterAssetBitmap? {
        if (imagePath.isNullOrBlank()) {
            return null
        }

        val assetPath = "flutter_assets/$imagePath"
        val lastSlash = assetPath.lastIndexOf('/')
        val dir = if (lastSlash >= 0) assetPath.substring(0, lastSlash) else ""
        val fileName = if (lastSlash >= 0) assetPath.substring(lastSlash + 1) else assetPath

        val density = context.resources.displayMetrics.density
        val variants = when {
            density >= 3f -> listOf("3.0x" to 3f, "2.0x" to 2f, "" to 1f)
            density >= 2f -> listOf("2.0x" to 2f, "" to 1f)
            else -> listOf("" to 1f)
        }

        for ((variant, scale) in variants) {
            val path = if (variant.isEmpty()) assetPath else "$dir/$variant/$fileName"
            try {
                context.assets.open(path).use { stream ->
                    BitmapFactory.decodeStream(stream)?.let { bitmap ->
                        return FlutterAssetBitmap(bitmap, scale)
                    }
                }
            } catch (_: Exception) {
                // 尝试下一个分辨率目录
            }
        }
        return null
    }

    fun logicalWidthPx(context: Context, bitmap: Bitmap, assetScale: Float): Int {
        val density = context.resources.displayMetrics.density
        return (bitmap.width / assetScale * density + 0.5f).toInt()
    }

    fun logicalHeightPx(context: Context, bitmap: Bitmap, assetScale: Float): Int {
        val density = context.resources.displayMetrics.density
        return (bitmap.height / assetScale * density + 0.5f).toInt()
    }
}
