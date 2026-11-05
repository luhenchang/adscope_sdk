import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'common.dart';
import 'controller/amps_mall_ad.dart';

/// 挂载已加载的 Android / iOS 商城视图；父布局必须提供有限宽高。
/// 同一个 adId 同时只挂载一个组件。路由遮挡/Tab切换时由业务设置 visible=false。
class AMPSMallView extends StatefulWidget {
  final AMPSMallAd ad;
  final String adId;
  final bool visible;
  const AMPSMallView(
      {super.key, required this.ad, required this.adId, this.visible = true});

  @override
  State<AMPSMallView> createState() => _AMPSMallViewState();
}

class _AMPSMallViewState extends State<AMPSMallView>
    with WidgetsBindingObserver {
  bool _foreground = true;
  bool _created = false;
  void _visibility(bool visible, {AMPSMallAd? ad, String? adId}) {
    unawaited((ad ?? widget.ad)
        .setVisible(adId ?? widget.adId, visible)
        .catchError((Object error) {
      debugPrint('AMPSMallView visibility: $error');
    }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didUpdateWidget(covariant AMPSMallView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ad != widget.ad || oldWidget.adId != widget.adId) {
      _visibility(false, ad: oldWidget.ad, adId: oldWidget.adId);
      _created = false;
    } else if (_created) {
      _visibility(widget.visible && _foreground);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_created) _visibility(widget.visible && _foreground);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_created) _visibility(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return const Center(child: Text('嵌入式商城支持 Android 和 iOS'));
    }
    final params = {
      'adInstanceId': widget.ad.instanceId,
      'adId': widget.adId,
      'visible': widget.visible && _foreground,
    };
    final gestures = {
      Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer())
    };
    void onCreated(int id) {
      if (!mounted) return;
      _created = true;
      _visibility(widget.visible && _foreground);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        key: ValueKey('${widget.ad.instanceId}/${widget.adId}'),
        viewType: AMPSPlatformViewRegistry.ampsSdkMallViewId,
        creationParamsCodec: const StandardMessageCodec(),
        creationParams: params,
        gestureRecognizers: gestures,
        onPlatformViewCreated: onCreated,
      );
    }
    return UiKitView(
      key: ValueKey('${widget.ad.instanceId}/${widget.adId}'),
      viewType: AMPSPlatformViewRegistry.ampsSdkMallViewId,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: params,
      gestureRecognizers: gestures,
      onPlatformViewCreated: onCreated,
    );
  }
}
