import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_native_interactive_listener.dart';
import '../data/amps_ad.dart';
import '../data/unified_ad_download_app_info.dart';
import '../data/unified_pattern.dart';
import 'native_callback_router.dart';

///原生广告类
class AMPSNativeAd {
  static int _instanceCounter = 0;

  /// 实例唯一标识，与原生 [AMPSAdInstanceKey.adInstanceId] 对应。
  final String instanceId;

  NativeType nativeType = NativeType.native;

  ///默认原生模式【鸿蒙中原生和自渲染是一样的调用入口；Android是两个不同的入口，所以这里需要说明文档说明】
  AdOptions config;
  AMPSNativeAdListener? mCallBack;
  AMPSNativeRenderListener? mRenderCallBack;
  AdWidgetSizeCall? updateSize;

  Map<String, AdWidgetSizeCall> updateSizeMap = {};
  Map<String, AmpsNativeInteractiveListener> mInteractiveCallBackMap = {};
  Map<String, AmpsVideoPlayListener> mVideoPlayerCallBackMap = {};
  Map<String, VoidCallback> mCloseWidgetCallMap = {};
  Map<String, AMPSUnifiedDownloadListener> mDownloadListenerMap = {};
  Map<String, AMPSNegativeFeedbackListener> mNegativeFeedbackListenerMap = {};

  AMPSNativeAd({
    required this.config,
    this.nativeType = NativeType.native,
    this.mCallBack,
    this.mRenderCallBack,
    String? instanceId,
  }) : instanceId = instanceId ?? _generateInstanceId() {
    NativeCallbackRouter.instance.register(this.instanceId, _handleCall);
    _createNativeAd();
  }

  ///创建原生广告实例，失败时通过loadFail通知，避免静默失败
  Future<void> _createNativeAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeCreate,
        _wrapArgs(config.toMap(nativeType: nativeType)),
      );
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///将原生端返回的错误转发给loadFail回调
  void _notifyLoadFailure(PlatformException e) {
    mCallBack?.loadFail?.call(int.tryParse(e.code) ?? -1, e.message ?? e.code);
  }

  ///回调参数中的错误码可能为null或非int类型，统一安全转换，避免回调分发时抛类型错误
  static int _safeCode(dynamic code) {
    if (code is int) return code;
    if (code is num) return code.toInt();
    if (code is String) return int.tryParse(code) ?? -1;
    return -1;
  }

  ///回调参数中的错误信息可能为null，统一安全转换
  static String _safeMessage(dynamic message) {
    return message?.toString() ?? 'unknown error';
  }

  static String _generateInstanceId() {
    _instanceCounter += 1;
    return 'native_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _wrapArgs(Map<dynamic, dynamic> args) {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      ...args,
    };
  }

  Map<String, dynamic> _typedArgs() {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      adNativeType: nativeType.value,
    };
  }

  Map<String, dynamic> _argsWithAdId(String adId) {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      adNativeType: nativeType.value,
      adAdId: adId,
    };
  }

  Future<void> _handleCall(MethodCall call) async {
    final args = call.arguments;
    final mapArgs = args is Map ? args : const <dynamic, dynamic>{};
    switch (call.method) {
      case AMPSNativeCallBackChannelMethod.loadOk:
        final list = (mapArgs["adIds"] as List?)?.cast<String>();
        if (list != null) {
          mCallBack?.loadOk?.call(list);
        }
        break;
      case AMPSNativeCallBackChannelMethod.loadFail:
        mCallBack?.loadFail?.call(
          _safeCode(mapArgs[AMPSSdkCallBackErrorKey.code]),
          _safeMessage(mapArgs[AMPSSdkCallBackErrorKey.message]),
        );
        break;
      case AMPSNativeCallBackChannelMethod.renderSuccess:
        mRenderCallBack?.renderSuccess?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
        break;
      case AMPSNativeCallBackChannelMethod.renderFailed:
        mRenderCallBack?.renderFailed?.call(
          mapArgs[AMPSSdkCallBackErrorKey.adId]?.toString() ?? '',
          _safeCode(mapArgs[AMPSSdkCallBackErrorKey.code]),
          _safeMessage(mapArgs[AMPSSdkCallBackErrorKey.message]),
        );
        break;
      case AMPSNativeCallBackChannelMethod.onAdShow:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mInteractiveCallBackMap[adId]?.onAdShow?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onAdExposure:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mInteractiveCallBackMap[adId]?.onAdExposure?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onAdClicked:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mInteractiveCallBackMap[adId]?.onAdClicked?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onAdClosed:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mCloseWidgetCallMap[adId]?.call();
          mInteractiveCallBackMap[adId]?.toCloseAd?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onComplainSuccess:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mNegativeFeedbackListenerMap[adId]?.onComplainSuccess.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoInit:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoInit?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoLoading:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoLoading?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoReady:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoReady?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoLoaded:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoLoaded?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPlayStart:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoPlayStart?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPlayComplete:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoPlayComplete?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPause:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoPause?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoResume:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoResume?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoStop:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoStop?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoClicked:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoClicked?.call(adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.onVideoPlayError:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoPlayError?.call(
            adId?.toString() ?? '',
            _safeCode(mapArgs[AMPSSdkCallBackErrorKey.code]),
            _safeMessage(mapArgs[AMPSSdkCallBackErrorKey.extra]),
          );
        }
        break;
      case DownLoadCallBackChannelMethod.onInstalled:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId] as String?;
          mDownloadListenerMap[adId]?.onInstalled?.call(adId ?? '');
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadFailed:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId] as String?;
          mDownloadListenerMap[adId]?.onDownloadFailed?.call(adId ?? '');
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadStarted:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId] as String?;
          mDownloadListenerMap[adId]?.onDownloadStarted?.call(adId ?? '');
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadFinished:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId] as String?;
          mDownloadListenerMap[adId]?.onDownloadFinished?.call(adId ?? '');
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadProgressUpdate:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId] as String? ?? '';
          final position = mapArgs["position"] ?? 0;
          mDownloadListenerMap[adId]?.onDownloadProgressUpdate?.call(position, adId);
        }
        break;
      case DownLoadCallBackChannelMethod.onDownloadPaused:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId] as String? ?? '';
          final position = mapArgs["position"] ?? 0;
          mDownloadListenerMap[adId]?.onDownloadPaused?.call(position, adId);
        }
        break;
      case AMPSNativeCallBackChannelMethod.nativeSizeUpdate:
        try {
          final param = Map<String, dynamic>.from(mapArgs);
          double width = 0;
          double height = 0;
          if (param.containsKey("width")) {
            width = param["width"] is num ? (param["width"] as num).toDouble() : 0;
          }
          if (param.containsKey("height")) {
            height = param["height"] is num ? (param["height"] as num).toDouble() : 0;
          }
          width = width >= 0 ? width : 0;
          height = height >= 0 ? height : 0;
          if (param.containsKey("adId")) {
            final adId = param["adId"];
            updateSizeMap[adId]?.call(width, height);
          }
        } catch (e, stackTrace) {
          debugPrint("nativeSizeUpdate-Error: $e");
          debugPrint("Stack trace: $stackTrace");
        }
        break;
    }
  }

  ///加载调用，失败时通过loadFail通知
  void load() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeLoad,
        _typedArgs(),
      );
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  //自渲染类型，异常时返回空列表
  Future<List<String>> getUnifiedImages(String adId) async {
    try {
      final images = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeImages,
        _argsWithAdId(adId),
      );
      if (images is List) {
        return images.map((item) => item?.toString() ?? '').where((url) => url.isNotEmpty).toList();
      }
      return const [];
    } on PlatformException {
      return const [];
    }
  }

  //自渲染类型，异常时返回未知类型
  Future<AMPSUnifiedPattern> getUnifiedPattern(String adId) async {
    try {
      final pattern = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativePattern,
        _argsWithAdId(adId),
      );
      return AMPSUnifiedPattern.fromValue(pattern);
    } on PlatformException {
      return AMPSUnifiedPattern.adPatternUnknown;
    }
  }

  //下载相关信息
  Future<UnifiedAdDownloadAppInfo?> getDownLoadInfo(String adId) async {
    try {
      final dynamic appInfo = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeUnifiedGetDownLoad,
        _argsWithAdId(adId),
      );
      Map<String, dynamic>? dataMap;
      if (appInfo != null) {
        dataMap = Map<String, dynamic>.from(appInfo);
      }
      return UnifiedAdDownloadAppInfo.fromMap(dataMap);
    } on PlatformException catch (e) {
      throw Exception('调用getDownLoadInfo失败: ${e.message}');
    }
  }

  ///获取信息
  Future<dynamic> getMediaExtraInfo() async {
    try {
      final mediaExtraInfo = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeGetMediaExtraInfo,
        _typedArgs(),
      );
      return mediaExtraInfo;
    } on PlatformException catch (e) {
      throw Exception('调用getCustomExtraData失败: ${e.message}');
    }
  }

  ///销毁
  Future<void> destroy() async {
    NativeCallbackRouter.instance.unregister(instanceId);
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeDestroy,
        _typedArgs(),
      );
    } on PlatformException {
      // 销毁失败不影响业务流程，但不能抛出未捕获异常
    }
  }

  ///失去焦点
  Future<void> resume() async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeResume,
        _typedArgs(),
      );
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///失去焦点
  Future<void> pause() async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativePause,
        _typedArgs(),
      );
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///获取是否有预加载，异常时返回false
  Future<bool> isReadyAd(String adId) async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeIsReadyAd,
        _argsWithAdId(adId),
      ) ?? false;
    } on PlatformException {
      return false;
    }
  }

  ///获取ecpm，异常时返回0
  Future<num> getECPM(String adId) async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeGetECPM,
        _argsWithAdId(adId),
      ) ?? 0;
    } on PlatformException {
      return 0;
    }
  }

  ///获取胜出渠道的seatId，异常时返回null
  Future<String?> getSeatId() async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeGetSeatId,
        _typedArgs(),
      );
    } on PlatformException {
      return null;
    }
  }

  ///获取是否是自渲染，异常时返回false
  Future<bool> isNativeExpress(String adId) async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.nativeIsNativeExpress,
        _argsWithAdId(adId),
      ) ?? false;
    } on PlatformException {
      return false;
    }
  }

  void setAdCloseCallBack(String adId, VoidCallback? closeWidgetCall) {
    if (closeWidgetCall != null) {
      mCloseWidgetCallMap[adId] = closeWidgetCall;
    }
  }

  void setDownloadListener(String adId, AMPSUnifiedDownloadListener? downloadListener) {
    if (downloadListener != null) {
      mDownloadListenerMap[adId] = downloadListener;
    }
  }

  void setInteractiveListener(String adId, AmpsNativeInteractiveListener? listener) {
    if (listener != null) {
      mInteractiveCallBackMap[adId] = listener;
    }
  }

  void setVideoPlayerListener(String adId, AmpsVideoPlayListener? listener) {
    if (listener != null) {
      mVideoPlayerCallBackMap[adId] = listener;
    }
  }

  void setNegativeFeedbackListener(String adId, AMPSNegativeFeedbackListener? listener) {
    if (listener != null) {
      mNegativeFeedbackListenerMap[adId] = listener;
    }
  }

  void setSizeUpdate(String adId, AdWidgetSizeCall? func) {
    if (func != null) {
      updateSizeMap[adId] = func;
    }
  }
}
