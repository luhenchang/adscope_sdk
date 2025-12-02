

import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';

import '../common.dart';

class AMPSRewardVideoAd {
  AdOptions config;
  AdCallBack? adCallBack;

  AMPSRewardVideoAd({required this.config,this.adCallBack}){
    AdscopeSdk.channel.invokeListMethod(AMPSAdSdkMethodNames.rewardVideoCreate,config.toMap());
    
    setMethodCallHandler();
  }
  void setMethodCallHandler() {
    AdscopeSdk.channel.setMethodCallHandler(
          (call) async {
        switch (call.method) {
          case AMPSAdCallBackChannelMethod.onLoadSuccess:
            adCallBack?.onLoadSuccess?.call();
            break;
          case AMPSAdCallBackChannelMethod.onLoadFailure:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onLoadFailure?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onRenderOk:
            adCallBack?.onRenderOk?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShow:
            adCallBack?.onAdShow?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdExposure:
            adCallBack?.onAdExposure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClicked:
            adCallBack?.onAdClicked?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClosed:
            adCallBack?.onAdClosed?.call();
            break;
          case AMPSAdCallBackChannelMethod.onRenderFailure:
            adCallBack?.onRenderFailure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShowError:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onAdShowError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayStart:
            adCallBack?.onVideoPlayStart?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayEnd:
            adCallBack?.onVideoPlayEnd?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onVideoPlayError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoSkipToEnd:
            var map = call.arguments as Map<dynamic, dynamic>;
            adCallBack?.onVideoSkipToEnd?.call(map[AMPSSdkCallBackParamsKey.playDurationMs]);
            break;
          case AMPSAdCallBackChannelMethod.onAdReward:
            adCallBack?.onAdReward?.call();
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
  void  preLoad() async {
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

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.rewardVideoGetECPM);
  }

}