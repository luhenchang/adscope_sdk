import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk/data/amps_ad.dart';
import 'package:flutter/services.dart';

class BannerCallbackRouter {
  BannerCallbackRouter._();

  static final BannerCallbackRouter instance = BannerCallbackRouter._();
  static const String _handlerKey = "banner_callback_router";

  final Map<String, _BannerEntry> _entries = {};
  bool _installed = false;

  void register(String instanceId, BannerCallBack? callback, VoidCallback? closeCallback) {
    _entries[instanceId] = _BannerEntry(callback, closeCallback);
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
      case AMPSBannerCallBackChannelMethod.onLoadSuccess:
        cb?.onLoadSuccess?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onLoadFailure:
        entry.closeCallback?.call();
        cb?.onLoadFailure?.call(mapArgs[AMPSSdkCallBackErrorKey.code], mapArgs[AMPSSdkCallBackErrorKey.message]);
        break;
      case AMPSBannerCallBackChannelMethod.onAdShow:
        cb?.onAdShow?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onAdClicked:
        cb?.onAdClicked?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onAdClosed:
        entry.closeCallback?.call();
        cb?.onAdClosed?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onVideoPlayStart:
        cb?.onVideoPlayStart?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onVideoPlayEnd:
        cb?.onVideoPlayEnd?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onVideoPlayError:
        cb?.onVideoPlayError?.call(mapArgs[AMPSSdkCallBackErrorKey.code], mapArgs[AMPSSdkCallBackErrorKey.message]);
        break;
      case AMPSBannerCallBackChannelMethod.onVideoReady:
        cb?.onVideoReady?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onVideoPause:
        cb?.onVideoPause?.call();
        break;
      case AMPSBannerCallBackChannelMethod.onVideoResume:
        cb?.onVideoResume?.call();
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

class _BannerEntry {
  final BannerCallBack? callback;
  final VoidCallback? closeCallback;

  _BannerEntry(this.callback, this.closeCallback);
}
