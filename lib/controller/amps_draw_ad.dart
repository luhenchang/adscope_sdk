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
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawCreate,
      _wrapArgs(config.toMap()),
    );
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
          mapArgs[AMPSSdkCallBackErrorKey.code],
          mapArgs[AMPSSdkCallBackErrorKey.message],
        );
        break;
      case AmpsDrawCallbackChannelMethod.onRenderSuccess:
        mRenderCallBack?.renderSuccess?.call(mapArgs[AMPSSdkCallBackErrorKey.adId]);
        break;
      case AmpsDrawCallbackChannelMethod.onRenderFail:
        mRenderCallBack?.renderFailed?.call(
          mapArgs[AMPSSdkCallBackErrorKey.adId],
          mapArgs[AMPSSdkCallBackErrorKey.code],
          mapArgs[AMPSSdkCallBackErrorKey.message],
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
            adId,
            mapArgs[AMPSSdkCallBackErrorKey.current],
            mapArgs[AMPSSdkCallBackErrorKey.duration],
          );
        }
        break;
      case AmpsDrawCallbackChannelMethod.onVideoError:
        {
          final adId = mapArgs[AMPSSdkCallBackErrorKey.adId];
          mVideoPlayerCallBackMap[adId]?.onVideoError?.call(
            adId,
            mapArgs[AMPSSdkCallBackErrorKey.code],
            mapArgs[AMPSSdkCallBackErrorKey.message],
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

  void load() async {
    AdscopeSdk.invokeMethod(AMPSAdSdkMethodNames.drawLoad, _instanceOnlyArgs());
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

  ///获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawIsReadyAd,
      _argsWithAdId(adId),
    );
  }

  ///获取ecpm
  Future<num> getECPM(String adId) async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawGetEcpm,
      _argsWithAdId(adId),
    );
  }

  ///获取胜出渠道的seatId
  Future<String?> getSeatId() async {
    return await AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawGetSeatId,
      _instanceOnlyArgs(),
    );
  }

  ///页面销毁时调用
  void destroy() {
    DrawCallbackRouter.instance.unregister(instanceId);
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawDestroyAd,
      _instanceOnlyArgs(),
    );
  }

  ///失去焦点时调用
  void pauseAd() {
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawPauseAd,
      _instanceOnlyArgs(),
    );
  }

  ///再次获取焦点时候调用
  void resumeAd() {
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.drawResumeAd,
      _instanceOnlyArgs(),
    );
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
