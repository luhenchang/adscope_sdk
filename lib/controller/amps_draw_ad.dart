import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_native_interactive_listener.dart';
import '../data/amps_ad.dart';
import 'draw_callback_router.dart';

///Draw 广告类
class AMPSDrawAd {
  static int _instanceCounter = 0;

  /// 实例唯一标识，与原生 [AMPSAdInstanceKey.adInstanceId] 对应。
  final String instanceId;

  AdOptions config;
  AMPSDrawAdListener? mCallBack;
  AMPSDrawRenderListener? mRenderCallBack;
  AdWidgetSizeCall? updateSize;
  Map<String, AdWidgetSizeCall> updateSizeMap = {};
  Map<String, AMPSDrawVideoListener> mVideoPlayerCallBackMap = {};
  Map<String, VoidCallback> mCloseWidgetCallMap = {};

  AMPSDrawAd({
    required this.config,
    this.mCallBack,
    this.mRenderCallBack,
    String? instanceId,
  }) : instanceId = instanceId ?? _generateInstanceId() {
    DrawCallbackRouter.instance.register(this.instanceId, _handleCall);
    _createNativeAd();
  }

  ///创建原生广告实例，失败时通过loadFail通知，避免静默失败
  Future<void> _createNativeAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.drawCreate,
        _wrapArgs(config.toMap()),
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
    return 'draw_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _wrapArgs(Map<dynamic, dynamic> args) {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      ...args,
    };
  }

  Map<String, dynamic> _instanceOnlyArgs() {
    return {AMPSAdInstanceKey.adInstanceId: instanceId};
  }

  Map<String, dynamic> _argsWithAdId(String adId) {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      adAdId: adId,
    };
  }

  Future<void> _handleCall(MethodCall call) async {
    final args = call.arguments;
    final mapArgs = args is Map ? args : const <dynamic, dynamic>{};
    switch (call.method) {
      case AmpsDrawCallbackChannelMethod.onLoadSuccess:
        final list = (mapArgs["adIds"] as List?)?.cast<String>();
        if (list != null) {
          mCallBack?.loadOk?.call(list);
        }
        break;
      case AmpsDrawCallbackChannelMethod.onLoadFailure:
        mCallBack?.loadFail?.call(
          _safeCode(mapArgs[AMPSSdkCallBackErrorKey.code]),
          _safeMessage(mapArgs[AMPSSdkCallBackErrorKey.message]),
        );
        break;
      case AmpsDrawCallbackChannelMethod.onRenderSuccess:
        mRenderCallBack?.renderSuccess?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
        break;
      case AmpsDrawCallbackChannelMethod.onRenderFail:
        mRenderCallBack?.renderFailed?.call(
          mapArgs[AMPSSdkCallBackErrorKey.adId]?.toString() ?? '',
          _safeCode(mapArgs[AMPSSdkCallBackErrorKey.code]),
          _safeMessage(mapArgs[AMPSSdkCallBackErrorKey.message]),
        );
        break;
      case AmpsDrawCallbackChannelMethod.onAdShow:
        mRenderCallBack?.onAdShow?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
        break;
      case AmpsDrawCallbackChannelMethod.onAdClicked:
        mRenderCallBack?.onAdClick?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
        break;
      case AmpsDrawCallbackChannelMethod.onAdClosed:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mCloseWidgetCallMap[adId]?.call();
          mRenderCallBack?.onAdClose?.call(adId);
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoLoad:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoLoad?.call(adId);
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoPlayStart:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoAdStartPlay?.call(adId);
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoPlayPause:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoAdPaused?.call(adId);
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoAdContinuePlay:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoAdContinuePlay?.call(adId);
        }
        break;
      case AmpsDrawCallbackChannelMethod.onProgressUpdate:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onProgressUpdate?.call(
            adId?.toString() ?? '',
            (mapArgs[AMPSSdkCallBackErrorKey.current] as num?)?.toInt() ?? 0,
            (mapArgs[AMPSSdkCallBackErrorKey.duration] as num?)?.toInt() ?? 0,
          );
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoError:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoError?.call(
            adId?.toString() ?? '',
            _safeCode(mapArgs[AMPSSdkCallBackErrorKey.code]),
            _safeMessage(mapArgs[AMPSSdkCallBackErrorKey.message]),
          );
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoAdComplete:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoAdComplete?.call(adId);
        }
        break;
      case AmpsDrawCallbackChannelMethod.drawSizeUpdate:
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
          debugPrint("drawSizeUpdate-Error: $e");
          debugPrint("Stack trace: $stackTrace");
        }
        break;
    }
  }

  ///加载调用，失败时通过loadFail通知
  void load() async {
    try {
      await AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.drawLoad, _instanceOnlyArgs());
    } on PlatformException catch (e) {
      _notifyLoadFailure(e);
    }
  }

  ///获取信息
  Future<dynamic> getMediaExtraInfo() async {
    try {
      final mediaExtraInfo = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.drawGetMediaExtraInfo,
        _instanceOnlyArgs(),
      );
      return mediaExtraInfo;
    } on PlatformException catch (e) {
      throw Exception('调用getCustomExtraData失败: ${e.message}');
    }
  }

  ///获取是否有预加载，异常时返回false
  Future<bool> isReadyAd(String adId) async {
    try {
      return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.drawIsReadyAd,
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
        AMPSAdSdkMethodNames.drawGetEcpm,
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
        AMPSAdSdkMethodNames.drawGetSeatId,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      return null;
    }
  }

  ///页面销毁时调用
  void destroy() async {
    DrawCallbackRouter.instance.unregister(instanceId);
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.drawDestroyAd,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      // 销毁失败不影响业务流程，但不能抛出未捕获异常
    }
  }

  ///失去焦点时调用
  void pauseAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.drawPauseAd,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  ///再次获取焦点时候调用
  void resumeAd() async {
    try {
      await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.drawResumeAd,
        _instanceOnlyArgs(),
      );
    } on PlatformException {
      // 异常不能向上抛出，避免未捕获异常
    }
  }

  void setAdCloseCallBack(String adId, VoidCallback? closeWidgetCall) {
    if (closeWidgetCall != null) {
      mCloseWidgetCallMap[adId] = closeWidgetCall;
    }
  }

  void setVideoPlayerListener(String adId, AMPSDrawVideoListener? listener) {
    if (listener != null) {
      mVideoPlayerCallBackMap[adId] = listener;
    }
  }

  void setSizeUpdate(String adId, AdWidgetSizeCall? func) {
    if (func != null) {
      updateSizeMap[adId] = func;
    }
  }
}
