import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_native_interactive_listener.dart';
import '../data/amps_ad.dart';

///原生广告类
class AMPSDrawAd {
  ///默认原生模式【鸿蒙中原生和自渲染是一样的调用入口；Android是两个不同的入口，所以这里需要说明文档说明】
  AdOptions config;
  AMPSDrawAdListener? mCallBack;
  AMPSDrawRenderListener? mRenderCallBack;
  AdWidgetSizeCall? updateSize;
  Map<String, AdWidgetSizeCall> updateSizeMap = {};
  Map<String, AMPSDrawVideoListener> mVideoPlayerCallBackMap = {};
  Map<String, AdWidgetNeedCloseCall> mCloseWidgetCallMap = {};

  AMPSDrawAd(
      {required this.config,
      this.mCallBack,this.mRenderCallBack}) {
    AdscopeSdk.channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case AmpsDrawCallbackChannelMethod.onLoadSuccess:
            final List<String>? receivedList = call.arguments?.cast<String>();
            if (receivedList != null) {
              mCallBack?.loadOk?.call(receivedList);
            }
            break;
          case AmpsDrawCallbackChannelMethod.onLoadFailure:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.loadFail?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AmpsDrawCallbackChannelMethod.onRenderSuccess:
            mRenderCallBack?.renderSuccess
                ?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onRenderFail:
            var map = call.arguments as Map<dynamic, dynamic>;
            mRenderCallBack?.renderFailed?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AmpsDrawCallbackChannelMethod.onAdShow:
            mRenderCallBack?.onAdShow?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onAdClicked:
            mRenderCallBack?.onAdClick?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onAdClosed:
            mCloseWidgetCallMap[call.arguments]?.call();
            mRenderCallBack?.onAdClose?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onVideoLoad:
            mVideoPlayerCallBackMap[call.arguments]
                ?.onVideoLoad
                ?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onVideoPlayStart:
            mVideoPlayerCallBackMap[call.arguments]
                ?.onVideoAdStartPlay
                ?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onVideoPlayPause:
            mVideoPlayerCallBackMap[call.arguments]
                ?.onVideoAdPaused
                ?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onVideoAdContinuePlay:
            mVideoPlayerCallBackMap[call.arguments]
                ?.onVideoAdContinuePlay
                ?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.onProgressUpdate:
            var map = call.arguments as Map<dynamic, dynamic>;
            mVideoPlayerCallBackMap[call.arguments]?.onProgressUpdate?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.current],
                map[AMPSSdkCallBackErrorKey.duration]);
            break;
          case AmpsDrawCallbackChannelMethod.onVideoError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mVideoPlayerCallBackMap[call.arguments]?.onVideoError?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AmpsDrawCallbackChannelMethod.onVideoAdComplete:
            mVideoPlayerCallBackMap[call.arguments]
                ?.onVideoAdComplete
                ?.call(call.arguments);
            break;
          case AmpsDrawCallbackChannelMethod.drawSizeUpdate:
            try {
              // 检查 arguments 是否为 Map
              if (call.arguments is Map) {
                var argMap = call.arguments as Map;
                final param = Map<String, dynamic>.from(argMap);
                // debugPrint("nativeSizeUpdate:${param["height"]}");
                // 安全地获取并转换为 double
                double width = 00;
                double height = 00;
                if (param.containsKey("width")) {
                  width = param["width"] is num
                      ? (param["width"] as num).toDouble()
                      : 00;
                }
                if (param.containsKey("height")) {
                  height = param["height"] is num
                      ? (param["height"] as num).toDouble()
                      : 00;
                }
                // 验证参数合理性
                width = width >= 0 ? width : 00;
                height = height >= 0 ? height : 00;
                // 安全调用回调
                if (param.containsKey("adId")) {
                  final adId = param["adId"];
                  updateSizeMap[adId]?.call(width, height);
                }

              } else {
                debugPrint("nativeSizeUpdate-Invalid arguments type: ${call.arguments.runtimeType}");
              }
            } catch (e, stackTrace) {
              debugPrint("nativeSizeUpdate-Error: $e");
              debugPrint("Stack trace: $stackTrace");
            }
            break;
        }
      },
    );
    AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.drawCreate,
      config.toMap(),
    );
  }

  void load() async {
    AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.drawLoad);
  }

  ///获取信息
  Future<dynamic> getMediaExtraInfo() async {
    try {
      final mediaExtraInfo = await AdscopeSdk.channel.invokeMethod(
          AMPSAdSdkMethodNames.drawGetMediaExtraInfo);
      return mediaExtraInfo;
    } on PlatformException catch (e) {
      throw Exception('调用getCustomExtraData失败: ${e.message}');
    }
  }

  ///获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.drawIsReadyAd, adId);
  }

  ///获取ecpm
  Future<num> getECPM(String adId) async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.drawGetEcpm, adId);
  }


  void setAdCloseCallBack(String adId, AdWidgetNeedCloseCall? closeWidgetCall) {
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

  void destroy() {

  }
}
