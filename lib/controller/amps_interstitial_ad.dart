import 'package:flutter/services.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
///插屏广告对象入口类
class AMPSInterstitialAd {
  AdOptions config;
  AdCallBack? mCallBack;

  AMPSInterstitialAd({required this.config, this.mCallBack}) {
    AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.interstitialCreate,
      config.toMap(),
    );
    setMethodCallHandler(null);
  }

  void setMethodCallHandler(AdWidgetNeedCloseCall? closeWidgetCall) {
    AdscopeSdk.channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case AMPSAdCallBackChannelMethod.onLoadSuccess:
            mCallBack?.onLoadSuccess?.call();
            break;
          case AMPSAdCallBackChannelMethod.onLoadFailure:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onLoadFailure?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onRenderOk:
            mCallBack?.onRenderOk?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShow:
            mCallBack?.onAdShow?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdExposure:
            mCallBack?.onAdExposure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClicked:
            closeWidgetCall?.call();
            mCallBack?.onAdClicked?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdClosed:
            closeWidgetCall?.call();
            mCallBack?.onAdClosed?.call();
            break;
          case AMPSAdCallBackChannelMethod.onRenderFailure:
            mCallBack?.onRenderFailure?.call();
            break;
          case AMPSAdCallBackChannelMethod.onAdShowError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onAdShowError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayStart:
            mCallBack?.onVideoPlayStart?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayEnd:
            mCallBack?.onVideoPlayEnd?.call();
            break;
          case AMPSAdCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onVideoPlayError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSAdCallBackChannelMethod.onVideoSkipToEnd:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onVideoSkipToEnd?.call(map[AMPSSdkCallBackParamsKey.playDurationMs]);
            break;
          case AMPSAdCallBackChannelMethod.onAdReward:
            mCallBack?.onAdReward?.call();
            break;
        }
      },
    );
  }
  ///广告加载调用方法
  void load() async {
    setMethodCallHandler(null);
    await AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad
    );
  }

  ///广预加载
  void  preLoad() async {
    await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.interstitialPreLoad);
  }

  ///插屏广告显示调用方法
  void showAd() async {
    await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.interstitialShowAd);
  }
  ///是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.interstitialIsReadyAd);
  }
  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.interstitialGetEcpm);
  }
  
  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.interstitialAddPreLoadAdInfo);
  }

  ///调用addPreGetMediaExtraInfo
  Future<dynamic> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.channel
        .invokeMapMethod(AMPSAdSdkMethodNames.interstitialGetMediaExtraInfo);
  }
}
