import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../widget/splash_bottom_widget.dart';

///开屏广告类
class AMPSSplashAd {
  AdOptions config;
  AdCallBack? mCallBack;
  AdCallBack? mViewCallBack;

  AMPSSplashAd({required this.config, this.mCallBack}) {
    AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.splashCreate,
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

  ///开屏广告加载调用
  void load() async {
    await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.splashLoad);
  }

  ///获取ecpm
  void  preLoad() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.splashPreLoad);
  }

  ///开屏广告显示调用
  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    await AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.splashShowAd, splashBottomWidget?.toMap());
  }

  ///开屏广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.splashIsReadyAd);
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.splashGetECPM);
  }

  ///获取ecpm
  void addPreLoadAdInfo() async {
    AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.splashAddPreLoadAdInfo);
  }

  ///获取ecpm
  Future<Map<String, dynamic>?> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.splashAddPreGetMediaExtraInfo);
  }
}
