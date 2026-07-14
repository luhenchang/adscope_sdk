import 'package:flutter/services.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../widget/splash_bottom_widget.dart';
import 'splash_callback_router.dart';

///开屏广告类
class AMPSSplashAd {
  static int _instanceCounter = 0;

  /// 实例唯一标识，与原生 [AMPSSplashInstanceKey.splashInstanceId] 对应。
  final String instanceId;

  AdOptions config;
  AdCallBack? mCallBack;
  VoidCallback? mCloseCallBack;

  AMPSSplashAd({required this.config, this.mCallBack, String? instanceId})
      : instanceId = instanceId ?? _generateInstanceId() {
    SplashCallbackRouter.instance.register(
      this.instanceId,
      mCallBack,
      () => mCloseCallBack?.call(),
    );
    _createNativeAd();
  }

  ///创建原生广告实例，失败时通过onLoadFailure通知，避免静默失败
  Future<void> _createNativeAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashCreate,
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
    return 'splash_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _wrapArgs(Map<dynamic, dynamic> args) {
    return {
      AMPSSplashInstanceKey.splashInstanceId: instanceId,
      ...args,
    };
  }

  Map<String, dynamic> _instanceOnlyArgs() {
    return {AMPSSplashInstanceKey.splashInstanceId: instanceId};
  }

  ///开屏广告加载调用，失败时通过onLoadFailure通知
  void load() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashLoad,
        _instanceOnlyArgs(),
      );
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///开屏广预加载，失败时通过onLoadFailure通知
  void preLoad() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashPreLoad,
        _instanceOnlyArgs(),
      );
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///开屏广告显示调用，失败时通过onAdShowError通知，避免静默失败
  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    final Map<String, dynamic> args = _instanceOnlyArgs();
    if (splashBottomWidget != null) {
      args[splashBottomView] = splashBottomWidget.toMap();
    }
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.splashShowAd, args);
    } on PlatformException catch (e) {
      _notifyShowFailure(e);
    }
  }

  ///开屏广告是否有预加载，异常时返回false
  Future<bool> isReadyAd() async {
    try {
      return await AdscopeSdk.invokeMethod(
            AMPSAdSdkMethodNames.splashIsReadyAd,
            _instanceOnlyArgs(),
          ) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  ///获取ecpm，异常时返回0
  Future<num> getECPM() async {
    try {
      return await AdscopeSdk.invokeMethod(
            AMPSAdSdkMethodNames.splashGetECPM,
            _instanceOnlyArgs(),
          ) ??
          0;
    } on PlatformException {
      return 0;
    }
  }

  ///获取胜出渠道的seatId，异常时返回null
  Future<String?> getSeatId() async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashGetSeatId,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      return null;
    }
  }

  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashAddPreLoadAdInfo,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///调用addPreGetMediaExtraInfo，异常时返回null
  Future<dynamic> addPreGetMediaExtraInfo() async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashAddPreGetMediaExtraInfo,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      return null;
    }
  }

  void registerChannel(VoidCallback callBack) {
    mCloseCallBack = callBack;
    SplashCallbackRouter.instance.register(
      instanceId,
      mCallBack,
      () => mCloseCallBack?.call(),
    );
  }

  Future destroy() async {
    SplashCallbackRouter.instance.unregister(instanceId);
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.splashDestroy,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      // 销毁失败不影响业务流程，但不能抛出未捕获异常
      return null;
    }
  }
}
