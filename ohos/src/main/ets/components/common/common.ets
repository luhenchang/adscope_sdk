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

//原生和原生自渲染标识
export class AMPSNativeCallBackChannelMethod {
  //广告加载回调标识
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
  static readonly splashLoad = 'AMPSSplashAd_load';
  static readonly splashShowAd = 'AMPSSplashAd_showAd';
  static readonly splashGetECPM = 'AMPSSplashAd_getECPM';
  static readonly splashNotifyRTBWin = 'AMPSSplashAd_notifyRTBWin';
  static readonly splashNotifyRTBLoss = 'AMPSSplashAd_notifyRTBLoss';
  static readonly splashIsReadyAd = 'AMPSSplashAd_isReadyAd';

  static readonly interstitialLoad = 'AMPSInterstitial_load';
  static readonly interstitialShowAd = 'AMPSSInterstitial_showAd';
  static readonly interstitialGetECPM = 'AMPSSInterstitial_getECPM';
  static readonly interstitialNotifyRTBWin = 'AMPSInterstitial_notifyRTBWin';
  static readonly interstitialNotifyRTBLoss = 'AMPSInterstitial_notifyRTBLoss';
  static readonly interstitialIsReadyAd = 'AMPSInterstitial_isReadyAd';

  static readonly nativeLoad = 'AMPSNative_load';
  static readonly nativeShowAd = 'AMPSNative_showAd';
  static readonly nativeGetECPM = 'AMPSNative_getECPM';
  static readonly nativeNotifyRTBWin = 'AMPSNative_notifyRTBWin';
  static readonly nativeNotifyRTBLoss = 'AMPSNative_notifyRTBLoss';
  static readonly nativeIsReadyAd = 'AMPSNative_isReadyAd';
  static readonly nativeIsNativeExpress = 'AMPSNative_isNativeExpress';
  static readonly nativeGetVideoDuration = 'AMPSNative_getVideoDuration';
  static readonly nativeSetVideoPlayConfig = 'AMPSNative_setVideoPlayConfig';
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
    AMPSAdSdkMethodNames.splashLoad,
    AMPSAdSdkMethodNames.splashShowAd,
    AMPSAdSdkMethodNames.splashGetECPM,
    AMPSAdSdkMethodNames.splashNotifyRTBWin,
    AMPSAdSdkMethodNames.splashNotifyRTBLoss,
    AMPSAdSdkMethodNames.splashIsReadyAd
  ];

export let InterstitialMethodNames: string[] =
  [
    AMPSAdSdkMethodNames.interstitialLoad,
    AMPSAdSdkMethodNames.interstitialShowAd,
    AMPSAdSdkMethodNames.interstitialGetECPM,
    AMPSAdSdkMethodNames.interstitialNotifyRTBWin,
    AMPSAdSdkMethodNames.interstitialNotifyRTBLoss,
    AMPSAdSdkMethodNames.interstitialIsReadyAd,
  ];

export let NativeMethodNames: string[] = [
  AMPSAdSdkMethodNames.nativeLoad,
  AMPSAdSdkMethodNames.nativeShowAd,
  AMPSAdSdkMethodNames.nativeGetECPM,
  AMPSAdSdkMethodNames.nativeNotifyRTBWin,
  AMPSAdSdkMethodNames.nativeNotifyRTBLoss,
  AMPSAdSdkMethodNames.nativeIsReadyAd,
  AMPSAdSdkMethodNames.nativeIsNativeExpress,
  AMPSAdSdkMethodNames.nativeGetVideoDuration,
  AMPSAdSdkMethodNames.nativeSetVideoPlayConfig
];

