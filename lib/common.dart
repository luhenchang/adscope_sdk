const String channelDomain = "xyz.adscope.amps";
///Flutter层的常量，此部分各端应该有一份完全一样的对应。
class AMPSChannels {
  static const String ampsSdk = 'adscope_sdk';
  static const String ampsSdkInit = '$channelDomain/sdk';
  static const String ampsSdkSplash = '$channelDomain/splash';
  static const ampsSdkSplashAdLoad = '$channelDomain/splash_ad_load';
  static const ampsSdkInterstitialAdLoad = '$channelDomain/interstitial_ad_load';
  static const ampsSdkNativeAdLoad = '$channelDomain/native_ad_load';
}
class AMPSPlatformViewRegistry {
  static const ampsSdkSplashViewId = '$channelDomain/splash_view_id';
  static const ampsSdkInterstitialViewId = '$channelDomain/interstitial_view_id';
  static const ampsSdkNativeViewId = '$channelDomain/native_view_id';
  static const ampsSdkUnifiedViewId = '$channelDomain/unified_view_id';
}
///初始化交互通道方法名称
class AMPSInitChannelMethod {
  static const String initSuccess = "initSuccess";
  static const String initializing = "initializing";
  static const String alreadyInit = "alreadyInit";
  static const String initFailed = "initFailed";
}

///开屏和插屏广告加载方法
class AMPSAdCallBackChannelMethod {
  static const String onLoadSuccess = "onLoadSuccess";
  static const String onLoadFailure = "onLoadFailure";
  static const String onRenderOk = "onRenderOk";
  static const String onAdShow = "onAdShow";
  static const String onAdExposure = "onAdExposure";
  static const String onAdClicked = "onAdClicked";
  static const String onAdClosed = "onAdClosed";
  static const String onRenderFailure = "onRenderFailure";
  static const String onAdShowError = "onAdShowError";
  static const String onVideoPlayStart = "onVideoPlayStart";
  static const String onVideoPlayEnd = "onVideoPlayEnd";
  static const String onVideoPlayError = "onVideoPlayError";
  static const String onVideoSkipToEnd = "onVideoSkipToEnd";
  static const String onAdReward = "onAdReward";
}

///原生和原生自渲染标识
class AMPSNativeCallBackChannelMethod {
  //广告加载回调标识
  static const String loadOk = "loadOk";
  static const String loadFail = "loadFail";
  static const String renderSuccess = "renderSuccess";
  static const String renderFailed = "renderFailed";
  ///具体广告组件回调
  static const String onAdShow = "onAdShow";
  static const String onAdExposure = "onAdExposure";
  static const String onAdClicked = "onAdClicked";
  static const String onAdClosed = "onAdClosed"; // 广告关闭
  static const String nativeSizeUpdate = 'AMPSNative_SizeUpdate';
  ///视频组件回调
  static const String onVideoInit = "onVideoInit"; // 视频初始化
  static const String onVideoLoading = "onVideoLoading"; // 视频加载中正在
  static const String onVideoReady = "onVideoReady"; // 视频准备就绪
  static const String onVideoLoaded = "onVideoLoaded"; // 视频加载完成
  static const String onVideoPlayStart = "onVideoPlayStart"; // 视频开始播放
  static const String onVideoPlayComplete = "onVideoPlayComplete"; // 视频播放完成
  static const String onVideoPause = "onVideoPause"; // 视频暂停
  static const String onVideoResume = "onVideoResume"; // 视频恢复播放
  static const String onVideoStop = "onVideoStop"; // 视频停止
  static const String onVideoClicked = "onVideoClicked"; // 视频点击
  static const String onVideoPlayError = "onVideoPlayError"; // 视频播放错误
}
class DownLoadCallBackChannelMethod {
  static const String onDownloadPaused = "onDownloadPaused";
  static const String onDownloadStarted = "onDownloadStarted";
  static const String onDownloadProgressUpdate = "onDownloadProgressUpdate";
  static const String onDownloadFinished = "onDownloadFinished";
  static const String onDownloadFailed = "onDownloadFailed";
  static const String onInstalled = "onInstalled";
}
class AMPSAdSdkMethodNames {
  /// 初始化AMPS广告SDK的方法名
  static const String init = 'AMPSAdSdk_init';
  /// 开屏相关方法
  static const String splashCreate = 'AMPSSplashAd_create';
  static const String splashLoad = 'AMPSSplashAd_load';
  static const String splashShowAd = 'AMPSSplashAd_showAd';
  static const String splashGetECPM = 'AMPSSplashAd_getECPM';
  static const String splashIsReadyAd = 'AMPSSplashAd_isReadyAd';
  static const String splashPreLoad = "AMPSSplashAd_preLoad";
  static const String splashAddPreLoadAdInfo = "AMPSSplashAd_addPreLoadAdInfo";
  static const String splashAddPreGetMediaExtraInfo = "AMPSSplashAd_getMediaExtraInfo";
  /// 插屏相关方法
  static const String interstitialLoad = 'AMPSInterstitial_load';
  static const String interstitialShowAd = 'AMPSSInterstitial_showAd';
  static const String interstitialGetECPM = 'AMPSSInterstitial_getECPM';
  static const String interstitialNotifyRTBWin = 'AMPSInterstitial_notifyRTBWin';
  static const String interstitialNotifyRTBLoss = 'AMPSInterstitial_notifyRTBLoss';
  static const String interstitialIsReadyAd = 'AMPSInterstitial_isReadyAd';

  /// 原生与自渲染相关方法
  static const String nativeLoad = 'AMPSNative_load';
  static const String nativeShowAd = 'AMPSNative_showAd';
  static const String nativeGetECPM = 'AMPSNative_getECPM';
  static const String nativeNotifyRTBWin = 'AMPSNative_notifyRTBWin';
  static const String nativeNotifyRTBLoss = 'AMPSNative_notifyRTBLoss';
  static const String nativeIsReadyAd = 'AMPSNative_isReadyAd';
  static const String nativeIsNativeExpress = 'AMPSNative_isNativeExpress';
  static const String nativeGetVideoDuration = 'AMPSNative_getVideoDuration';
  static const String nativeSetVideoPlayConfig = 'AMPSNative_setVideoPlayConfig';

  //激励视频
  static const String rewardVideoCreate = 'AMPSRewardVideo_create';
  static const String rewardVideoLoad = 'AMPSRewardVideo_load';
  static const String rewardVideoPreLoad = "AMPSRewardVideo_preLoad";
  static const String rewardVideoShowAd = 'AMPSRewardVideo_showAd';
  static const String rewardVideoGetECPM = 'AMPSRewardVideo_getECPM';
  static const String rewardVideoIsReadyAd = 'AMPSRewardVideo_isReadyAd';


}
///Error对应的key
class AMPSSdkCallBackErrorKey {
  static const String adId = "adId";
  static const String code = "code";
  static const String message = "message";
  static const String extra = "extra";
}

class AMPSSdkCallBackParamsKey {
  static const String playDurationMs = "playDurationMs";
}

///NativeType
enum NativeType {
  ///原生广告
  native(0),
  ///原生自渲染
  unified(1);

  final int value;
  const NativeType(this.value);
}

///广告方法参数对应的一些常量
const String adWinPrice = 'winPrice';
const String adSecPrice = 'secPrice';
const String adWinAdnId = 'winAdnId';
const String adAdId = 'adId';
const String adNativeType = 'nativeType';
const String adLossReason = 'lossReason';
const String adOption = 'AdOption';
const String splashConfig = "config";
const String splashBottomView = "SplashBottomView";