
import 'dart:ui';
import '../common.dart';

///广告加载入参参数
class AdOptions {
  final String spaceId;
  final String? apiKey;
  final int? adCount;
  final String? s2sImpl;
  final int? timeoutInterval;
  final List<num?>? expressSize;
  final int? splashAdBottomBuilderHeight;
  final String? userId;
  final String? extra;
  final Map<String,dynamic>? customExtraMap;
  final String? ipAddress;

  AdOptions({
    required this.spaceId,
    this.apiKey,
    this.adCount,
    this.s2sImpl,
    this.timeoutInterval,
    this.expressSize,
    this.splashAdBottomBuilderHeight,
    this.userId,
    this.extra,
    this.customExtraMap,
    this.ipAddress
  });

  Map<dynamic, dynamic> toMap({NativeType? nativeType}) {
    return {
      'nativeType': nativeType?.value??0,
      'spaceId': spaceId,
      'apiKey': apiKey,
      'adCount': adCount,
      's2sImpl': s2sImpl,
      'timeoutInterval': timeoutInterval,
      'expressSize': expressSize,
      'splashAdBottomBuilderHeight': splashAdBottomBuilderHeight,
      'userId': userId,
      'extra': extra,
      'customExtraParameters': customExtraMap,
      'ipAddress': ipAddress
    };
  }
}


typedef AdFailureCallback = void Function(int code, String message);
typedef VideoPlayErrorCallback = void Function(int code, String message);
typedef VideoSkipToEndCallback = void Function(int? playDurationMs);
///广告回调相关接口
class AdCallBack {
  final VoidCallback? onLoadSuccess;
  final AdFailureCallback? onLoadFailure;
  final VoidCallback? onRenderOk;
  final VoidCallback? onRenderFailure;
  final AdFailureCallback? onAdShowError;
  final VoidCallback? onAdShow;
  final VoidCallback? onAdExposure;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;
  final VoidCallback? onVideoPlayStart;
  final VoidCallback? onVideoPlayEnd;
  final VideoPlayErrorCallback? onVideoPlayError;
  final VideoSkipToEndCallback? onVideoSkipToEnd;
  final VoidCallback? onAdReward;

  const AdCallBack({
    this.onLoadSuccess,
    this.onLoadFailure,
    this.onRenderOk,
    this.onRenderFailure,
    this.onAdShowError,
    this.onAdShow,
    this.onAdExposure,
    this.onAdClicked,
    this.onAdClosed,
    this.onVideoPlayStart,
    this.onVideoPlayEnd,
    this.onVideoPlayError,
    this.onVideoSkipToEnd,
    this.onAdReward,
  });
}

class RewardVideoCallBack {
  final VoidCallback? onLoadSuccess;
  final VoidCallback? onAdCached;
  final AdFailureCallback? onLoadFailure;
  final AdFailureCallback? onVideoPlayError;
  final VoidCallback? onAdShow;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;
  final VoidCallback? onVideoPlayStart;
  final VoidCallback? onVideoPlayEnd;
  final VideoSkipToEndCallback? onVideoSkipToEnd;
  final VoidCallback? onAdReward;

  const RewardVideoCallBack({
    this.onLoadSuccess,
    this.onAdCached,
    this.onLoadFailure,
    this.onAdShow,
    this.onAdClicked,
    this.onAdClosed,
    this.onVideoPlayStart,
    this.onVideoPlayEnd,
    this.onVideoPlayError,
    this.onVideoSkipToEnd,
    this.onAdReward
  });
}

class BannerCallBack {
  final VoidCallback? onLoadSuccess;
  final AdFailureCallback? onLoadFailure;
  final VoidCallback? onAdShow;
  final VoidCallback? onAdClicked;
  final VoidCallback? onAdClosed;
  final VoidCallback? onVideoPause;
  final VoidCallback? onVideoReady;
  final VoidCallback? onVideoResume;
  final VoidCallback? onVideoPlayStart;
  final VoidCallback? onVideoPlayEnd;
  final AdFailureCallback? onVideoPlayError;


  const BannerCallBack(
      {this.onLoadSuccess,
      this.onLoadFailure,
      this.onAdShow,
      this.onAdClicked,
      this.onAdClosed,
      this.onVideoReady,
      this.onVideoPlayStart,
      this.onVideoPlayEnd,
      this.onVideoPause,
      this.onVideoPlayError,
      this.onVideoResume});
}


typedef AdWidgetSizeCall = void Function(double width,double height);