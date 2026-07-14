import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk/data/amps_ad.dart';
import 'package:flutter/services.dart';

typedef SplashMethodCallHandler = Future<void> Function(MethodCall call);

/// 开屏广告回调路由：单例 MethodChannel handler，按 [splashInstanceId] 分发到各 [AMPSSplashAd]。
class SplashCallbackRouter {
  SplashCallbackRouter._();

  static final SplashCallbackRouter instance = SplashCallbackRouter._();

  static const String _routerHandlerKey = "splash_callback_router";

  final Map<String, _SplashCallbackEntry> _entries = {};
  bool _channelHandlerInstalled = false;

  void register(String instanceId, AdCallBack? callback, void Function()? closeCallback) {
    _entries[instanceId] = _SplashCallbackEntry(callback, closeCallback);
    _ensureChannelHandler();
  }

  void unregister(String instanceId) {
    _entries.remove(instanceId);
  }

  void _ensureChannelHandler() {
    if (_channelHandlerInstalled) {
      return;
    }
    _channelHandlerInstalled = true;
    AdscopeSdk.addMethodCallHandler(_routerHandlerKey, _dispatch);
  }

  Future<void> _dispatch(MethodCall call) async {
    final instanceId = _extractInstanceId(call.arguments);
    if (instanceId == null) {
      return;
    }
    final entry = _entries[instanceId];
    if (entry == null) {
      return;
    }
    final adCallBack = entry.callback;
    switch (call.method) {
      case AMPSSplashAdCallBackChannelMethod.onLoadSuccess:
        adCallBack?.onLoadSuccess?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onLoadFailure:
        entry.closeCallback?.call();
        adCallBack?.onLoadFailure?.call(_errorCode(call.arguments), _errorMessage(call.arguments));
        break;
      case AMPSSplashAdCallBackChannelMethod.onRenderOk:
        adCallBack?.onRenderOk?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onAdShow:
        adCallBack?.onAdShow?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onAdExposure:
        adCallBack?.onAdExposure?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onAdClicked:
        entry.closeCallback?.call();
        adCallBack?.onAdClicked?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onAdClosed:
        entry.closeCallback?.call();
        adCallBack?.onAdClosed?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onRenderFailure:
        adCallBack?.onRenderFailure?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onAdShowError:
        entry.closeCallback?.call();
        adCallBack?.onAdShowError?.call(_errorCode(call.arguments), _errorMessage(call.arguments));
        break;
      case AMPSSplashAdCallBackChannelMethod.onVideoPlayStart:
        adCallBack?.onVideoPlayStart?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onVideoPlayEnd:
        adCallBack?.onVideoPlayEnd?.call();
        break;
      case AMPSSplashAdCallBackChannelMethod.onVideoPlayError:
        adCallBack?.onVideoPlayError?.call(_errorCode(call.arguments), _errorMessage(call.arguments));
        break;
      case AMPSSplashAdCallBackChannelMethod.onVideoSkipToEnd:
        final skipMap = call.arguments as Map<dynamic, dynamic>?;
        adCallBack?.onVideoSkipToEnd?.call(
          skipMap?[AMPSSdkCallBackParamsKey.playDurationMs],
        );
        break;
      case AMPSSplashAdCallBackChannelMethod.onAdReward:
        adCallBack?.onAdReward?.call();
        break;
    }
  }

  ///原生端传来的code可能为null或非int类型，做安全转换避免回调抛类型异常被吞掉
  int _errorCode(dynamic args) {
    final code = args is Map ? args[AMPSSdkCallBackErrorKey.code] : null;
    if (code is int) return code;
    if (code is num) return code.toInt();
    if (code is String) return int.tryParse(code) ?? -1;
    return -1;
  }

  ///原生端传来的message可能为null，做安全转换避免回调抛类型异常被吞掉
  String _errorMessage(dynamic args) {
    final message = args is Map ? args[AMPSSdkCallBackErrorKey.message] : null;
    return message?.toString() ?? 'unknown error';
  }

  String? _extractInstanceId(dynamic arguments) {
    if (arguments is Map) {
      final id = arguments[AMPSSplashInstanceKey.splashInstanceId];
      if (id is String && id.isNotEmpty) {
        return id;
      }
    }
    return null;
  }
}

class _SplashCallbackEntry {
  final AdCallBack? callback;
  final void Function()? closeCallback;

  _SplashCallbackEntry(this.callback, this.closeCallback);
}
