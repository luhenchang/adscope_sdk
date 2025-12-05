enum AMPSUnifiedPattern {
  /// 图文广告样式（value: 0）
  adPatternTextImage(0),

  /// 三图广告样式（value: 1）
  adPattern3Images(1),

  /// 视频广告样式（value: 2）
  adPatternVideo(2),

  /// 未知广告样式（value: 3）
  adPatternUnknown(3);

  // 新增 int 类型 value
  final int value;

  // 构造函数赋值
  const AMPSUnifiedPattern(this.value);

  /// 根据 value 解析枚举（核心新增方法）
  static AMPSUnifiedPattern fromValue(int value) {
    switch (value) {
      case 0:
        return adPatternTextImage;
      case 1:
        return adPattern3Images;
      case 2:
        return adPatternVideo;
      case 3:
        return adPatternUnknown;
      default:
      // 非法 value 默认为未知类型
        return adPatternUnknown;
    }
  }
}