import 'package:flutter/services.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import 'interstitial_callback_router.dart';
///插屏广告对象入口类
class AMPSInterstitialAd {
  static int _instanceCounter = 0;
  final String instanceId;
  AdOptions config;
  AdCallBack? mCallBack;
  VoidCallback? _closeWidgetCall;

  AMPSInterstitialAd({required this.config, this.mCallBack, String? instanceId})
      : instanceId = instanceId ?? _generateInstanceId() {
    InterstitialCallbackRouter.instance.register(this.instanceId, mCallBack, _closeWidgetCall);
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.interstitialCreate,
      _wrapArgs(config.toMap()),
    );
  }

  static String _generateInstanceId() {
    _instanceCounter += 1;
    return 'interstitial_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
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

  void setMethodCallHandler(VoidCallback? closeWidgetCall) {
    _closeWidgetCall = closeWidgetCall;
    InterstitialCallbackRouter.instance.register(instanceId, mCallBack, _closeWidgetCall);
  }
  ///广告加载调用方法
  void load() async {
    await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad,
      _instanceOnlyArgs(),
    );
  }

  ///广预加载
  void  preLoad() async {
    await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.interstitialPreLoad, _instanceOnlyArgs());
  }

  ///插屏广告显示调用方法
  void showAd() async {
    await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.interstitialShowAd, _instanceOnlyArgs());
  }
  ///是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.interstitialIsReadyAd, _instanceOnlyArgs());
  }
  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.interstitialGetEcpm, _instanceOnlyArgs());
  }
  
  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.interstitialAddPreLoadAdInfo, _instanceOnlyArgs());
  }

  ///调用addPreGetMediaExtraInfo
  Future<dynamic> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.interstitialGetMediaExtraInfo, _instanceOnlyArgs());
  }

  Future destroy() {
    InterstitialCallbackRouter.instance.unregister(instanceId);
    return AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.interstitialDestroy, _instanceOnlyArgs());
  }
}
