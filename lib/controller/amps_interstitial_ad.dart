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
    _createNativeAd();
  }

  ///创建原生广告实例，失败时通过onLoadFailure通知，避免静默失败
  Future<void> _createNativeAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialCreate,
        _wrapArgs(config.toMap()),
      );
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///将原生端返回的错误转发给onLoadFailure回调
  void _notifyLoadFailure(PlatformException e) {
    mCallBack?.onLoadFailure?.call(int.tryParse(e.code) ?? -1, e.message ?? e.code);
  }

  ///将展示阶段的错误转发给onAdShowError回调，避免show失败后业务方无感知
  void _notifyShowFailure(PlatformException e) {
    mCallBack?.onAdShowError?.call(int.tryParse(e.code) ?? -1, e.message ?? e.code);
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
  ///广告加载调用方法，失败时通过onLoadFailure通知
  void load() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialLoad,
        _instanceOnlyArgs(),
      );
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///广预加载，失败时通过onLoadFailure通知
  void  preLoad() async {
    try {
      await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialPreLoad, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///插屏广告显示调用方法，失败时通过onAdShowError通知，避免静默失败
  void showAd() async {
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.interstitialShowAd, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyShowFailure(e);
    }
  }
  ///是否有预加载，异常时返回false
  Future<bool> isReadyAd() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialIsReadyAd, _instanceOnlyArgs()) ?? false;
    } on PlatformException {
      return false;
    }
  }
  ///获取ecpm，异常时返回0
  Future<num> getECPM() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialGetEcpm, _instanceOnlyArgs()) ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  ///获取胜出渠道的seatId，异常时返回null
  Future<String?> getSeatId() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialGetSeatId, _instanceOnlyArgs());
    } on PlatformException {
      return null;
    }
  }
  
  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    try {
      await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialAddPreLoadAdInfo, _instanceOnlyArgs());
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///调用addPreGetMediaExtraInfo，异常时返回null
  Future<dynamic> addPreGetMediaExtraInfo() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialGetMediaExtraInfo, _instanceOnlyArgs());
    } on PlatformException {
      return null;
    }
  }

  Future destroy() async {
    InterstitialCallbackRouter.instance.unregister(instanceId);
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.interstitialDestroy, _instanceOnlyArgs());
    } on PlatformException {
      // 销毁失败不影响业务流程，但不能抛出未捕获异常
      return null;
    }
  }
}
