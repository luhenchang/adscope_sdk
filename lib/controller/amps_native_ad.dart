import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../adscope_sdk.dart';
import '../amps_sdk_export.dart';
import '../common.dart';

///原生广告类
class AMPSNativeAd {
  NativeType nativeType = NativeType.native;

  ///默认原生模式【鸿蒙中原生和自渲染是一样的调用入口；Android是两个不同的入口，所以这里需要说明文档说明】
  AdOptions config;
  AMPSNativeAdListener? mCallBack;
  AMPSNativeRenderListener? mRenderCallBack;
  AmpsNativeInteractiveListener? mInteractiveCallBack;
  AmpsVideoPlayListener? mVideoPlayerCallBack;
  AdWidgetNeedCloseCall? mCloseWidgetCall;
  AMPSUnifiedDownloadListener? mDownloadListener;
  AMPSNegativeFeedbackListener? mNegativeFeedbackListener;
  AdWidgetSizeCall? updateSize;

  AMPSNativeAd(
      {required this.config,
      this.nativeType = NativeType.native,
      this.mCallBack,
      this.mRenderCallBack,
      this.mInteractiveCallBack,
      this.mVideoPlayerCallBack,
      this.mNegativeFeedbackListener}) {
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
            mInteractiveCallBack?.onAdShow?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdExposure:
            mInteractiveCallBack?.onAdExposure?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdClicked:
            mInteractiveCallBack?.onAdClicked?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onAdClosed:
            mCloseWidgetCall?.call();
            mInteractiveCallBack?.toCloseAd?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onComplainSuccess:
            mNegativeFeedbackListener?.onComplainSuccess.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoInit:
            mVideoPlayerCallBack?.onVideoInit?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoLoading:
            mVideoPlayerCallBack?.onVideoLoading?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoReady:
            mVideoPlayerCallBack?.onVideoReady?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoLoaded:
            mVideoPlayerCallBack?.onVideoLoaded?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayStart:
            mVideoPlayerCallBack?.onVideoPlayStart?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayComplete:
            mVideoPlayerCallBack?.onVideoPlayComplete?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPause:
            mVideoPlayerCallBack?.onVideoPause?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoResume:
            mVideoPlayerCallBack?.onVideoResume?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoStop:
            mVideoPlayerCallBack?.onVideoStop?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoClicked:
            mVideoPlayerCallBack?.onVideoClicked?.call(call.arguments);
            break;
          case AMPSNativeCallBackChannelMethod.onVideoPlayError:
            var map = call.arguments as Map<dynamic, dynamic>;
            mVideoPlayerCallBack?.onVideoPlayError?.call(
                map[AMPSSdkCallBackErrorKey.adId],
                map[AMPSSdkCallBackErrorKey.code],
                map[AMPSSdkCallBackErrorKey.extra]);
            break;
          case DownLoadCallBackChannelMethod.onInstalled:
            var adId = call.arguments as String;
            mDownloadListener?.onInstalled?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadFailed:
            var adId = call.arguments as String;
            mDownloadListener?.onDownloadFailed?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadStarted:
            var adId = call.arguments as String;
            mDownloadListener?.onDownloadStarted?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadFinished:
            var adId = call.arguments as String;
            mDownloadListener?.onDownloadFinished?.call(adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadProgressUpdate:
            var argMap = call.arguments as Map<dynamic, dynamic>;
            var position = argMap["position"] ?? 0;
            var adId = argMap["adId"] ?? "";
            mDownloadListener?.onDownloadProgressUpdate?.call(position, adId);
            break;
          case DownLoadCallBackChannelMethod.onDownloadPaused:
            var argMap = call.arguments as Map<dynamic, dynamic>;
            var position = argMap["position"] ?? 0;
            var adId = argMap["adId"] ?? "";
            mDownloadListener?.onDownloadPaused?.call(position, adId);
            break;
          case AMPSNativeCallBackChannelMethod.nativeSizeUpdate:
            try {
              // 检查 arguments 是否为 Map
              if (call.arguments is Map) {
                var argMap = call.arguments as Map;
                final param = Map<String, dynamic>.from(argMap);

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
                updateSize?.call(width, height);
              } else {
                // debugPrint("nativeSizeUpdate-Invalid arguments type: ${call.arguments.runtimeType}");
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

  ///获取是否有预加载
  Future<bool> isReadyAd(String adId) async {
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativeIsReadyAd, nativeType);
  }

  ///获取ecpm
  Future<AMPSUnifiedPattern> getUnifiedPattern(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    final pattern = await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativePattern, args);
    return  AMPSUnifiedPattern.fromValue(pattern);
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

  ///获取视频播放时长
  Future<num> getVideoDuration(String adId) async {
    final Map<String, dynamic> args = {adNativeType: nativeType.value, adAdId: adId};
    return await AdscopeSdk.channel
        .invokeMethod(AMPSAdSdkMethodNames.nativeGetVideoDuration, args);
  }

  ///设置视频播放配置
  void setVideoPlayConfig(AMPSAdVideoPlayConfig videoPlayConfig) {
    AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.nativeSetVideoPlayConfig,
        videoPlayConfig.toJson());
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

  void setAdCloseCallBack(AdWidgetNeedCloseCall? closeWidgetCall) {
    mCloseWidgetCall = closeWidgetCall;
  }

  void setDownloadListener(AMPSUnifiedDownloadListener? downloadListener) {
    mDownloadListener = downloadListener;
  }

  void setSizeUpdate(AdWidgetSizeCall func) {
    updateSize = func;
  }
}
