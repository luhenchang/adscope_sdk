import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk/data/amps_ad.dart';
import 'package:flutter/services.dart';

class RewardVideoCallbackRouter {
  RewardVideoCallbackRouter._();

  static final RewardVideoCallbackRouter instance = RewardVideoCallbackRouter._();
  static const String _handlerKey = "reward_video_callback_router";

  final Map<String, RewardVideoCallBack?> _entries = {};
  bool _installed = false;

  void register(String instanceId, RewardVideoCallBack? callback) {
    _entries[instanceId] = callback;
    if (_installed) return;
    _installed = true;
    AdscopeSdk.addMethodCallHandler(_handlerKey, _dispatch);
  }

  void unregister(String instanceId) {
    _entries.remove(instanceId);
  }

  Future<void> _dispatch(MethodCall call) async {
    final args = call.arguments;
    final instanceId = _resolveInstanceId(args);
    if (instanceId == null) return;
    final cb = _entries[instanceId];
    if (cb == null) return;
    final mapArgs = args is Map ? args : const <dynamic, dynamic>{};

    switch (call.method) {
      case AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess:
        cb.onLoadSuccess?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onLoadFailure:
        cb.onLoadFailure?.call(_errorCode(mapArgs), _errorMessage(mapArgs));
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onAdShow:
        cb.onAdShow?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onAdClicked:
        cb.onAdClicked?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onAdClosed:
        cb.onAdClosed?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onVideoPlayStart:
        cb.onVideoPlayStart?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd:
        cb.onVideoPlayEnd?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onVideoPlayError:
        cb.onVideoPlayError?.call(_errorCode(mapArgs), _errorMessage(mapArgs));
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onVideoSkipToEnd:
        cb.onVideoSkipToEnd?.call(mapArgs[AMPSSdkCallBackParamsKey.playDurationMs]);
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onAdReward:
        cb.onAdReward?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onAdCached:
        cb.onAdCached?.call();
        break;
      case AMPSRewardedVideoCallBackChannelMethod.onServerRewardDidFail:
        cb.onServerRewardFailed?.call(_errorCode(mapArgs), _errorMessage(mapArgs));
        break;
    }
  }

  ///原生端传来的code可能为null或非int类型，做安全转换避免回调抛类型异常被吞掉
  int _errorCode(Map<dynamic, dynamic> args) {
    final code = args[AMPSSdkCallBackErrorKey.code];
    if (code is int) return code;
    if (code is num) return code.toInt();
    if (code is String) return int.tryParse(code) ?? -1;
    return -1;
  }

  ///原生端传来的message可能为null，做安全转换避免回调抛类型异常被吞掉
  String _errorMessage(Map<dynamic, dynamic> args) {
    final message = args[AMPSSdkCallBackErrorKey.message];
    return message?.toString() ?? 'unknown error';
  }

  String? _resolveInstanceId(dynamic args) {
    if (args is Map) {
      final id = args[AMPSAdInstanceKey.adInstanceId];
      if (id is String && id.isNotEmpty) return id;
    }
    if (_entries.length == 1) {
      return _entries.keys.first;
    }
    return null;
  }
}
