import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../widget/splash_bottom_widget.dart';
import '';
///开屏广告类
class AMPSSplashAd {
  MethodChannel? _channel;
  AdOptions config;
  AdCallBack? mCallBack;
  AdCallBack? mViewCallBack;

  AMPSSplashAd({required this.config, this.mCallBack});

  // void registerChannel(int id,AdWidgetNeedCloseCall? closeWidgetCall) {
  //   _channel = null;
  //   _channel = MethodChannel('${AMPSPlatformViewRegistry.ampsSdkSplashViewId}$id');
  //   setMethodCallHandler(closeWidgetCall);
  // }

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
  ///开屏广告加载调用
  void load() async {
    _channel = AdscopeSdk.channel;
    setMethodCallHandler(null);
    debugPrint("Flutter == onAmpsAdLoaded=load");
    await AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.splashLoad,
      config.toMap(),
    );
  }
  ///开屏广告显示调用
  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    await _channel?.invokeMethod(AMPSAdSdkMethodNames.splashShowAd, splashBottomWidget?.toMap());
  }
  ///开屏广告是否有预加载
  Future<bool> isReadyAd() async {
    return await _channel?.invokeMethod(AMPSAdSdkMethodNames.splashIsReadyAd);
  }
  ///获取ecpm
  Future<num> getECPM() async {
    return await _channel?.invokeMethod(AMPSAdSdkMethodNames.splashGetECPM);
  }
  ///上报竞胜
  notifyRTBWin(double winPrice, double secPrice,{String? winAdnId}) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adWinAdnId: winAdnId
    };
    _channel?.invokeMethod(AMPSAdSdkMethodNames.splashNotifyRTBWin, args);
  }
  ///上报竞败
  notifyRTBLoss(double winPrice, double secPrice, String lossReason,{String? winAdnId}) {
    final Map<String, dynamic> args = {
      adWinPrice: winPrice,
      adSecPrice: secPrice,
      adLossReason: lossReason,
      adWinAdnId: winAdnId
    };
    _channel?.invokeMethod(AMPSAdSdkMethodNames.splashNotifyRTBLoss,args);
  }
}
