import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';

import '../common.dart';

class AMPSRewardVideoAd {
  AdOptions config;
  RewardVideoCallBack? adCallBack;

  AMPSRewardVideoAd({required this.config, this.adCallBack}) {
    AdscopeSdk.channel.invokeListMethod(
        AMPSAdSdkMethodNames.rewardVideoCreate, config.toMap());

    setMethodCallHandler();
  }

  void setMethodCallHandler() {
    AdscopeSdk.channel.setMethodCallHandler(
          (call) async {
        switch (call.method) {
          case AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess:
            adCallBack?.onLoadSuccess?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onLoadFailure:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onLoadFailure?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onAdShow:
            adCallBack?.onAdShow?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onAdClicked:
            adCallBack?.onAdClicked?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onAdClosed:
            adCallBack?.onAdClosed?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onVideoPlayStart:
            adCallBack?.onVideoPlayStart?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd:
            adCallBack?.onVideoPlayEnd?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onVideoPlayError?.call(
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onVideoSkipToEnd:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onVideoSkipToEnd?.call(
                map[AMPSSdkCallBackParamsKey.playDurationMs]);
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onAdReward:
            adCallBack?.onAdReward?.call();
            break;
          case AMPSRewardedVideoCallBackChannelMethod.onAdCached:
            adCallBack?.onAdCached?.call();
            break;
        }
      },
    );
  }

  ///激励视频广告加载调用
  void load() async {
    await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.rewardVideoLoad);
  }

  ///激励视频广预加载
  void preLoad() async {
    await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoPreLoad);
  }

  ///激励视频广告显示调用
  void showAd() async {
    await AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoShowAd);
  }

  ///激励视频广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoIsReadyAd);
  }

  ///销毁视频广告
  Future<void> destroy() async {
    await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.rewardedVideoDestroyAd);
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetECPM);
  }

  ///添加预加载广告
  addPreLoadAdInfo() async {
     AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.rewardedVideoAddPreLoadAdInfo);
  }

  ///获取MediaExtraInfo
  addPreGetMediaExtraInfo() async {
    AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.rewardedVideoGetMediaExtraInfo);
  }
}