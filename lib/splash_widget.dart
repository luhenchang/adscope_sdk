import 'dart:io';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class SplashWidget extends StatefulWidget {
  final AMPSSplashAd? adSplash;
  final SplashBottomWidget? splashBottomWidget;
  const SplashWidget(this.adSplash, {super.key,this.splashBottomWidget});

  @override
  State<StatefulWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  var splashParam = <dynamic, dynamic>{};

  bool splashNeedClose = false;
  @override
  void initState() {
    super.initState();
    splashParam[splashConfig] = widget.adSplash?.config.toMap();
    splashParam[splashBottomView] = widget.splashBottomWidget?.toMap();
  }

  @override
  Widget build(BuildContext context) {
    if (splashNeedClose) {
      return const SizedBox.shrink();
    }
    Widget view;
    if (Platform.isAndroid) {
      view = AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          creationParams: splashParam,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      view =  UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
          creationParams: splashParam,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    }
    // else if (Platform.isOhos) {
    //   view =  OhosView(
    //       viewType: AMPSPlatformViewRegistry.ampsSdkSplashViewId,
    //       onPlatformViewCreated: _onPlatformViewCreated,
    //       creationParams: splashParam,
    //       creationParamsCodec: const StandardMessageCodec());
    // }
    else {
      view =  const Center(child: Text("暂不支持此平台"));
    }
    // 有宽高信息了（渲染成功了）设置对应宽高
    return view;
  }

  void _onPlatformViewCreated(int id) {
    registerChannel();
  }
  ///当开屏页面关闭时，在Flutter层开屏组件内部让其开屏组件销毁，避免用户可见。
  void registerChannel() {
    widget.adSplash?.registerChannel((){
      setState(() {
        splashNeedClose = true;
      });
    });
  }
}
