import 'dart:io';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';
///插屏组件
class InterstitialWidget extends StatefulWidget {
  final AMPSInterstitialAd? ad;
  const InterstitialWidget(this.ad, {super.key});

  @override
  State<StatefulWidget> createState() => _InterstitialWidgetState();
}

class _InterstitialWidgetState extends State<InterstitialWidget> {
  var param = <dynamic, dynamic>{};
  bool widgetNeedClose = false;
  @override
  void initState() {
    super.initState();
    param[splashConfig] = widget.ad?.config.toMap();
  }

  @override
  Widget build(BuildContext context) {
    if (widgetNeedClose) {
      return const SizedBox.shrink();
    }
    Widget view;
    if (Platform.isAndroid) {
      view = AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          creationParams: param,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      view =  UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          creationParams: param,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    }
    else if (Platform.isOhos) {
      view =  OhosView(
          viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: param,
          creationParamsCodec: const StandardMessageCodec());
    }
    else {
      view =  const Center(child: Text("暂不支持此平台"));
    }
    // 有宽高信息了（渲染成功了）设置对应宽高
    return view;
  }
  ///通知关闭开屏显示组件内容，避免关闭广告之后用户可见。
  void _onPlatformViewCreated(int id) {
    debugPrint("ad load  _onPlatformViewCreated");
    setState(() {
      widgetNeedClose = true;
    });
  }
}
