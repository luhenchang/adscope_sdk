package xyz.adscope.adscope_sdk.data

/**
 * 定义开屏广告的显示区域类型，用于指导如何计算广告View的尺寸。
 */
enum class SplashAdDisplayType(val value: Int) {
    /**
     * 全屏模式：广告占据整个屏幕的物理像素区域 (Real Screen Size)，
     * 状态栏和导航栏都被隐藏（或内容绘制在其后）。
     * 计算高度：Real Screen Height
     */
    FULL_SCREEN(0),

    /**
     * 有状态栏模式：广告区域从状态栏下方开始，延伸至屏幕底部。
     * 通常在 Activity 使用 NoActionBar/NoTitleBar 主题时使用。
     * 计算高度：Real Screen Height - Status Bar Height
     */
    STATUS_BAR_VISIBLE(1),

    /**
     * 有导航栏模式：广告区域截止到屏幕底导航栏区域上边。
     * 通常在 Activity 使用 ActionBar 主题时使用。
     * 计算高度：Real Screen Height - Navigation Bar Height
     */
    STATUS_NAV_BAR_VISIBLE(2),
    /**
     * 有状态栏和导航栏模式：广告区域从状态栏下方开始，延伸至导航栏上方。
     * 这是最保守的模式，确保广告内容不与任何系统UI重叠。
     * 计算高度：Real Screen Height - Status Bar Height - Navigation Bar Height
     */
    STATUS_AND_NAV_BAR_VISIBLE(3)
}