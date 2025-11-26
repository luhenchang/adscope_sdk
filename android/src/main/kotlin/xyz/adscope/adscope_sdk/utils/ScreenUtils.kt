package xyz.adscope.adscope_sdk.utils

import android.R
import android.app.Activity
import android.content.Context
import android.graphics.Point
import android.graphics.Rect
import android.os.Build
import android.util.TypedValue
import android.view.WindowInsets
import androidx.annotation.Px

object ScreenUtils {

    /**
     * 获取屏幕的真实像素高度（包含状态栏和导航栏）。
     */
    fun getRealScreenHeight(activity: Activity): Int {
        val size = Point()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val metrics = activity.windowManager.currentWindowMetrics
            size.x = metrics.bounds.width()
            size.y = metrics.bounds.height()
        } else {
            @Suppress("DEPRECATION")
            val display = activity.windowManager.defaultDisplay
            @Suppress("DEPRECATION")
            display.getRealSize(size)
        }
        return size.y
    }

    /**
     * 获取状态栏的高度 (Status Bar)。
     * 适用于大多数 Android 版本。
     */
    @Px
    fun getStatusBarHeight(context: Context): Int {
        var result = 0
        val resourceId = context.resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) {
            result = context.resources.getDimensionPixelSize(resourceId)
        }
        return result
    }

    /**
     * 获取底部导航栏的高度 (Navigation Bar)。
     * 注意：如果设备没有虚拟导航栏（如使用手势导航或硬件按键），此方法返回 0。
     */
    @Px
    fun getNavigationBarHeight(context: Context): Int {
        var result = 0
        val resourceId = context.resources.getIdentifier("navigation_bar_height", "dimen", "android")
        if (resourceId > 0) {
            result = context.resources.getDimensionPixelSize(resourceId)
        }
        // 进一步判断：通过比较实际尺寸和可用尺寸来确定导航栏是否存在
        // 这是一个复杂的判断，为了简洁，这里主要依赖资源ID，但请注意其局限性。
        // 在实际项目中，需要更复杂的逻辑判断导航栏是否可见/存在。
        return result
    }

    /**
     * 获取 Activity 标题栏/Action Bar 的高度。
     * (如果 Activity 使用了 NoActionBar 主题，此方法可能返回 0)
     */
    @Px
    fun getTitleBarHeight(activity: Activity): Int {
        val tv = TypedValue()
        // 查找主题中定义的 Action Bar 尺寸
        if (activity.theme.resolveAttribute(R.attr.actionBarSize, tv, true)) {
            return TypedValue.complexToDimensionPixelSize(tv.data, activity.resources.displayMetrics)
        }
        return 0
    }

    /**
     * 获取应用可见内容区域的顶部 Y 坐标。
     * 它可以用来获取状态栏+标题栏的总高度 (即 Rect.top)。
     */
    @Px
    fun getContentTopOffset(activity: Activity): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val insets = activity.windowManager.currentWindowMetrics.windowInsets
            // 获取系统栏（状态栏+标题栏）的顶部高度
            return insets.getInsets(WindowInsets.Type.systemBars()).top
        } else {
            val rectangle = Rect()
            @Suppress("DEPRECATION")
            activity.window.decorView.getWindowVisibleDisplayFrame(rectangle)
            // Rect.top 返回的是可见内容区域相对于屏幕顶部的偏移量，
            // 在非全屏模式下，通常是状态栏 + 标题栏的高度。
            return rectangle.top
        }
    }
}
