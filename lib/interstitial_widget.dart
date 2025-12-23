import 'dart:io';
import 'package:flutter/cupertino.dart';
///插屏组件
class InterstitialWidget extends StatefulWidget {
  const InterstitialWidget({super.key});

  @override
  State<StatefulWidget> createState() => _InterstitialWidgetState();
}

class _InterstitialWidgetState extends State<InterstitialWidget> {
  var param = <dynamic, dynamic>{};
  bool widgetNeedClose = false;
  @override
  void initState() {
    super.initState();
    // param[splashConfig] = widget.ad?.config.toMap();
  }

  @override
  Widget build(BuildContext context) {
    if (widgetNeedClose) {
      return const SizedBox.shrink();
    }
    Widget view;
    if (Platform.isAndroid) {
      view =  const Center(child: Text("Android端暂不支持组件方式"));
    } else if (Platform.isIOS) {
      view =  const Center(child: Text("IOS端暂不支持组件方式"));
    }
    // else if (Platform.isOhos) {
    //   view =  OhosView(
    //       viewType: AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
    //       onPlatformViewCreated: _onPlatformViewCreated,
    //       creationParams: param,
    //       creationParamsCodec: const StandardMessageCodec());
    // }
    else {
      view =  const Center(child: Text("暂不支持此平台"));
    }
    return view;
  }
  ///通知关闭开屏显示组件内容，避免关闭广告之后用户可见。
  // void _onPlatformViewCreated(int id) {
  //   debugPrint("ad load  _onPlatformViewCreated");
  //   setState(() {
  //     widgetNeedClose = true;
  //   });
  // }
}
