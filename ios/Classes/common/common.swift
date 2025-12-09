//
//  common.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation

// 字符串常量
enum StringConstants {
    static let emptyString = ""
}

// 广告配置数据类
struct AdOptions {
    let spaceId: String
}

// 频道常量
enum AMPSChannels {
    private static let channelDomain = "xyz.adscope.amps"
    
    static let ampsSdkInit = "\(channelDomain)/sdk"
    static let ampsSdkSplash = "\(channelDomain)/splash"
    static let ampsSdkSplashAdLoad = "\(channelDomain)/splash_ad_load"
    static let ampsSdkInterstitialAdLoad = "\(channelDomain)/interstitial_ad_load"
    static let ampsSdkNativeAdLoad = "\(channelDomain)/native_ad_load"
}

// 平台视图注册常量
enum AMPSPlatformViewIds {
    private static let channelDomain = "xyz.adscope.amps"  // 若可访问可改为 AMPSChannels.channelDomain
    
    static let splashViewId = "\(channelDomain)/splash_view_id"
    static let interstitialViewId = "\(channelDomain)/interstitial_view_id"
    static let nativeViewId = "\(channelDomain)/native_view_id"
    static let unifiedViewId = "\(channelDomain)/unified_view_id"
}

// 初始化相关方法名
enum AMPSInitChannelMethod {
    static let initSuccess = "initSuccess"
    static let initializing = "initializing"
    static let alreadyInit = "alreadyInit"
    static let initFailed = "initFailed"
}

// 广告回调方法名
enum AMPSAdCallBackChannelMethod {
    static let onLoadSuccess = "onLoadSuccess"
    static let onLoadFailure = "onLoadFailure"
    static let onRenderOk = "onRenderOk"
    static let onAdShow = "onAdShow"
    static let onAdExposure = "onAdExposure"
    static let onAdClicked = "onAdClicked"
    static let onAdClosed = "onAdClosed"
    static let onRenderFailure = "onRenderFailure"
    static let onAdShowError = "onAdShowError"
    static let onVideoPlayStart = "onVideoPlayStart"
    static let onVideoPlayEnd = "onVideoPlayEnd"
    static let onVideoPlayError = "onVideoPlayError"
    static let onVideoSkipToEnd = "onVideoSkipToEnd"
    static let onAdReward = "onAdReward"
}

// 原生广告回调方法名
enum AMPSNativeCallBackChannelMethod {
    // 广告加载回调标识
    static let loadOk = "loadOk"
    static let loadFail = "loadFail"
    static let renderSuccess = "renderSuccess"
    static let renderFailed = "renderFailed"
    
    // 特定广告组件回调
    static let onAdShow = "onAdShow"
    static let onAdExposure = "onAdExposure"
    static let onAdClicked = "onAdClicked"
    static let onAdClosed = "onAdClosed"  // 广告关闭
    static let nativeSizeUpdate = "AMPSNative_SizeUpdate"
    
    // 视频组件回调
    static let onVideoReady = "onVideoReady"  // 视频就绪
    static let onVideoPlayStart = "onVideoPlayStart"  // 视频开始播放
    static let onVideoPlayComplete = "onVideoPlayComplete"  // 视频播放完成
    static let onVideoPause = "onVideoPause"  // 视频暂停
    static let onVideoResume = "onVideoResume"  // 视频恢复
    static let onVideoPlayError = "onVideoPlayError"  // 视频播放错误
}

// 广告SDK方法名
enum AMPSAdSdkMethodNames {
    // AMPS广告SDK初始化方法名
    static let testMode = "testMode"
    static let sdk_init = "AMPSAdSdk_init"
    
    // 开屏广告相关方法
    static let splashCreate = "AMPSSplashAd_create"
    static let splashLoad = "AMPSSplashAd_load"
    static let splashShowAd = "AMPSSplashAd_showAd"
    static let splashGetEcpm = "AMPSSplashAd_getECPM"
    static let splashNotifyRtbWin = "AMPSSplashAd_notifyRTBWin"
    static let splashNotifyRtbLoss = "AMPSSplashAd_notifyRTBLoss"
    static let splashIsReadyAd = "AMPSSplashAd_isReadyAd"
    
    // 插屏广告相关方法
    static let interstitialCreate = "AMPSInterstitial_create"
    static let interstitialLoad = "AMPSInterstitial_load"
    static let interstitialShowAd = "AMPSInterstitial_showAd"
    static let interstitialGetEcpm = "AMPSSInterstitial_getECPM"
    static let interstitialNotifyRtbWin = "AMPSInterstitial_notifyRTBWin"
    static let interstitialNotifyRtbLoss = "AMPSInterstitial_notifyRTBLoss"
    static let interstitialIsReadyAd = "AMPSInterstitial_isReadyAd"
    
    // 原生广告相关方法
    static let nativeCreate = "AMPSNative_create"
    static let nativeLoad = "AMPSNative_load"
    static let nativeShowAd = "AMPSNative_showAd"
    static let nativeGetEcpm = "AMPSNative_getECPM"
    static let nativeNotifyRtbWin = "AMPSNative_notifyRTBWin"
    static let nativeNotifyRtbLoss = "AMPSNative_notifyRTBLoss"
    static let nativeIsReadyAd = "AMPSNative_isReadyAd"
    static let nativeIsNativeExpress = "AMPSNative_isNativeExpress"
    static let nativeGetVideoDuration = "AMPSNative_getVideoDuration"
    static let nativeSetVideoPlayConfig = "AMPSNative_setVideoPlayConfig"
    static let nativeGetUnifiedPattern = "AMPSNative_getUnifiedPattern"
    static let nativeGetDownLoad  = "AMPSNative_getDownLoad"
}
enum AdOptionKeys{
    static let keySpaceId = "spaceId"
    static let keyAdCount = "adCount"
    static let keyS2SImpl = "s2sImpl"
    static let keyTimeoutInterval = "timeoutInterval"
    static let keyExpressSize = "expressSize"
    static let keySplashBottomHeight = "splashAdBottomBuilderHeight"
    static let keyUserId = "userId"
    static let keyExtra = "extra"
    static let keyIpAddress = "ipAddress"
}

enum ArgumentKeys {
    // 参数键或其他字符串值的常量
    static let adWinPrice = "winPrice"
    static let adSecPrice = "secPrice"
    static let adId = "adId"
    static let adLossReason = "lossReason"
    static let adOption = "AdOption"
    static let config = "config"
    static let splashBottom = "SplashBottomView"
    static let videoSound = "videoSoundEnable"
    static let videoPlayType = "videoAutoPlayType"
    static let videoLoopReplay = "videoLoopReplay"
}
enum BidKeys{
    static let winPrince = "AMPS_WIN_PRICE"
    static let winADNId = "AMPS_WIN_ADNID"
    static let lossSecondPrice = "AMPS_HIGHRST_LOSS_PRICE"
    static let lossReason = "AMPS_LOSS_REASON"
    static let expectPrice = "AMPS_EXPECT_PRICE"
}

// 默认广告配置
let defaultAdOption = AdOptions(spaceId: StringConstants.emptyString)

// 方法名集合
let initMethodNames: Set<String> = [
    AMPSAdSdkMethodNames.sdk_init
]

let splashMethodNames: Set<String> = [
    AMPSAdSdkMethodNames.splashCreate,
    AMPSAdSdkMethodNames.splashLoad,
    AMPSAdSdkMethodNames.splashShowAd,
    AMPSAdSdkMethodNames.splashGetEcpm,
    AMPSAdSdkMethodNames.splashNotifyRtbWin,
    AMPSAdSdkMethodNames.splashNotifyRtbLoss,
    AMPSAdSdkMethodNames.splashIsReadyAd
]

let interstitialMethodNames: Set<String> = [
    AMPSAdSdkMethodNames.interstitialCreate,
    AMPSAdSdkMethodNames.interstitialLoad,
    AMPSAdSdkMethodNames.interstitialShowAd,
    AMPSAdSdkMethodNames.interstitialGetEcpm,
    AMPSAdSdkMethodNames.interstitialNotifyRtbWin,
    AMPSAdSdkMethodNames.interstitialNotifyRtbLoss,
    AMPSAdSdkMethodNames.interstitialIsReadyAd
]

let nativeMethodNames: Set<String> = [
    AMPSAdSdkMethodNames.nativeCreate,
    AMPSAdSdkMethodNames.nativeLoad,
    AMPSAdSdkMethodNames.nativeShowAd,
    AMPSAdSdkMethodNames.nativeGetEcpm,
    AMPSAdSdkMethodNames.nativeNotifyRtbWin,
    AMPSAdSdkMethodNames.nativeNotifyRtbLoss,
    AMPSAdSdkMethodNames.nativeIsReadyAd,
    AMPSAdSdkMethodNames.nativeIsNativeExpress,
    AMPSAdSdkMethodNames.nativeGetVideoDuration,
    AMPSAdSdkMethodNames.nativeSetVideoPlayConfig,
    AMPSAdSdkMethodNames.nativeGetUnifiedPattern,
    AMPSAdSdkMethodNames.nativeGetDownLoad
]
