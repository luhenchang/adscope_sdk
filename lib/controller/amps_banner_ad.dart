import 'dart:ffi';
import 'package:flutter/services.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import 'banner_callback_router.dart';

///开屏广告类
class AMPSBannerAd {
  static int _instanceCounter = 0;
  final String instanceId;
  AdOptions config;
  BannerCallBack? mCallBack;
  VoidCallback? mCloseCallBack;

  AMPSBannerAd({required this.config, this.mCallBack, String? instanceId})
      : instanceId = instanceId ?? _generateInstanceId() {
    BannerCallbackRouter.instance.register(this.instanceId, mCallBack, mCloseCallBack);
    _createNativeAd();
  }

  ///创建原生广告实例，失败时通过onLoadFailure通知，避免静默失败
  Future<void> _createNativeAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.bannerCreate,
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

  static String _generateInstanceId() {
    _instanceCounter += 1;
    return 'banner_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
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

  void setMethodCallHandler() {
    BannerCallbackRouter.instance.register(instanceId, mCallBack, mCloseCallBack);
  }

  ///开屏广告加载调用，失败时通过onLoadFailure通知
  void load() async {
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.bannerLoad, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///开屏广预加载，失败时通过onLoadFailure通知
  void preLoad() async {
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.bannerPreLoad, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///开屏广告显示调用
  void setSlideTime(Int time) async {
    try {
      await AdscopeSdk.invokeMethod(
          AMPSAdSdkMethodNames.bannerSetSlideTime, {
        ..._instanceOnlyArgs(),
        "slideTime": time,
      });
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///开屏广告是否有预加载，异常时返回false
  Future<bool> isReadyAd() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.bannerIsReadyAd, _instanceOnlyArgs()) ?? false;
    } on PlatformException {
      return false;
    }
  }

  ///获取ecpm，异常时返回0
  Future<num> getECPM() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.bannerGetECPM, _instanceOnlyArgs()) ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  ///获取胜出渠道的seatId，异常时返回null
  Future<String?> getSeatId() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.bannerGetSeatId, _instanceOnlyArgs());
    } on PlatformException {
      return null;
    }
  }

  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    try {
      await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.bannerAddPreLoadAdInfo, _instanceOnlyArgs());
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///调用addPreGetMediaExtraInfo，异常时返回null
  Future<dynamic> getMediaExtraInfo() async {
    try {
      return await AdscopeSdk
          .invokeMethod(AMPSAdSdkMethodNames.bannerGetMediaExtraInfo, _instanceOnlyArgs());
    } on PlatformException {
      return null;
    }
  }

  ///销毁视频广告
  destroy() async {
    BannerCallbackRouter.instance.unregister(instanceId);
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.bannerDestroyAd, _instanceOnlyArgs());
    } on PlatformException {
      // 销毁失败不影响业务流程，但不能抛出未捕获异常
    }
  }

  void registerChannel(VoidCallback callBack) {
    mCloseCallBack = callBack;
    BannerCallbackRouter.instance.register(instanceId, mCallBack, mCloseCallBack);
  }

  void setAdCloseCallBack(VoidCallback closeCallBack) {
    mCloseCallBack = closeCallBack;
    // 重新注册到 router，保证 close 回调引用与字段同步。
    BannerCallbackRouter.instance.register(instanceId, mCallBack, mCloseCallBack);
  }
}
