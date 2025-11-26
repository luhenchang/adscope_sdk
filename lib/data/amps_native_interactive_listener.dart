///原生和原生自渲染广告相关回调
///原生广告加载回调
typedef AdLoadCallback = void Function(List<String> adIds);
typedef AdLoadErrorCallback = void Function(int code, String message);

class AmpsNativeAdListener {
  final AdLoadCallback? loadOk;
  final AdLoadErrorCallback? loadFail;

  const AmpsNativeAdListener({this.loadOk, this.loadFail});
}

/// 渲染回调
typedef AMPSNativeRenderCallback = void Function(String adId);
typedef AMPSNativeRenderFailedCallback = void Function(String adId, int code, String message);

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
typedef VideoPlayerErrorCallback = void Function(String adId, int code, String extra);

class AmpsVideoPlayListener {
  final VideoPlayerEventCallback? onVideoInit;//android有
  final VideoPlayerEventCallback? onVideoLoading;//android有
  final VideoPlayerEventCallback? onVideoReady;
  final VideoPlayerEventCallback? onVideoLoaded;//android有
  final VideoPlayerEventCallback? onVideoPlayStart;
  final VideoPlayerEventCallback? onVideoPlayComplete;
  final VideoPlayerEventCallback? onVideoPause;
  final VideoPlayerEventCallback? onVideoResume;
  final VideoPlayerEventCallback? onVideoStop;//android有
  final VideoPlayerEventCallback? onVideoClicked;//android有
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
  final Function(int position,String adId)? onDownloadPaused;
  final Function(String adId)? onDownloadStarted;
  final Function(int position,String adId)? onDownloadProgressUpdate;
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
