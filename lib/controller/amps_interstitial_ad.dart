import 'package:flutter/services.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
///插屏广告对象入口类
class AMPSInterstitialAd {
  AdOptions config;
  AdCallBack? mCallBack;
  bool needLoad = false;

  MethodChannel? _channel;

  AMPSInterstitialAd({required this.config, this.mCallBack});

  void setMethodCallHandler(AdWidgetNeedCloseCall? closeWidgetCall) {
    _channel?.setMethodCallHandler(
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
    _channel = AdscopeSdk.channel;
    setMethodCallHandler(null);
    await AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad,
      config.toMap(),
    );
  }
  ///插屏广告显示调用方法
  void showAd() async {
    await _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialShowAd);
  }
  ///是否有预加载
  Future<bool> isReadyAd() async {
    return await _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialIsReadyAd);
  }
  ///获取ecpm
  Future<num> getECPM() async {
    return await _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialGetECPM);
  }
  ///上报竞胜
  notifyRTBWin(double winPrice, double secPrice,{String? winAdnId}) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adWinAdnId: winAdnId
    };
    _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialNotifyRTBWin, args);
  }
  ///上报竞败
  notifyRTBLoss(double winPrice, double secPrice, String lossReason,{String? winAdnId}) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adLossReason: lossReason,
      adWinAdnId: winAdnId
    };
    _channel?.invokeMethod(AMPSAdSdkMethodNames.interstitialNotifyRTBLoss,args);
  }
}
