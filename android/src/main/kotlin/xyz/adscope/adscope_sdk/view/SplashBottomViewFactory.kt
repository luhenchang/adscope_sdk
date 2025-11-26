package xyz.adscope.adscope_sdk.view
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.TypedValue
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.example.amps_sdk.data.SplashBottomModule
import androidx.core.graphics.toColorInt


object SplashBottomViewFactory {

    /**
     * 根据 SplashBottomModule 数据动态创建一个 RelativeLayout 作为自定义底部视图。
     *
     * @param context Context
     * @param bottomModule 包含自定义底部视图数据的 SplashBottomModule 实例。
     * @return 配置好的 RelativeLayout，如果 bottomModule 未初始化或无效则返回 null。
     */
    fun createSplashBottomLayout(context: Context, bottomModule: SplashBottomModule?): RelativeLayout? {
        if (bottomModule == null || !bottomModule.initialized) {
            println("SplashBottomViewFactory: SplashBottomModule is null or not initialized.")
            return null
        }

        val displayMetrics = context.resources.displayMetrics

        // 1. 创建父容器 RelativeLayout
        val parentLayout = RelativeLayout(context)
        val moduleHeightPx = (bottomModule.height * displayMetrics.density).toInt()
        parentLayout.layoutParams = RelativeLayout.LayoutParams(
            RelativeLayout.LayoutParams.MATCH_PARENT,
            moduleHeightPx
        )

        try {
            parentLayout.setBackgroundColor(bottomModule.backgroundColor.toColorInt())
        } catch (e: IllegalArgumentException) {
            println("SplashBottomViewFactory: Invalid background color string: ${bottomModule.backgroundColor}. Using transparent.")
            parentLayout.setBackgroundColor(Color.TRANSPARENT)
        }

        // 2. 添加图片子视图 (如果存在)
        bottomModule.imgChildren?.let { imgChild ->
            val imageView = ImageView(context)
            val flutterAssetPath = "flutter_assets/${imgChild.imagePath}"
            val inputStream = context.assets.open(flutterAssetPath)
            // 将文件流解码为 Bitmap 对象
            val bitmap: Bitmap = BitmapFactory.decodeStream(inputStream)
            imageView.setBackgroundColor(Color.LTGRAY) // 临时占位符颜色
            imageView.scaleType = ImageView.ScaleType.FIT_CENTER // 或其他适合的 ScaleType
            imageView.setImageBitmap(bitmap)
            val imgParams = RelativeLayout.LayoutParams(
                (imgChild.width?.let { it * displayMetrics.density } ?: RelativeLayout.LayoutParams.WRAP_CONTENT).toInt(),
                (imgChild.height?.let { it * displayMetrics.density } ?: RelativeLayout.LayoutParams.WRAP_CONTENT).toInt()
            )
            // 设置边距来模拟 x, y 坐标 (相对于父 RelativeLayout 的左上角)
            imgParams.leftMargin = (imgChild.x?.let { it * displayMetrics.density } ?: 0.0).toInt()
            imgParams.topMargin = (imgChild.y?.let { it * displayMetrics.density } ?: 0.0).toInt()
            // 如果 x, y 代表的是中心点或其他对齐方式，需要调整这里的逻辑

            parentLayout.addView(imageView, imgParams)
        }

        // 3. 添加文本子视图 (如果存在)
        bottomModule.textChildren?.let { textChild ->
            val textView = TextView(context)
            textView.text = textChild.text ?: ""

            textChild.color?.let {
                try {
                    textView.setTextColor(it.toColorInt())
                } catch (e: IllegalArgumentException) {
                    println("SplashBottomViewFactory: Invalid text color string: $it")
                    textView.setTextColor(Color.BLACK) // 默认颜色
                }
            }

            textChild.fontSize?.let {
                textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, it.toFloat()) // 假设 fontSize 是 sp 单位
            }
            val textParams = RelativeLayout.LayoutParams(
                RelativeLayout.LayoutParams.WRAP_CONTENT, // 文本通常根据内容自适应宽度和高度
                RelativeLayout.LayoutParams.WRAP_CONTENT  // 或者你可以从 textChild 获取固定的宽高
            )
            textParams.leftMargin = (textChild.x?.let { it * displayMetrics.density } ?: 0.0).toInt()
            textParams.topMargin = (textChild.y?.let { it * displayMetrics.density } ?: 0.0).toInt()
            parentLayout.addView(textView, textParams)
        }

        return parentLayout
    }
}
