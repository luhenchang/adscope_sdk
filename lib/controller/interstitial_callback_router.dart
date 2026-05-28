import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk/data/amps_ad.dart';
import 'package:flutter/services.dart';

class InterstitialCallbackRouter {
  InterstitialCallbackRouter._();

  static final InterstitialCallbackRouter instance = InterstitialCallbackRouter._();
  static const String _handlerKey = "interstitial_callback_router";

  final Map<String, _Entry> _entries = {};
  bool _installed = false;

  void register(String instanceId, AdCallBack? callback, VoidCallback? closeCallback) {
    _entries[instanceId] = _Entry(callback, closeCallback);
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
    final entry = _entries[instanceId];
    if (entry == null) return;
    final cb = entry.callback;
    final mapArgs = args is Map ? args : const <dynamic, dynamic>{};
    switch (call.method) {
      case AMPSInterstitialAdCallBackChannelMethod.onLoadSuccess:
        cb?.onLoadSuccess?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onLoadFailure:
        cb?.onLoadFailure?.call(mapArgs[AMPSSdkCallBackErrorKey.code], mapArgs[AMPSSdkCallBackErrorKey.message]);
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onRenderOk:
        cb?.onRenderOk?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onAdShow:
        cb?.onAdShow?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onAdExposure:
        cb?.onAdExposure?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onAdClicked:
        entry.closeCallback?.call();
        cb?.onAdClicked?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onAdClosed:
        entry.closeCallback?.call();
        cb?.onAdClosed?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onRenderFailure:
        cb?.onRenderFailure?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onAdShowError:
        cb?.onAdShowError?.call(mapArgs[AMPSSdkCallBackErrorKey.code], mapArgs[AMPSSdkCallBackErrorKey.message]);
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onVideoPlayStart:
        cb?.onVideoPlayStart?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onVideoPlayEnd:
        cb?.onVideoPlayEnd?.call();
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onVideoPlayError:
        cb?.onVideoPlayError?.call(mapArgs[AMPSSdkCallBackErrorKey.code], mapArgs[AMPSSdkCallBackErrorKey.message]);
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onVideoSkipToEnd:
        cb?.onVideoSkipToEnd?.call(mapArgs[AMPSSdkCallBackParamsKey.playDurationMs]);
        break;
      case AMPSInterstitialAdCallBackChannelMethod.onAdReward:
        cb?.onAdReward?.call();
        break;
    }
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

class _Entry {
  final AdCallBack? callback;
  final VoidCallback? closeCallback;

  _Entry(this.callback, this.closeCallback);
}
