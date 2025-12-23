///原生和原生自渲染广告相关回调
///原生广告加载回调
typedef AdLoadCallback = void Function(List<String> adIds);
typedef AdLoadErrorCallback = void Function(int code, String message);
typedef OnComplainSuccess = void Function(String adId);

class AMPSNativeAdListener {
  final AdLoadCallback? loadOk;
  final AdLoadErrorCallback? loadFail;

  const AMPSNativeAdListener({this.loadOk, this.loadFail});
}

class AMPSNegativeFeedbackListener {
  final OnComplainSuccess onComplainSuccess;

  const AMPSNegativeFeedbackListener({required this.onComplainSuccess});
}

/// 渲染回调
typedef AMPSNativeRenderCallback = void Function(String adId);
typedef AMPSNativeRenderFailedCallback = void Function(
    String adId, int code, String message);

class AMPSNativeRenderListener {
  final AMPSNativeRenderCallback? renderSuccess;
  final AMPSNativeRenderFailedCallback? renderFailed;

  const AMPSNativeRenderListener({this.renderSuccess, this.renderFailed});
}

///广告View事件相关回调
typedef AdEventCallback = void Function(String? adId);

class AmpsNativeInteractiveListener {
  final AdEventCallback? onAdShow;
  final AdEventCallback? onAdExposure;
  final AdEventCallback? onAdClicked;
  final AdEventCallback? toCloseAd;

  const AmpsNativeInteractiveListener({
    this.onAdShow,
    this.onAdExposure,
    this.onAdClicked,
    this.toCloseAd,
  });
}

/// 视频相关回调
typedef VideoPlayerEventCallback = void Function(String adId);
typedef VideoPlayerErrorCallback = void Function(
    String adId, int code, String extra);

class AmpsVideoPlayListener {
  final VideoPlayerEventCallback? onVideoInit; //android有
  final VideoPlayerEventCallback? onVideoLoading; //android有
  final VideoPlayerEventCallback? onVideoReady;
  final VideoPlayerEventCallback? onVideoLoaded; //android有
  final VideoPlayerEventCallback? onVideoPlayStart;
  final VideoPlayerEventCallback? onVideoPlayComplete;
  final VideoPlayerEventCallback? onVideoPause;
  final VideoPlayerEventCallback? onVideoResume;
  final VideoPlayerEventCallback? onVideoStop; //android有
  final VideoPlayerEventCallback? onVideoClicked; //android有
  final VideoPlayerErrorCallback? onVideoPlayError;

  const AmpsVideoPlayListener({
    this.onVideoInit,
    this.onVideoLoading,
    this.onVideoReady,
    this.onVideoLoaded,
    this.onVideoPlayStart,
    this.onVideoPlayComplete,
    this.onVideoPause,
    this.onVideoResume,
    this.onVideoStop,
    this.onVideoClicked,
    this.onVideoPlayError,
  });
}

///Android下载相关回调
class AMPSUnifiedDownloadListener {
  final Function(int position, String adId)? onDownloadPaused;
  final Function(String adId)? onDownloadStarted;
  final Function(int position, String adId)? onDownloadProgressUpdate;
  final Function(String adId)? onDownloadFinished;
  final Function(String adId)? onDownloadFailed;
  final Function(String adId)? onInstalled;

  const AMPSUnifiedDownloadListener(
      {this.onDownloadPaused,
      this.onDownloadStarted,
      this.onDownloadProgressUpdate,
      this.onDownloadFinished,
      this.onDownloadFailed,
      this.onInstalled});
}

///Draw回调
class AMPSDrawAdListener {
  final AdLoadCallback? loadOk;
  final AdLoadErrorCallback? loadFail;

  const AMPSDrawAdListener({this.loadOk, this.loadFail});
}

typedef AMPSDrawRenderCallBack = void Function(String adId);
typedef AMPSDrawRenderFailedCallBack = void Function(
    String adId, int code, String message);

class AMPSDrawRenderListener {
  final AMPSDrawRenderCallBack? onAdShow;
  final AMPSDrawRenderCallBack? onAdClick;
  final AMPSDrawRenderCallBack? onAdClose;
  final AMPSDrawRenderCallBack? renderSuccess;
  final AMPSDrawRenderFailedCallBack? renderFailed;

  const AMPSDrawRenderListener(
      {this.onAdShow,
      this.onAdClick,
      this.onAdClose,
      this.renderSuccess,
      this.renderFailed});
}

typedef AMPSDrawVideoCallBack = void Function(String adId);
typedef AMPSDrawVideoFailedCallBack = void Function(
    String adId, int code, String message);
typedef AMPSDrawProgressUpdateCallBack = void Function(
    String adId, int current, int duration);

class AMPSDrawVideoListener {
  final AMPSDrawVideoCallBack? onVideoLoad;
  final AMPSDrawVideoFailedCallBack? onVideoError;
  final AMPSDrawVideoCallBack? onVideoAdStartPlay;
  final AMPSDrawVideoCallBack? onVideoAdPaused;
  final AMPSDrawVideoCallBack? onVideoAdContinuePlay;
  final AMPSDrawProgressUpdateCallBack? onProgressUpdate;
  final AMPSDrawVideoCallBack? onVideoAdComplete;

  AMPSDrawVideoListener(
      {this.onVideoLoad,
      this.onVideoError,
      this.onVideoAdStartPlay,
      this.onVideoAdPaused,
      this.onVideoAdContinuePlay,
      this.onProgressUpdate,
      this.onVideoAdComplete});
}
