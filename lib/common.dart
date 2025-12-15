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
  static const ampsSdkBannerViewId = '$channelDomain/banner_view_id';
  static const ampsSdkDrawViewId = '$channelDomain/draw_view_id';
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

// 1. 先定义统一的回调方法常量（参考示例格式）
class AMPSRewardedVideoCallBackChannelMethod {
  static const String onLoadSuccess = "RewardedVideo_onLoadSuccess";
  static const String onLoadFailure = "RewardedVideo_onLoadFailure";
  static const String onAdShow = "RewardedVideo_onAdShow";
  static const String onAdClicked = "RewardedVideo_onAdClicked";
  static const String onAdClosed = "RewardedVideo_onAdClosed";
  static const String onAdReward = "RewardedVideo_onAdReward";
  static const String onVideoPlayStart = "RewardedVideo_onVideoPlayStart";
  static const String onVideoPlayEnd = "RewardedVideo_onVideoPlayEnd";
  static const String onVideoPlayError = "RewardedVideo_onVideoPlayError";
  static const String onVideoSkipToEnd = "RewardedVideo_onVideoSkipToEnd";
  static const String onAdCached = "RewardedVideo_onAdCached";
}

//2. banner相关原生端回调
class AMPSBannerCallBackChannelMethod {
  static const String onLoadSuccess = "Banner_onLoadSuccess";
  static const String onLoadFailure = "Banner_onLoadFailure";
  static const String onAdShow = "Banner_onAdShow";
  static const String onAdClicked = "Banner_onAdClicked";
  static const String onAdClosed = "Banner_onAdClosed";

  static const String onVideoReady = "Banner_onVideoReady";
  static const String onVideoPause = "Banner_onVideoPause";
  static const String onVideoResume = "Banner_onVideoResume";
  static const String onVideoPlayStart = "Banner_onVideoPlayStart";
  static const String onVideoPlayEnd = "Banner_onVideoPlayEnd";
  static const String onVideoPlayError = "Banner_onVideoPlayError";
}

class AmpsDrawCallbackChannelMethod {
  static const String onLoadSuccess = "Draw_onLoadSuccess";
  static const String onLoadFailure = "Draw_onLoadFailure";
  static const String onRenderSuccess = "Draw_onRenderSuccess";
  static const String onRenderFail = "Draw_onRenderFail";
  static const String onAdShow = "Draw_onAdShow";
  static const String onAdClicked = "Draw_onAdClicked";
  static const String onAdClosed = "Draw_onAdClosed";
  static const String onVideoLoad = "Draw_onVideoLoad";
  static const String onVideoPlayStart = "Draw_onVideoPlayStart";
  static const String onVideoPlayPause = "Draw_onVideoAdPaused";
  static const String onVideoAdContinuePlay = "Draw_onVideoAdContinuePlay";
  static const String onProgressUpdate = "Draw_onProgressUpdate";
  static const String onVideoError = "Draw_onVideoError";
  static const String onVideoAdComplete = "Draw_onVideoAdComplete";
  static const String drawSizeUpdate = "Draw_SizeUpdate";

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
  static const String onComplainSuccess = "onComplainSuccess";
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
  static const String getSdkVersion= "AMPSAdSdk_getSdkVersion";
  static const String getInitStatus= "AMPSAdSdk_getSdkVersion";
  static const String setPersonalRecommend = "AMPSAdSdk_setPersonalRecommend";
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
  static const String interstitialCreate = "AMPSInterstitial_create";
  static const String interstitialLoad = "AMPSInterstitial_load";
  static const String interstitialPreLoad = "AMPSInterstitial_preLoad";
  static const String interstitialShowAd = "AMPSInterstitial_showAd";
  static const String interstitialGetEcpm = "AMPSInterstitial_getECPM";
  static const String interstitialIsReadyAd = "AMPSInterstitial_isReadyAd";
  static const String interstitialAddPreLoadAdInfo = "AMPSInterstitial_addPreLoadAdInfo";
  static const String interstitialGetMediaExtraInfo = "AMPSInterstitial_getMediaExtraInfo";

  /// 原生与自渲染相关方法
  static const String nativeCreate = 'AMPSNative_create';
  static const String nativeLoad = 'AMPSNative_load';
  // static const String nativeShowAd = 'AMPSNative_showAd';
  static const String nativePattern = 'AMPSNative_getUnifiedPattern';
  static const String nativeGetECPM = 'AMPSNative_getECPM';
  static const String nativeIsReadyAd = 'AMPSNative_isReadyAd';
  static const String nativeIsNativeExpress = 'AMPSNative_isNativeExpress';
  static const String nativeUnifiedMaterialType = "AMPSNative_materialType";
  static const String nativeUnifiedGetDownLoad = "AMPSNative_getDownLoad";
  static const String nativeGetVideoDuration = 'AMPSNative_getVideoDuration';
  // static const String nativeSetVideoPlayConfig = 'AMPSNative_setVideoPlayConfig';
  static const String nativeGetMediaExtraInfo = "AMPSNative_getMediaExtraInfo";

  //激励视频
  static const String rewardVideoCreate = 'AMPSRewardVideo_create';
  static const String rewardVideoLoad = 'AMPSRewardVideo_load';
  static const String rewardVideoPreLoad = "AMPSRewardVideo_preLoad";
  static const String rewardVideoShowAd = 'AMPSRewardVideo_showAd';
  static const String rewardVideoGetECPM = 'AMPSRewardVideo_getECPM';
  static const String rewardVideoIsReadyAd = 'AMPSRewardVideo_isReadyAd';
  static const String rewardVideoDestroyAd = "AMPSRewardVideo_destroy";
  static const String rewardVideoAddPreLoadAdInfo = "AMPSRewardVideo_addPreLoadAdInfo";
  static const String rewardVideoGetMediaExtraInfo = "AMPSRewardVideo_getMediaExtraInfo";

  //Banner
  static const String bannerCreate = 'AMPSBanner_create';
  static const String bannerLoad = 'AMPSBanner_load';
  static const String bannerPreLoad = "AMPSBanner_preLoad";
  static const String bannerSetSlideTime = 'AMPSBanner_setSlideTime';
  static const String bannerGetECPM = 'AMPSBanner_getECPM';
  static const String bannerIsReadyAd = 'AMPSBanner_isReadyAd';
  static const String bannerDestroyAd = "AMPSBanner_destroy";
  static const String bannerAddPreLoadAdInfo = "AMPSBanner_addPreLoadAdInfo";
  static const String bannerGetMediaExtraInfo = "AMPSBanner_getMediaExtraInfo";

  // Draw ad related methods
  static const String drawCreate = "AMPSDraw_create";
  static const String drawLoad = "AMPSDraw_load";
  static const String drawGetEcpm = "AMPSDraw_getEcpm";
  static const String drawIsReadyAd = "AMPSDraw_isReadyAd";
  static const String drawDestroyAd = "AMPSDraw_destroy";
  static const String drawPauseAd = "AMPSDraw_pause";
  static const String drawResumeAd = "AMPSDraw_resume";
  static const String drawGetMediaExtraInfo = "AMPSDraw_getMediaExtraInfo";
}
///Error对应的key
class AMPSSdkCallBackErrorKey {
  static const String adId = "adId";
  static const String code = "code";
  static const String message = "message";
  static const String extra = "extra";
  static const String current = "current";
  static const String duration = "duration";
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