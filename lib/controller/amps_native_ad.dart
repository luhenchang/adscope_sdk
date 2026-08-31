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
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeCreate,
      _wrapArgs(config.toMap(nativeType: nativeType)),
    );
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
          mapArgs[AMPSSdkCallBackErrorKey.code],
          mapArgs[AMPSSdkCallBackErrorKey.message],
        );
        break;
      case AMPSNativeCallBackChannelMethod.renderSuccess:
        mRenderCallBack?.renderSuccess?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
        break;
      case AMPSNativeCallBackChannelMethod.renderFailed:
        mRenderCallBack?.renderFailed?.call(
          mapArgs[AMPSSdkCallBackErrorKey.adId],
          mapArgs[AMPSSdkCallBackErrorKey.code],
          mapArgs[AMPSSdkCallBackErrorKey.message],
        );
        break;
      case AMPSNativeCallBackChannelMethod.onCarouselAdLoad:
        mRenderCallBack?.onCarouselAdLoad?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
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
            adId,
            mapArgs[AMPSSdkCallBackErrorKey.code],
            mapArgs[AMPSSdkCallBackErrorKey.extra],
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

  void load() async {
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeLoad,
      _typedArgs(),
    );
  }

  //自渲染类型
  Future<List<String>> getUnifiedImages(String adId) async {
    final images = await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeImages,
      _argsWithAdId(adId),
    );
    if (images is List) {
      return images.map((item) => item?.toString() ?? '').where((url) => url.isNotEmpty).toList();
    }
    return const [];
  }

  //自渲染类型
  Future<AMPSUnifiedPattern> getUnifiedPattern(String adId) async {
    final pattern = await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativePattern,
      _argsWithAdId(adId),
    );
    return AMPSUnifiedPattern.fromValue(pattern);
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
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeDestroy,
      _typedArgs(),
    );
  }

  ///失去焦点
  Future<void> resume() async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeResume,
      _typedArgs(),
    );
  }

  ///失去焦点
  Future<void> pause() async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativePause,
      _typedArgs(),
    );
  }

  ///获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeIsReadyAd,
      _argsWithAdId(adId),
    );
  }

  ///获取ecpm
  Future<num> getECPM(String adId) async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeGetECPM,
      _argsWithAdId(adId),
    );
  }

  ///获取胜出渠道的seatId
  Future<String?> getSeatId() async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeGetSeatId,
      _typedArgs(),
    );
  }

  ///获取是否是自渲染
  Future<bool> isNativeExpress(String adId) async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.nativeIsNativeExpress,
      _argsWithAdId(adId),
    );
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
