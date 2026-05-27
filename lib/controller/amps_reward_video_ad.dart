import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';

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
    AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoCreate, _wrapArgs(config.toMap()));
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
    await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.rewardVideoLoad, _instanceOnlyArgs());
  }

  ///激励视频广预加载
  void preLoad() async {
    await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoPreLoad, _instanceOnlyArgs());
  }

  ///激励视频广告显示调用
  void showAd() async {
    await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoShowAd, _instanceOnlyArgs());
  }

  ///激励视频广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoIsReadyAd, _instanceOnlyArgs());
  }

  ///销毁视频广告
  destroy() async {
    RewardVideoCallbackRouter.instance.unregister(instanceId);
    AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.rewardVideoDestroyAd, _instanceOnlyArgs());
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetECPM, _instanceOnlyArgs());
  }

  ///添加预加载广告
  addPreLoadAdInfo() async {
    AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoAddPreLoadAdInfo, _instanceOnlyArgs());
  }

  ///获取MediaExtraInfo
  Future<dynamic> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetMediaExtraInfo, _instanceOnlyArgs());
  }
}