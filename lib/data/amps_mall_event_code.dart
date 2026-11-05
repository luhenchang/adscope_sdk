/// 商城渠道事件码，通过 AMPSMallAd.onEvent 返回。
class AMPSMallEventCode {
  AMPSMallEventCode._();

  /// 商城浏览任务奖励事件，表示 SDK 通知任务奖励，可由业务处理发奖。
  ///
  /// Android：TTAdConstant.AD_EVENT_FEED_REWARD；
  /// iOS：BUNativeAdEventCode_SendFeedReward。
  static const int feedReward = 2;

  /// 商城滚动到边界，info['bound'] 取值见 AMPSMallScrollBound。
  /// Android 对应 TTAdConstant.AD_EVENT_MALL_REACH_BOUND，iOS 同为 200。
  static const int reachBound = 200;
}

/// 商城 reachBound 事件中 info['bound'] 的取值。
class AMPSMallScrollBound {
  AMPSMallScrollBound._();

  /// 到达顶部。
  static const int top = 1;

  /// 到达底部。
  static const int bottom = 2;
}
