import { ampsAd } from 'xyz.adscope.amps';
import { StringConstants } from './StringConstants';

const channelDomain = "xyz.adscope.amps";

export class AMPSChannels {
  static readonly ampsSdkInit = `${channelDomain}/sdk`;
  static readonly ampsSdkSplash = `${channelDomain}/splash`;
  static readonly ampsSdkSplashAdLoad = `${channelDomain}/splash_ad_load`;
  static readonly ampsSdkInterstitialAdLoad = `${channelDomain}/interstitial_ad_load`;
  static readonly ampsSdkNativeAdLoad = `${channelDomain}/native_ad_load`;
}

export class AMPSPlatformViewRegistry {
  static readonly ampsSdkSplashViewId = `${channelDomain}/splash_view_id`;
  static readonly ampsSdkInterstitialViewId = `${channelDomain}/interstitial_view_id`;
  static readonly ampsSdkNativeViewId = `${channelDomain}/native_view_id`;
  static readonly ampsSdkUnifiedViewId = `${channelDomain}/unified_view_id`;
  static readonly ampsSdkBannerViewId = `${channelDomain}/banner_view_id`;
  static readonly ampsSdkDrawViewId = `${channelDomain}/draw_view_id`;
}

//初始化交互通道方法名称
export class AMPSInitChannelMethod {
  static readonly initSuccess = "initSuccess";
  static readonly initializing = "initializing";
  static readonly alreadyInit = "alreadyInit";
  static readonly initFailed = "initFailed";
}

//开屏广告加载方法
export class AMPSAdCallBackChannelMethod {
  static readonly onLoadSuccess = "onLoadSuccess";
  static readonly onLoadFailure = "onLoadFailure";
  static readonly onRenderOk = "onRenderOk";
  static readonly onAdShow = "onAdShow";
  static readonly onAdExposure = "onAdExposure";
  static readonly onAdClicked = "onAdClicked";
  static readonly onAdClosed = "onAdClosed";
  static readonly onRenderFailure = "onRenderFailure";
  static readonly onAdShowError = "onAdShowError";
  static readonly onVideoPlayStart = "onVideoPlayStart";
  static readonly onVideoPlayEnd = "onVideoPlayEnd";
  static readonly onVideoPlayError = "onVideoPlayError";
  static readonly onVideoSkipToEnd = "onVideoSkipToEnd";
  static readonly onAdReward = "onAdReward";
}
// 1. 激励视频回调方法常量（参考示例格式）
export class AMPSRewardedVideoCallBackChannelMethod {
  static readonly onLoadSuccess = "RewardedVideo_onLoadSuccess";
  static readonly onLoadFailure = "RewardedVideo_onLoadFailure";
  static readonly onAdShow = "RewardedVideo_onAdShow";
  static readonly onAdClicked = "RewardedVideo_onAdClicked";
  static readonly onAdClosed = "RewardedVideo_onAdClosed";
  static readonly onAdReward = "RewardedVideo_onAdReward";
  static readonly onVideoPlayStart = "RewardedVideo_onVideoPlayStart";
  static readonly onVideoPlayEnd = "RewardedVideo_onVideoPlayEnd";
  static readonly onVideoPlayError = "RewardedVideo_onVideoPlayError";
  static readonly onVideoSkipToEnd = "RewardedVideo_onVideoSkipToEnd";
  static readonly onAdCached = "RewardedVideo_onAdCached";
}
//2. banner相关原生端回调
export class AMPSBannerCallBackChannelMethod {
  static readonly onLoadSuccess = "Banner_onLoadSuccess";
  static readonly onLoadFailure = "Banner_onLoadFailure";
  static readonly onAdShow = "Banner_onAdShow";
  static readonly onAdClicked = "Banner_onAdClicked";
  static readonly onAdClosed = "Banner_onAdClosed";

  static readonly onVideoReady = "Banner_onVideoReady";
  static readonly onVideoPlayStart = "Banner_onVideoPlayStart";
  static readonly onVideoPlayEnd = "Banner_onVideoPlayEnd";
  static readonly onVideoPlayError = "Banner_onVideoPlayError";
  static readonly onVideoPause = "Banner_onVideoPause";
  static readonly onVideoResume = "Banner_onVideoResume";
}
export class AmpsDrawCallbackChannelMethod {
  static readonly onLoadSuccess = "Draw_onLoadSuccess";
  static readonly onLoadFailure = "Draw_onLoadFailure";
  static readonly onRenderSuccess = "Draw_onRenderSuccess";
  static readonly onRenderFail = "Draw_onRenderFail";
  static readonly onAdShow = "Draw_onAdShow";
  static readonly onAdClicked = "Draw_onAdClicked";
  static readonly onAdClosed = "Draw_onAdClosed";
  static readonly onVideoLoad = "Draw_onVideoLoad";

  static readonly onVideoPlayStart = "Draw_onVideoPlayStart";
  static readonly onVideoPlayPause = "Draw_onVideoAdPaused";
  static readonly onVideoAdContinuePlay = "Draw_onVideoAdContinuePlay";
  static readonly onProgressUpdate = "Draw_onProgressUpdate";
  static readonly onVideoError = "Draw_onVideoError";
  static readonly onVideoAdComplete = "Draw_onVideoAdComplete";
  static readonly drawSizeUpdate = "Draw_SizeUpdate";

}
//原生和原生自渲染标识
export class AMPSNativeCallBackChannelMethod {
  //广告加载回调标识
  static readonly nativeSizeUpdate = 'AMPSNative_SizeUpdate';
  static readonly loadOk = "loadOk";
  static readonly loadFail = "loadFail";
  static readonly renderSuccess = "renderSuccess";
  static readonly renderFailed = "renderFailed";
  //具体广告组件回调
  static readonly onAdShow = "onAdShow";
  static readonly onAdExposure = "onAdExposure";
  static readonly onAdClicked = "onAdClicked";
  static readonly onAdClosed = "onAdClosed"; // 广告关闭
  //视频组件回调
  static readonly onVideoReady = "onVideoReady"; // 视频准备就绪
  static readonly onVideoPlayStart = "onVideoPlayStart"; // 视频开始播放
  static readonly onVideoPlayComplete = "onVideoPlayComplete"; // 视频播放完成
  static readonly onVideoPause = "onVideoPause"; // 视频暂停
  static readonly onVideoResume = "onVideoResume"; // 视频恢复播放
  static readonly onVideoPlayError = "onVideoPlayError"; // 视频播放错误
}

export class AMPSAdSdkMethodNames {
  // 初始化AMPS广告SDK的方法名
  static readonly testMode = 'testMode'
  static readonly init = 'AMPSAdSdk_init';
  // 开屏相关方法
  static readonly splashCreate = 'AMPSSplashAd_create';
  static readonly splashLoad = 'AMPSSplashAd_load';
  static readonly splashShowAd = 'AMPSSplashAd_showAd';
  static readonly splashGetECPM = 'AMPSSplashAd_getECPM';
  static readonly splashPreLoad = "AMPSSplashAd_preLoad";
  static readonly splashAddPreLoadAdInfo = "AMPSSplashAd_addPreLoadAdInfo";
  static readonly splashAddPreGetMediaExtraInfo = "AMPSSplashAd_getMediaExtraInfo";
  static readonly splashIsReadyAd = 'AMPSSplashAd_isReadyAd';

  //插屏
  static readonly interstitialCreate = "AMPSInterstitial_create";
  static readonly interstitialLoad = 'AMPSInterstitial_load';
  static readonly interstitialShowAd = 'AMPSInterstitial_showAd';
  static readonly interstitialGetECPM = 'AMPSInterstitial_getECPM';
  static readonly interstitialPreLoad = "AMPSInterstitial_preLoad";
  static readonly interstitialAddPreLoadAdInfo = "AMPSInterstitial_addPreLoadAdInfo";
  static readonly interstitialGetMediaExtraInfo = "AMPSInterstitial_getMediaExtraInfo";
  static readonly interstitialIsReadyAd = 'AMPSInterstitial_isReadyAd';


  static readonly nativeLoad = 'AMPSNative_load';
  static readonly nativeCreate = 'AMPSNative_create';
  static readonly nativeGetECPM = 'AMPSNative_getECPM';
  static readonly nativeIsReadyAd = 'AMPSNative_isReadyAd';
  static readonly nativeIsNativeExpress = 'AMPSNative_isNativeExpress';
  static readonly nativeUnifiedMaterialType = "AMPSNative_materialType";
  static readonly nativeUnifiedGetDownLoad = "AMPSNative_getDownLoad";
  static readonly nativeGetVideoDuration = 'AMPSNative_getVideoDuration';
  // static readonly nativeSetVideoPlayConfig = 'AMPSNative_setVideoPlayConfig';
  static readonly nativeGetMediaExtraInfo = "AMPSNative_getMediaExtraInfo";


  static readonly rewardVideoCreate = 'AMPSRewardVideo_create';
  static readonly rewardVideoLoad = 'AMPSRewardVideo_load';
  static readonly rewardVideoPreLoad = 'AMPSRewardVideo_preLoad';
  static readonly rewardVideoShowAd = 'AMPSRewardVideo_showAd';
  static readonly rewardVideoGetECPM = 'AMPSRewardVideo_getECPM';
  static readonly rewardVideoIsReadyAd = 'AMPSRewardVideo_isReadyAd';
  static readonly rewardVideoDestroyAd = "AMPSRewardVideo_destroy";
  static readonly rewardVideoAddPreLoadAdInfo = "AMPSRewardVideo_addPreLoadAdInfo";
  static readonly rewardVideoGetMediaExtraInfo = "AMPSRewardVideo_getMediaExtraInfo";

  //Banner
  static readonly bannerCreate = 'AMPSBanner_create';
  static readonly bannerLoad = 'AMPSBanner_load';
  static readonly bannerPreLoad = 'AMPSBanner_preLoad';
  static readonly bannerSetSlideTime = 'AMPSBanner_setSlideTime';
  static readonly bannerGetECPM = 'AMPSBanner_getECPM';
  static readonly bannerIsReadyAd = 'AMPSBanner_isReadyAd';
  static readonly bannerDestroyAd = "AMPSBanner_destroy";
  static readonly bannerAddPreLoadAdInfo = "AMPSBanner_addPreLoadAdInfo";
  static readonly bannerGetMediaExtraInfo = "AMPSBanner_getMediaExtraInfo";

  //draw
  static readonly drawCreate = "AMPSDraw_create";
  static readonly drawLoad = "AMPSDraw_load";
  static readonly drawGetEcpm = "AMPSDraw_getEcpm";
  static readonly drawIsReadyAd = "AMPSDraw_isReadyAd";
  static readonly drawDestroyAd = "AMPSDraw_destroy";
  static readonly drawPauseAd = "AMPSDraw_pause";
  static readonly drawResumeAd = "AMPSDraw_resume";
  static readonly drawGetMediaExtraInfo = "AMPSDraw_getMediaExtraInfo";

}

export const AD_WIN_PRICE = 'winPrice'
export const AD_SEC_PRICE = 'secPrice'
export const AD_ID = 'adId';
export const AD_LOSS_REASON = 'lossReason'
export const AD_OPTION = 'AdOption';
export const CONFIG = "config";
export const SPLASH_BOTTOM = "SplashBottomView";
export const VIDEO_SOUND = "videoSoundEnable";
export const VIDEO_PLAY_TYPE = "videoAutoPlayType";
export const VIDEO_LOOP_REPLAY = "videoLoopReplay";
export const defaultAdOption: ampsAd.AdOptions = {
  spaceId: StringConstants.EMPTY_STRING
}

export let InitMethodNames: string[] = [AMPSAdSdkMethodNames.init];

export let SplashMethodNames: string[] =
  [
    AMPSAdSdkMethodNames.splashCreate,
    AMPSAdSdkMethodNames.splashLoad,
    AMPSAdSdkMethodNames.splashShowAd,
    AMPSAdSdkMethodNames.splashGetECPM,
    AMPSAdSdkMethodNames.splashPreLoad,
    AMPSAdSdkMethodNames.splashAddPreLoadAdInfo,
    AMPSAdSdkMethodNames.splashAddPreGetMediaExtraInfo,
    AMPSAdSdkMethodNames.splashIsReadyAd
  ];

export let InterstitialMethodNames: string[] =
  [
    AMPSAdSdkMethodNames.interstitialCreate,
    AMPSAdSdkMethodNames.interstitialLoad,
    AMPSAdSdkMethodNames.interstitialShowAd,
    AMPSAdSdkMethodNames.interstitialGetECPM,
    AMPSAdSdkMethodNames.interstitialAddPreLoadAdInfo,
    AMPSAdSdkMethodNames.interstitialGetMediaExtraInfo,
    AMPSAdSdkMethodNames.interstitialPreLoad,
    AMPSAdSdkMethodNames.interstitialIsReadyAd,
  ];

export let NativeMethodNames: string[] = [
  AMPSAdSdkMethodNames.nativeLoad,
  AMPSAdSdkMethodNames.nativeCreate,
  AMPSAdSdkMethodNames.nativeGetECPM,
  AMPSAdSdkMethodNames.nativeUnifiedMaterialType,
  AMPSAdSdkMethodNames.nativeUnifiedGetDownLoad,
  AMPSAdSdkMethodNames.nativeGetMediaExtraInfo,
  AMPSAdSdkMethodNames.nativeIsReadyAd,
  AMPSAdSdkMethodNames.nativeIsNativeExpress,
  AMPSAdSdkMethodNames.nativeGetVideoDuration
];

export let RewardVideoMethodNames: string[] = [
  AMPSAdSdkMethodNames.rewardVideoCreate,
  AMPSAdSdkMethodNames.rewardVideoLoad,
  AMPSAdSdkMethodNames.rewardVideoPreLoad,
  AMPSAdSdkMethodNames.rewardVideoShowAd,
  AMPSAdSdkMethodNames.rewardVideoGetECPM,
  AMPSAdSdkMethodNames.rewardVideoIsReadyAd,
  AMPSAdSdkMethodNames.rewardVideoDestroyAd,
  AMPSAdSdkMethodNames.rewardVideoAddPreLoadAdInfo,
  AMPSAdSdkMethodNames.rewardVideoGetMediaExtraInfo
];

export let BannerMethodNames: string[] = [
  AMPSAdSdkMethodNames.bannerCreate,
  AMPSAdSdkMethodNames.bannerLoad,
  AMPSAdSdkMethodNames.bannerPreLoad,
  AMPSAdSdkMethodNames.bannerSetSlideTime,
  AMPSAdSdkMethodNames.bannerGetECPM,
  AMPSAdSdkMethodNames.bannerIsReadyAd,
  AMPSAdSdkMethodNames.bannerDestroyAd,
  AMPSAdSdkMethodNames.bannerAddPreLoadAdInfo,
  AMPSAdSdkMethodNames.bannerGetMediaExtraInfo
];

export let DrawMethodNames: string[] = [
  AMPSAdSdkMethodNames.drawCreate,
  AMPSAdSdkMethodNames.drawLoad,
  AMPSAdSdkMethodNames.drawGetEcpm,
  AMPSAdSdkMethodNames.drawIsReadyAd,
  AMPSAdSdkMethodNames.drawDestroyAd,
  AMPSAdSdkMethodNames.drawPauseAd,
  AMPSAdSdkMethodNames.drawResumeAd,
  AMPSAdSdkMethodNames.drawGetMediaExtraInfo
];

