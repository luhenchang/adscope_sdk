import 'package:flutter/foundation.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../data/amps_native_interactive_listener.dart';
import 'amps_native_ad.dart';

/// Android / iOS 嵌入式商城。请求完成后以返回的 adId 创建 AMPSMallView。
/// 使用 config.mallQuery 传搜索词，config.mallReward 传可选频道奖励任务。
/// 兼容 config.customExtraMap 的 GM.userData 原始 JSON/搜索词。
class AMPSMallAd extends AMPSNativeAd {
  AMPSMallAd({
    required AdOptions config,
    AMPSNativeAdListener? onLoad,
    void Function(String adId, int code, Map<String, dynamic>? info)? onEvent,
    String? instanceId,
  }) : super(
            config: _requireSupportedPlatform(config),
            nativeType: NativeType.unified,
            mallMode: true,
            mCallBack: onLoad,
            onMallEvent: onEvent,
            instanceId: instanceId);

  static AdOptions _requireSupportedPlatform(AdOptions config) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      throw UnsupportedError('Embedded mall supports Android and iOS only');
    }
    return config;
  }

  Map<String, dynamic> _args(String adId) => {
        'adInstanceId': instanceId,
        'nativeType': NativeType.unified.value,
        'adId': adId,
      };

  /// 返回 supportsMall、viewCreated、isValid 与 extras（商品扩展字段）。
  /// 查询不创建视图，Android 的 supportsMall 在首次挂载前为 false。
  Future<Map<String, dynamic>> getMallInfo(String adId) async {
    final value = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeGetMallInfo, _args(adId));
    return (value as Map?)?.cast<String, dynamic>() ?? {};
  }

  /// 页面离开或商城不可见时传 false，恢复可见时传 true。
  Future<void> setVisible(String adId, bool visible) async {
    await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.nativeSetMallVisible,
        {..._args(adId), 'visible': visible});
  }
}
