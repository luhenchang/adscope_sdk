import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_ad.dart';
import '../widget/splash_bottom_widget.dart';

///开屏广告类
class AMPSBannerAd {
  AdOptions config;
  BannerCallBack? mCallBack;
  AdWidgetNeedCloseCall? mCloseCallBack;

  AMPSBannerAd({required this.config, this.mCallBack}) {
    AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.bannerCreate,
      config.toMap(),
    );
    setMethodCallHandler();
  }

  void setMethodCallHandler() {
    AdscopeSdk.channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case AMPSBannerCallBackChannelMethod.onLoadSuccess:
            mCallBack?.onLoadSuccess?.call();
            break;
          case AMPSBannerCallBackChannelMethod.onLoadFailure:
            mCloseCallBack?.call();
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onLoadFailure?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSBannerCallBackChannelMethod.onAdShow:
            mCallBack?.onAdShow?.call();
            break;
          case AMPSBannerCallBackChannelMethod.onAdClicked:
            mCloseCallBack?.call();
            mCallBack?.onAdClicked?.call();
            break;
          case AMPSBannerCallBackChannelMethod.onAdClosed:
            mCloseCallBack?.call();
            mCallBack?.onAdClosed?.call();
            break;
          case AMPSBannerCallBackChannelMethod.onVideoPlayStart:
            mCallBack?.onVideoPlayStart?.call();
            break;
          case AMPSBannerCallBackChannelMethod.onVideoPlayEnd:
            mCallBack?.onVideoPlayEnd?.call();
            break;
          case AMPSBannerCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onVideoPlayError?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSBannerCallBackChannelMethod.onVideoSkipToEnd:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.onVideoSkipToEnd
                ?.call(map[AMPSSdkCallBackParamsKey.playDurationMs]);
            break;
          case AMPSBannerCallBackChannelMethod.onAdReward:
            mCallBack?.onAdReward?.call();
            break;
        }
      },
    );
  }

  ///开屏广告加载调用
  void load() async {
    await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.bannerLoad);
  }

  ///开屏广预加载
  void preLoad() async {
    await AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.bannerPreLoad);
  }

  ///开屏广告显示调用
  void showAd({SplashBottomWidget? splashBottomWidget}) async {
    await AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.bannerShowAd, splashBottomWidget?.toMap());
  }

  ///开屏广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.bannerIsReadyAd);
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.bannerGetECPM);
  }

  ///调用addPreLoadAdInfo
  void addPreLoadAdInfo() async {
    await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.bannerAddPreLoadAdInfo);
  }

  ///调用addPreGetMediaExtraInfo
  Future<Map<String, dynamic>?> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.bannerGetMediaExtraInfo);
  }

  ///销毁视频广告
  destroy() async {
    AdscopeSdk.channel.invokeMethod(AMPSAdSdkMethodNames.bannerDestroyAd);
  }

  void registerChannel(AdWidgetNeedCloseCall callBack) {
    mCloseCallBack = callBack;
  }

  void setAdCloseCallBack(AdWidgetNeedCloseCall closeCallBack) {
    mCloseCallBack = closeCallBack;
  }
}
