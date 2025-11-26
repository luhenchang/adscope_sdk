/// 广告视频播放配置
class AMPSAdVideoPlayConfig {
  /// 是否启用视频声音（可选）
  final bool? videoSoundEnable;

  /// 视频自动播放类型（可选）
  /// 对应原 TypeScript 中的 number 类型，使用 Dart 的 int 类型。
  final int? videoAutoPlayType;

  /// 视频是否循环重播（可选）
  final bool? videoLoopReplay;

  /// 构造函数，所有参数均可选且命名。
  const AMPSAdVideoPlayConfig({
    this.videoSoundEnable,
    this.videoAutoPlayType,
    this.videoLoopReplay,
  });

  /// 将对象转换为 Map<String, dynamic> 格式（常用于方法通道或 JSON 序列化）。
  Map<String, dynamic> toJson() {
    // 仅包含非空字段，保持与可选接口的语义一致
    final Map<String, dynamic> data = {};
    if (videoSoundEnable != null) {
      data['videoSoundEnable'] = videoSoundEnable;
    }
    if (videoAutoPlayType != null) {
      data['videoAutoPlayType'] = videoAutoPlayType;
    }
    if (videoLoopReplay != null) {
      data['videoLoopReplay'] = videoLoopReplay;
    }
    return data;
  }
}
