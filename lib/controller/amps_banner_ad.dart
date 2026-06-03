import 'dart:ffi';
import 'package:flutter/cupertino.dart';

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
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.bannerCreate,
      _wrapArgs(config.toMap()),
    );
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

  ///开屏广告加载调用
  void load() async {
    await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.bannerLoad, _instanceOnlyArgs());
  }

  ///开屏广预加载
  void preLoad() async {
    await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.bannerPreLoad, _instanceOnlyArgs());
  }

  ///开屏广告显示调用
  void setSlideTime(Int time) async {
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.bannerSetSlideTime, {
      ..._instanceOnlyArgs(),
      "slideTime": time,
    });
  }

  ///开屏广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.bannerIsReadyAd, _instanceOnlyArgs());
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.bannerGetECPM, _instanceOnlyArgs());
  }

  ///获取胜出渠道的seatId
  Future<String?> getSeatId() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.bannerGetSeatId, _instanceOnlyArgs());
  }

  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.bannerAddPreLoadAdInfo, _instanceOnlyArgs());
  }

  ///调用addPreGetMediaExtraInfo
  Future<dynamic> getMediaExtraInfo() async {
    return await AdscopeSdk
        .invokeMethod(AMPSAdSdkMethodNames.bannerGetMediaExtraInfo, _instanceOnlyArgs());
  }

  ///销毁视频广告
  destroy() async {
    BannerCallbackRouter.instance.unregister(instanceId);
    AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.bannerDestroyAd, _instanceOnlyArgs());
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
