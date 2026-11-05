import 'dart:convert';

/// 穿山甲商城激励任务，创建 Android / iOS 激励视频实例时使用。
///
/// 空字段会忽略；全部为空时按普通激励视频请求。值按字符串透传，
/// 金币数和时长应使用业务下发的数据，具体有效范围由原生 SDK 决定。
class AMPSGMMallRewardConfig {
  /// 任务奖励金币数，对应 ec_reward_gold。
  final String? gold;

  /// 任务浏览时长，单位秒，对应 ec_reward_duration。
  final String? duration;

  const AMPSGMMallRewardConfig({this.gold, this.duration});

  /// 生成原生商城接口要求的标准 JSON 数组；无有效字段时返回 null。
  String? toUserData() {
    final entries = <Map<String, String>>[];
    void append(String name, String? raw) {
      final value = raw?.trim();
      if (value != null && value.isNotEmpty) {
        entries.add({'name': name, 'value': value});
      }
    }

    append('ec_reward_gold', gold);
    append('ec_reward_duration', duration);
    return entries.isEmpty ? null : jsonEncode(entries);
  }
}
