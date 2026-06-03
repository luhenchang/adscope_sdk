import 'dart:ui';

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
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.splashCreate,
      _wrapArgs(config.toMap()),
    );
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

  ///开屏广告加载调用
  void load() async {
    await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.splashLoad,
      _instanceOnlyArgs(),
    );
  }

  ///开屏广预加载
  void preLoad() async {
    await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.splashPreLoad,
      _instanceOnlyArgs(),
    );
  }

  ///开屏广告显示调用
  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    final Map<String, dynamic> args = _instanceOnlyArgs();
    if (splashBottomWidget != null) {
      args[splashBottomView] = splashBottomWidget.toMap();
    }
    await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.splashShowAd, args);
  }

  ///开屏广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.invokeMethod(
          AMPSAdSdkMethodNames.splashIsReadyAd,
          _instanceOnlyArgs(),
        ) ??
        false;
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.invokeMethod(
          AMPSAdSdkMethodNames.splashGetECPM,
          _instanceOnlyArgs(),
        ) ??
        0;
  }

  ///获取胜出渠道的seatId
  Future<String?> getSeatId() async {
    return await AdscopeSdk.invokeMethod(
          AMPSAdSdkMethodNames.splashGetSeatId,
          _instanceOnlyArgs(),
        );
  }

  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.splashAddPreLoadAdInfo,
      _instanceOnlyArgs(),
    );
  }

  ///调用addPreGetMediaExtraInfo
  Future<dynamic> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.splashAddPreGetMediaExtraInfo,
      _instanceOnlyArgs(),
    );
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
    return AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.splashDestroy,
      _instanceOnlyArgs(),
    );
  }
}
