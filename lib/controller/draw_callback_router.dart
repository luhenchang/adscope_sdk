import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/common.dart';
import 'package:flutter/services.dart';

/// Draw 广告回调路由：单例 MethodChannel handler，按 [AMPSAdInstanceKey.adInstanceId] 分发到各 [AMPSDrawAd]。
class DrawCallbackRouter {
  DrawCallbackRouter._();

  static final DrawCallbackRouter instance = DrawCallbackRouter._();

  static const String _handlerKey = "draw_callback_router";

  final Map<String, Future<void> Function(MethodCall)> _handlers = {};
  bool _installed = false;

  void register(String instanceId, Future<void> Function(MethodCall) handler) {
    _handlers[instanceId] = handler;
    _ensureInstalled();
  }

  void unregister(String instanceId) {
    _handlers.remove(instanceId);
  }

  void _ensureInstalled() {
    if (_installed) return;
    _installed = true;
    AdscopeSdk.addMethodCallHandler(_handlerKey, _dispatch);
  }

  Future<void> _dispatch(MethodCall call) async {
    final instanceId = _resolveInstanceId(call.arguments);
    if (instanceId == null) return;
    final handler = _handlers[instanceId];
    if (handler == null) return;
    return handler(call);
  }

  String? _resolveInstanceId(dynamic args) {
    if (args is Map) {
      final id = args[AMPSAdInstanceKey.adInstanceId];
      if (id is String && id.isNotEmpty) return id;
    }
    if (_handlers.length == 1) {
      return _handlers.keys.first;
    }
    return null;
  }
}
