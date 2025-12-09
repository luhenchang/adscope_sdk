package xyz.adscope.adscope_sdk.data

object StringConstants {
    const val EMPTY_STRING = ""
}

data class AdOptions(val spaceId: String)

object AMPSChannels {
    private const val CHANNEL_DOMAIN = "xyz.adscope.amps"

    const val AMPS_SDK_INIT = "$CHANNEL_DOMAIN/sdk"
    const val AMPS_SDK_SPLASH = "$CHANNEL_DOMAIN/splash"
    const val AMPS_SDK_SPLASH_AD_LOAD = "$CHANNEL_DOMAIN/splash_ad_load"
    const val AMPS_SDK_INTERSTITIAL_AD_LOAD = "$CHANNEL_DOMAIN/interstitial_ad_load"
    const val AMPS_SDK_NATIVE_AD_LOAD = "$CHANNEL_DOMAIN/native_ad_load"
}

object AMPSPlatformViewRegistry {
    private const val CHANNEL_DOMAIN = "xyz.adscope.amps"

    const val AMPS_SDK_SPLASH_VIEW_ID = "$CHANNEL_DOMAIN/splash_view_id"
    const val AMPS_SDK_INTERSTITIAL_VIEW_ID = "$CHANNEL_DOMAIN/interstitial_view_id"
    const val AMPS_SDK_NATIVE_VIEW_ID = "$CHANNEL_DOMAIN/native_view_id"
    const val AMPS_SDK_UNIFIED_VIEW_ID = "$CHANNEL_DOMAIN/unified_view_id"
    const val AMPS_SDK_BANNER_VIEW_ID = "$CHANNEL_DOMAIN/banner_view_id"
}

object AMPSInitChannelMethod {
    const val INIT_SUCCESS = "initSuccess"
    const val INITIALIZING = "initializing"
    const val ALREADY_INIT = "alreadyInit"
    const val INIT_FAILED = "initFailed"
}

object AMPSAdCallBackChannelMethod {
    const val ON_LOAD_SUCCESS = "onLoadSuccess"
    const val ON_LOAD_FAILURE = "onLoadFailure"
    const val ON_RENDER_OK = "onRenderOk"
    const val ON_AD_SHOW = "onAdShow"
    const val ON_AD_EXPOSURE = "onAdExposure"
    const val ON_AD_CLICKED = "onAdClicked"
    const val ON_AD_CLOSED = "onAdClosed"
    const val ON_RENDER_FAILURE = "onRenderFailure"
    const val ON_AD_SHOW_ERROR = "onAdShowError"
    const val ON_VIDEO_PLAY_START = "onVideoPlayStart"
    const val ON_VIDEO_PLAY_END = "onVideoPlayEnd"
    const val ON_VIDEO_PLAY_ERROR = "onVideoPlayError"
    const val ON_VIDEO_SKIP_TO_END = "onVideoSkipToEnd"
    const val ON_AD_REWARD = "onAdReward"
}

object AMPSNativeCallBackChannelMethod {
    // Ad loading callback identifiers
    const val LOAD_OK = "loadOk"
    const val LOAD_FAIL = "loadFail"
    const val RENDER_SUCCESS = "renderSuccess"
    const val RENDER_FAILED = "renderFailed"

    // Specific ad component callbacks
    const val ON_AD_SHOW = "onAdShow"
    const val ON_AD_EXPOSURE = "onAdExposure"
    const val ON_AD_EXPOSURE_FAIL = "onAdExposureFail"
    const val ON_AD_CLICKED = "onAdClicked"
    const val ON_AD_CLOSED = "onAdClosed"
    const val ON_COMPLAIN_SUCCESS = "onComplainSuccess"

    // Video component callbacks
    const val ON_VIDEO_INIT = "onVideoInit"; // 视频初始化
    const val ON_VIDEO_LOADING = "onVideoLoading"; // 视频加载中正在
    const val ON_VIDEO_READY = "onVideoReady" // Video ready
    const val ON_VIDEO_LOADED = "onVideoLoaded"; // 视频加载完成
    const val ON_VIDEO_PLAY_START = "onVideoPlayStart" // Video playback started
    const val ON_VIDEO_PLAY_COMPLETE = "onVideoPlayComplete" // Video playback completed
    const val ON_VIDEO_PAUSE = "onVideoPause" // Video paused
    const val ON_VIDEO_RESUME = "onVideoResume" // Video resumed
    const val ON_VIDEO_STOP = "onVideoStop"; // 视频停止
    const val ON_VIDEO_CLICKED = "onVideoClicked"; // 视频点击
    const val ON_VIDEO_PLAY_ERROR = "onVideoPlayError" // Video playback error
}

// 1. 先定义统一的回调方法常量（参考示例格式）
object AMPSRewardedVideoCallBackChannelMethod {
    // 基础广告回调（对应第二段代码核心回调）
    const val ON_LOAD_SUCCESS = "RewardedVideo_onLoadSuccess"
    const val ON_LOAD_FAILURE = "RewardedVideo_onLoadFailure"
    const val ON_AD_SHOW = "RewardedVideo_onAdShow"       // 对应 onAdDidShow + onAmpsAdShow
    const val ON_AD_CLICKED = "RewardedVideo_onAdClicked"
    const val ON_AD_CLOSED = "RewardedVideo_onAdClosed"     // 对应 onAmpsAdDismiss
    const val ON_AD_REWARD = "RewardedVideo_onAdReward"     // 对应 onAmpsAdRewardArrived

    // 视频相关回调（对应两段代码的视频回调）
    const val ON_VIDEO_PLAY_START = "RewardedVideo_onVideoPlayStart"
    const val ON_VIDEO_PLAY_END = "RewardedVideo_onVideoPlayEnd"       // 对应 onAmpsAdVideoComplete
    const val ON_VIDEO_PLAY_ERROR = "RewardedVideo_onVideoPlayError"   // 对应 onAmpsAdVideoError
    const val ON_VIDEO_SKIP_TO_END = "RewardedVideo_onVideoSkipToEnd"
    // 额外Android接口
    const val ON_AD_CACHED = "RewardedVideo_onAdCached"
}

//2. banner相关原生端回调
object AMPSBannerCallbackChannelMethod {
    const val ON_LOAD_SUCCESS = "Banner_onLoadSuccess"
    const val ON_LOAD_FAILURE = "Banner_onLoadFailure"
    const val ON_AD_SHOW = "Banner_onAdShow"
    const val ON_AD_CLICKED = "Banner_onAdClicked"
    const val ON_AD_CLOSED = "Banner_onAdClosed"
    const val ON_VIDEO_PLAY_START = "Banner_onVideoPlayStart"
    const val ON_VIDEO_PLAY_END = "Banner_onVideoPlayEnd"
    const val ON_VIDEO_PLAY_ERROR = "Banner_onVideoPlayError"
    const val ON_VIDEO_SKIP_TO_END = "Banner_onVideoSkipToEnd"
    const val ON_AD_REWARD = "Banner_onAdReward"
}

object DownLoadCallBackChannelMethod {
    const val ON_DOWNLOAD_PAUSED = "onDownloadPaused"
    const val ON_DOWNLOAD_STARTED = "onDownloadStarted"
    const val ON_DOWNLOAD_PROGRESS_UPDATE = "onDownloadProgressUpdate"
    const val ON_DOWNLOAD_FINISHED = "onDownloadFinished"
    const val ON_DOWNLOAD_FAILED = "onDownloadFailed"
    const val ON_INSTALLED = "onInstalled"
}

object AMPSAdSdkMethodNames {
    // Method name for initializing AMPS Ad SDK
    const val TEST_MODE = "testMode"
    const val INIT = "AMPSAdSdk_init"

    // Splash ad related methods
    const val SPLASH_CREATE = "AMPSSplashAd_create"
    const val SPLASH_LOAD = "AMPSSplashAd_load"
    const val SPLASH_SHOW_AD = "AMPSSplashAd_showAd"
    const val SPLASH_GET_ECPM = "AMPSSplashAd_getECPM"
    const val SPLASH_PRE_LOAD = "AMPSSplashAd_preLoad"
    const val SPLASH_ADD_PRE_LOAD_AD_INFO = "AMPSSplashAd_addPreLoadAdInfo"
    const val SPLASH_GET_MEDIA_EXTRA_INFO = "AMPSSplashAd_getMediaExtraInfo"
    const val SPLASH_IS_READY_AD = "AMPSSplashAd_isReadyAd"

    // Interstitial ad related methods
    const val INTERSTITIAL_CREATE = "AMPSInterstitial_create"
    const val INTERSTITIAL_LOAD = "AMPSInterstitial_load"
    const val INTERSTITIAL_PRE_LOAD = "AMPSInterstitial_preLoad"
    const val INTERSTITIAL_SHOW_AD = "AMPSInterstitial_showAd"
    const val INTERSTITIAL_GET_ECPM = "AMPSInterstitial_getECPM"
    const val INTERSTITIAL_IS_READY_AD = "AMPSInterstitial_isReadyAd"
    const val INTERSTITIAL_ADD_PRE_LOAD_AD_INFO = "AMPSInterstitial_addPreLoadAdInfo"
    const val INTERSTITIAL_GET_MEDIA_EXTRA_INFO = "AMPSInterstitial_getMediaExtraInfo"

    // Native ad related methods
    const val NATIVE_CREATE = "AMPSNative_create"
    const val NATIVE_LOAD = "AMPSNative_load"
    const val NATIVE_SHOW_AD = "AMPSNative_showAd"
    const val NATIVE_SIZE_UPDATE = "AMPSNative_SizeUpdate"
    const val NATIVE_PATTERN = "AMPSNative_getUnifiedPattern";
    const val NATIVE_GET_ECPM = "AMPSNative_getECPM"
    const val NATIVE_IS_READY_AD = "AMPSNative_isReadyAd"
    const val NATIVE_IS_NATIVE_EXPRESS = "AMPSNative_isNativeExpress"
    const val NATIVE_UNIFIED_MATERIAL_TYPE = "AMPSNative_materialType"
    const val NATIVE_UNIFIED_GET_DOWNLOAD = "AMPSNative_getDownLoad"
    const val NATIVE_RESUME = "AMPSNative_resume"
    const val NATIVE_PAUSE = "AMPSNative_pause"
    const val NATIVE_DESTROY = "AMPSNative_destroy"
    const val NATIVE_GET_MEDIA_EXTRA_INFO = "AMPSNative_getMediaExtraInfo"

    // Rewarded ad related methods
    const val REWARDED_VIDEO_CREATE = "AMPSRewardVideo_create"
    const val REWARDED_VIDEO_LOAD = "AMPSRewardVideo_load"
    const val REWARDED_VIDEO_PRE_LOAD = "AMPSRewardVideo_preLoad"
    const val REWARDED_VIDEO_SHOW_AD = "AMPSRewardVideo_showAd"
    const val REWARDED_VIDEO_DESTROY_AD = "AMPSRewardVideo_destroy"
    const val REWARDED_VIDEO_GET_ECPM = "AMPSRewardVideo_getECPM"
    const val REWARDED_VIDEO_IS_READY_AD = "AMPSRewardVideo_isReadyAd"
    const val REWARDED_VIDEO_ADD_PRE_LOAD_AD_INFO = "AMPSRewardVideo_addPreLoadAdInfo"
    const val REWARDED_VIDEO_GET_MEDIA_EXTRA_INFO = "AMPSRewardVideo_getMediaExtraInfo"

    // Banner ad related methods
    const val BANNER_CREATE = "AMPSBanner_create"
    const val BANNER_LOAD = "AMPSBanner_load"
    const val BANNER_PRE_LOAD = "AMPSBanner_preLoad"
    const val BANNER_SHOW_AD = "AMPSBanner_showAd"
    const val BANNER_GET_ECPM = "AMPSBanner_getECPM"
    const val BANNER_IS_READY_AD = "AMPSBanner_isReadyAd"
    const val BANNER_DESTROY_AD = "AMPSBanner_destroy"
    const val BANNER_ADD_PRE_LOAD_AD_INFO = "AMPSBanner_addPreLoadAdInfo"
    const val BANNER_GET_MEDIA_EXTRA_INFO = "AMPSBanner_getMediaExtraInfo"
}

// Constants for argument keys or other string values
const val NATIVE_WIDTH = "width"
const val NATIVE_HEIGHT = "height"
const val NATIVE_TYPE = "nativeType"
const val AD_WIN_PRICE = "winPrice"
const val AD_SEC_PRICE = "secPrice"
const val AD_ID = "adId"
const val AD_LOSS_REASON = "lossReason"
const val AD_OPTION = "AdOption"
const val CONFIG = "config"
const val SPLASH_BOTTOM = "SplashBottomView"
const val VIDEO_SOUND = "videoSoundEnable"
const val VIDEO_PLAY_TYPE = "videoAutoPlayType"
const val VIDEO_LOOP_REPLAY = "videoLoopReplay"

enum class NativeType(val value: Int) {
    // 原生广告
    NATIVE(0),
    // 原生自渲染
    UNIFIED(1);
}

val InitMethodNames: Set<String> = setOf(
    AMPSAdSdkMethodNames.INIT
)

val SplashMethodNames: Set<String> = setOf(
    AMPSAdSdkMethodNames.SPLASH_CREATE,
    AMPSAdSdkMethodNames.SPLASH_LOAD,
    AMPSAdSdkMethodNames.SPLASH_SHOW_AD,
    AMPSAdSdkMethodNames.SPLASH_GET_ECPM,
    AMPSAdSdkMethodNames.SPLASH_PRE_LOAD,
    AMPSAdSdkMethodNames.SPLASH_ADD_PRE_LOAD_AD_INFO,
    AMPSAdSdkMethodNames.SPLASH_GET_MEDIA_EXTRA_INFO,
    AMPSAdSdkMethodNames.SPLASH_IS_READY_AD
)

val InterstitialMethodNames: Set<String> = setOf(
    AMPSAdSdkMethodNames.INTERSTITIAL_CREATE,
    AMPSAdSdkMethodNames.INTERSTITIAL_LOAD,
    AMPSAdSdkMethodNames.INTERSTITIAL_PRE_LOAD,
    AMPSAdSdkMethodNames.INTERSTITIAL_SHOW_AD,
    AMPSAdSdkMethodNames.INTERSTITIAL_GET_ECPM,
    AMPSAdSdkMethodNames.INTERSTITIAL_IS_READY_AD,
    AMPSAdSdkMethodNames.INTERSTITIAL_ADD_PRE_LOAD_AD_INFO,
    AMPSAdSdkMethodNames.INTERSTITIAL_GET_MEDIA_EXTRA_INFO
)

val NativeMethodNames: Set<String> = setOf(
    AMPSAdSdkMethodNames.NATIVE_CREATE,
    AMPSAdSdkMethodNames.NATIVE_LOAD,
    AMPSAdSdkMethodNames.NATIVE_SHOW_AD,
    AMPSAdSdkMethodNames.NATIVE_GET_ECPM,
    AMPSAdSdkMethodNames.NATIVE_PATTERN,
    AMPSAdSdkMethodNames.NATIVE_IS_READY_AD,
    AMPSAdSdkMethodNames.NATIVE_IS_NATIVE_EXPRESS,
    AMPSAdSdkMethodNames.NATIVE_RESUME,
    AMPSAdSdkMethodNames.NATIVE_PAUSE,
    AMPSAdSdkMethodNames.NATIVE_DESTROY,
    AMPSAdSdkMethodNames.NATIVE_GET_MEDIA_EXTRA_INFO,
    AMPSAdSdkMethodNames.NATIVE_UNIFIED_MATERIAL_TYPE,
    AMPSAdSdkMethodNames.NATIVE_UNIFIED_GET_DOWNLOAD


)

val RewardedVideoMethodNames: Set<String> = setOf(
    AMPSAdSdkMethodNames.REWARDED_VIDEO_CREATE,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_LOAD,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_PRE_LOAD,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_SHOW_AD,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_DESTROY_AD,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_ECPM,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_IS_READY_AD,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_ADD_PRE_LOAD_AD_INFO,
    AMPSAdSdkMethodNames.REWARDED_VIDEO_GET_MEDIA_EXTRA_INFO
)

val BannerMethodNames: Set<String> = setOf(
    AMPSAdSdkMethodNames.BANNER_CREATE,
    AMPSAdSdkMethodNames.BANNER_LOAD,
    AMPSAdSdkMethodNames.BANNER_PRE_LOAD,
    AMPSAdSdkMethodNames.BANNER_SHOW_AD,
    AMPSAdSdkMethodNames.BANNER_GET_ECPM,
    AMPSAdSdkMethodNames.BANNER_IS_READY_AD,
    AMPSAdSdkMethodNames.BANNER_DESTROY_AD,
    AMPSAdSdkMethodNames.BANNER_ADD_PRE_LOAD_AD_INFO,
    AMPSAdSdkMethodNames.BANNER_GET_MEDIA_EXTRA_INFO
)
