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
