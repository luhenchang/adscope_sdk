import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_native_interactive_listener.dart';
import '../data/amps_ad.dart';
import '../data/unified_ad_download_app_info.dart';
import '../data/unified_pattern.dart';

///原生广告类
class AMPSNativeAd {
  NativeType nativeType = NativeType.native;

  ///默认原生模式【鸿蒙中原生和自渲染是一样的调用入口；Android是两个不同的入口，所以这里需要说明文档说明】
  AdOptions config;
  AMPSNativeAdListener? mCallBack;
  AMPSNativeRenderListener? mRenderCallBack;
  AdWidgetSizeCall? updateSize;

  Map<String,AdWidgetSizeCall> updateSizeMap = {};
  Map<String,AmpsNativeInteractiveListener> mInteractiveCallBackMap = {};
  Map<String, AmpsVideoPlayListener> mVideoPlayerCallBackMap = {};
  Map<String, AdWidgetNeedCloseCall> mCloseWidgetCallMap = {};
  Map<String, AMPSUnifiedDownloadListener> mDownloadListenerMap = {};
  Map<String, AMPSNegativeFeedbackListener> mNegativeFeedbackListenerMap = {};

  AMPSNativeAd(
      {required this.config,
      this.nativeType = NativeType.native,
      this.mCallBack,
      this.mRenderCallBack}) {

    AdscopeSdk.channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case AMPSNativeCallBackChannelMethod.loadOk:
            final List<String>? receivedList = call.arguments?.cast<String>();
            if (receivedList != null) {
              mCallBack?.loadOk?.call(receivedList);
            }
            break;
          case AMPSNativeCallBackChannelMethod.loadFail:
            var map = call.arguments as Map<dynamic, dynamic>;
            mCallBack?.loadFail?.call(map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSNativeCallBackChannelMethod.renderSuccess:
            mRenderCallBack?.renderSuccess?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.renderFailed:
            var map = call.arguments as Map<dynamic, dynamic>;
            mRenderCallBack?.renderFailed?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.message]);
            break;
          case AMPSNativeCallBackChannelMethod.onAdShow:
            mInteractiveCallBackMap[call.arguments]?.onAdShow?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdExposure:
            mInteractiveCallBackMap[call.arguments]?.onAdExposure?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdClicked:
            mInteractiveCallBackMap[call.arguments]?.onAdClicked?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdClosed:
            mCloseWidgetCallMap[call.arguments]?.call();
            mInteractiveCallBackMap[call.arguments]?.toCloseAd?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onComplainSuccess:
            mNegativeFeedbackListenerMap[call.arguments]?.onComplainSuccess.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoInit:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoInit?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoLoading:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoLoading?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoReady:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoReady?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoLoaded:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoLoaded?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayStart:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoPlayStart?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayComplete:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoPlayComplete?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPause:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoPause?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoResume:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoResume?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoStop:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoStop?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoClicked:
            mVideoPlayerCallBackMap[call.arguments]?.onVideoClicked?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mVideoPlayerCallBackMap[call.arguments]?.onVideoPlayError?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.extra]);
            break;
          case DownLoadCallBackChannelMethod.onInstalled:
            var adId = call.arguments as String;
            mDownloadListenerMap[call.arguments]?.onInstalled?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadFailed:
            var adId = call.arguments as String;
            mDownloadListenerMap[call.arguments]?.onDownloadFailed?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadStarted:
            var adId = call.arguments as String;
            mDownloadListenerMap[call.arguments]?.onDownloadStarted?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadFinished:
            var adId = call.arguments as String;
            mDownloadListenerMap[call.arguments]?.onDownloadFinished?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadProgressUpdate:
            var argMap = call.arguments as Map<dynamic, dynamic>;
            var position = argMap["position"] ?? 0;
            var adId = argMap["adId"] ?? "";
            mDownloadListenerMap[call.arguments]?.onDownloadProgressUpdate?.call(position, adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadPaused:
            var argMap = call.arguments as Map<dynamic, dynamic>;
            var position = argMap["position"] ?? 0;
            var adId = argMap["adId"] ?? "";
            mDownloadListenerMap[call.arguments]?.onDownloadPaused?.call(position, adId);
            break;
          case AMPSNativeCallBackChannelMethod.nativeSizeUpdate:
            try {

              // 检查 arguments 是否为 Map
              if (call.arguments is Map) {
                var argMap = call.arguments as Map;
                final param = Map<String, dynamic>.from(argMap);
                debugPrint("nativeSizeUpdate:${param["height"]}");
                // 安全地获取并转换为 double
                double width = 00;
                double height = 00;
                debugPrint("nativeSizeUpdate-Error: 1");
                if (param.containsKey("width")) {
                  width = param["width"] is num
                      ? (param["width"] as num).toDouble()
                      : 00;
                }
                debugPrint("nativeSizeUpdate-Error: 2");
                if (param.containsKey("height")) {
                  height = param["height"] is num
                      ? (param["height"] as num).toDouble()
                      : 00;
                }
                // 验证参数合理性
                debugPrint("nativeSizeUpdate-Error: 3");
                width = width >= 0 ? width : 00;
                height = height >= 0 ? height : 00;
                // 安全调用回调
                debugPrint("nativeSizeUpdate-Error: 4-$updateSize");
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
      AMPSAdSdkMethodNames.nativeCreate,
      config.toMap(nativeType: nativeType),
    );
  }

  void load() async {
    AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.nativeLoad,
      nativeType.value,
    );
  }

  //自渲染类型
  Future<AMPSUnifiedPattern> getUnifiedPattern(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    final pattern = await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativePattern, args);
    return  AMPSUnifiedPattern.fromValue(pattern);
  }
  //下载相关信息
  Future<UnifiedAdDownloadAppInfo?> getDownLoadInfo(String adId) async {
    try {
      final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
      final dynamic appInfo = await AdscopeSdk.channel
          .invokeMethod(AMPSAdSdkMethodNames.nativeUnifiedGetDownLoad, args);
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
  Future<Map<String, dynamic>?> getMediaExtraInfo() async {
    try {
      final dynamic param = await AdscopeSdk.channel.invokeMethod(
          AMPSAdSdkMethodNames.nativeGetMediaExtraInfo, nativeType.value);
      if (param == null) {
        return null;
      }
      return Map<String, dynamic>.from(param);
    } on PlatformException catch (e) {
      throw Exception('调用getCustomExtraData失败: ${e.message}');
    }
  }

  ///获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativeIsReadyAd, args);
  }

  ///获取ecpm
  Future<num> getECPM(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativeGetECPM, args);
  }

  ///获取是否是自渲染
  Future<bool> isNativeExpress(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativeIsNativeExpress, args);
  }

  ///获取视频播放时长
  Future<num> getVideoDuration(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativeGetVideoDuration, args);
  }


  void setAdCloseCallBack(String adId, AdWidgetNeedCloseCall? closeWidgetCall) {
    if (closeWidgetCall != null){
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



  void setSizeUpdate(String adId ,AdWidgetSizeCall? func) {
    if (func != null){
      updateSizeMap[adId] = func;
    }
  }
}
