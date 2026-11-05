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
  late final Future<PlatformException?> _creation;
  bool _isDestroyed = false;

  AMPSInterstitialAd({required this.config, this.mCallBack, String? instanceId})
      : instanceId = instanceId ?? _generateInstanceId() {
    InterstitialCallbackRouter.instance
        .register(this.instanceId, mCallBack, _closeWidgetCall);
    _creation = AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.interstitialCreate,
      _wrapArgs(config.toMap()),
    ).then<PlatformException?>((_) => null,
        onError: (Object error) => error is PlatformException
            ? error
            : PlatformException(code: 'CREATE_FAILED', message: '$error'));
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
    InterstitialCallbackRouter.instance
        .register(instanceId, mCallBack, _closeWidgetCall);
  }

  ///广告加载调用方法
  Future<bool> _ensureCreated() async {
    final error = await _creation;
    if (_isDestroyed) return false;
    if (error == null) return true;
    final callback = mCallBack?.onLoadFailure;
    if (callback == null) throw error;
    callback(-1, '${error.code}: ${error.message}');
    return false;
  }

  Future<void> load() async {
    if (!await _ensureCreated()) return;
    await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.interstitialLoad,
      _instanceOnlyArgs(),
    );
  }

  ///广预加载
  Future<void> preLoad() async {
    if (!await _ensureCreated()) return;
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialPreLoad, _instanceOnlyArgs());
  }

  ///插屏广告显示调用方法
  Future<void> showAd() async {
    if (!await _ensureCreated()) return;
    final result = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialShowAd, _instanceOnlyArgs());
    if (result == false) {
      throw PlatformException(
          code: 'SHOW_FAILED', message: 'Interstitial could not be shown');
    }
  }

  ///是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialIsReadyAd, _instanceOnlyArgs());
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialGetEcpm, _instanceOnlyArgs());
  }

  ///获取胜出渠道的seatId
  Future<String?> getSeatId() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialGetSeatId, _instanceOnlyArgs());
  }

  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialAddPreLoadAdInfo, _instanceOnlyArgs());
  }

  ///调用addPreGetMediaExtraInfo
  Future<dynamic> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialGetMediaExtraInfo,
        _instanceOnlyArgs());
  }

  Future<void> destroy() async {
    if (_isDestroyed) return;
    _isDestroyed = true;
    InterstitialCallbackRouter.instance.unregister(instanceId);
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.interstitialDestroy, _instanceOnlyArgs());
  }
}
