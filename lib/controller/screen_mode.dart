///提供给Android使用
/// 屏幕广告区域模式 (Splash Ad Display Mode)
/// 用于定义开屏广告 View 的绘制边界和高度计算方式。
enum ScreenMode {
  /// 0. 全屏填充区域 (FULL_FILL)：
  /// 广告占据整个屏幕的物理像素区域 (Real Screen Size)。
  /// 适用于隐藏所有系统栏的沉浸式体验。
  /// 计算高度：Real Screen Height
  fullScreen(0),

  /// 1. 顶部安全区域 (TOP_SAFE_REGION)：
  /// 广告绘制区域在状态栏下方，但延伸至屏幕最底。
  /// 计算高度：Real Screen Height - Status Bar Height (MediaQueryData.padding.top)
  statusBarVisible(1),

  /// 2. 底部安全区域 (BOTTOM_SAFE_REGION)：
  /// 广告绘制区域从屏幕最顶开始，截止到底部导航/手势区域上方。
  /// 计算高度：Real Screen Height - Navigation Bar Height (MediaQueryData.padding.bottom)
  statusNavBarVisible(2),

  /// 3. 全部安全区域 (ALL_SAFE_REGION)：
  /// 广告绘制区域在状态栏下方，截止到导航栏上方。
  /// 这是最安全的模式，避开所有系统安全区域。
  /// 计算高度：Real Screen Height - Status Bar Height - Navigation Bar Height
  statusNavAndBarVisible(3);

  // 为每个枚举值添加 value
  final int value;

  const ScreenMode(this.value);
}