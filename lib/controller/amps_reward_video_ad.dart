import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/services.dart';

import '../common.dart';
import 'reward_video_callback_router.dart';

class AMPSRewardVideoAd {
  static int _instanceCounter = 0;
  final String instanceId;
  AdOptions config;
  RewardVideoCallBack? adCallBack;

  AMPSRewardVideoAd({required this.config, this.adCallBack, String? instanceId})
      : instanceId = instanceId ?? _generateInstanceId() {
    RewardVideoCallbackRouter.instance.register(this.instanceId, adCallBack);
    _createNativeAd();
  }

  ///创建原生广告实例，失败时通过onLoadFailure通知，避免静默失败
  Future<void> _createNativeAd() async {
    try {
      await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoCreate, _wrapArgs(config.toMap()));
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///将原生端返回的错误转发给onLoadFailure回调
  void _notifyLoadFailure(PlatformException e) {
    adCallBack?.onLoadFailure?.call(int.tryParse(e.code) ?? -1, e.message ?? e.code);
  }

  ///将展示阶段的错误转发给onVideoPlayError回调，避免show失败后业务方无感知
  void _notifyShowFailure(PlatformException e) {
    adCallBack?.onVideoPlayError?.call(int.tryParse(e.code) ?? -1, e.message ?? e.code);
  }

  static String _generateInstanceId() {
    _instanceCounter += 1;
    return 'reward_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _wrapArgs(Map<dynamic, dynamic> args) {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      ...args,
    };
  }

  Map<String, dynamic> _instanceOnlyArgs() {
    return {AMPSAdInstanceKey.adInstanceId: instanceId};
  }

  ///激励视频广告加载调用
  void load() async {
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.rewardVideoLoad, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///激励视频广预加载
  void preLoad() async {
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.rewardVideoPreLoad, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///激励视频广告显示调用，失败时通过onVideoPlayError通知，避免静默失败
  void showAd() async {
    try {
      await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoShowAd, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyShowFailure(e);
    }
  }

  ///激励视频广告是否有预加载，异常时返回false
  Future<bool> isReadyAd() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoIsReadyAd, _instanceOnlyArgs()) ?? false;
    } on PlatformException {
      return false;
    }
  }

  ///销毁视频广告
  destroy() async {
    RewardVideoCallbackRouter.instance.unregister(instanceId);
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.rewardVideoDestroyAd, _instanceOnlyArgs());
    } on PlatformException {
      // 销毁失败不影响业务流程，但不能抛出未捕获异常
    }
  }

  ///获取ecpm，异常时返回0
  Future<num> getECPM() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetECPM, _instanceOnlyArgs()) ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  ///获取胜出渠道的seatId，异常时返回null
  Future<String?> getSeatId() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetSeatId, _instanceOnlyArgs());
    } on PlatformException {
      return null;
    }
  }

  ///添加预加载广告
  addPreLoadAdInfo() async {
    try {
      await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoAddPreLoadAdInfo, _instanceOnlyArgs());
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///获取MediaExtraInfo，异常时返回null
  Future<dynamic> addPreGetMediaExtraInfo() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetMediaExtraInfo, _instanceOnlyArgs());
    } on PlatformException {
      return null;
    }
  }
}