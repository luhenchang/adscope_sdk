import 'dart:async';
import 'dart:io';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class DrawWidget extends StatefulWidget {
  final String adId;

  final AMPSDrawAd? adDraw;

  final AMPSDrawVideoListener? mVideoPlayerCallBack;
  const DrawWidget(
      this.adDraw, {required this.adId,super.key,
        this.mVideoPlayerCallBack});


  @override
  State<StatefulWidget> createState() => _DrawWidgetState();
}

class _DrawWidgetState extends State<DrawWidget>
    with AutomaticKeepAliveClientMixin {
  /// 创建参数
  late Map<String, dynamic> creationParams;

  /// 宽高
  double width = 0, height = 0;
  bool widgetNeedClose = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    widget.adDraw?.setAdCloseCallBack(widget.adId,() {
      setState(() {
        widgetNeedClose = true;
      });
    });
    widget.adDraw?.setVideoPlayerListener(widget.adId, widget.mVideoPlayerCallBack);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_initialized) {
      _initialized = true;
      width = MediaQuery.of(context).size.width;
      height = MediaQuery.of(context).size.height;
      final expressSizeList = widget.adDraw?.config.expressSize;
      if (expressSizeList != null && expressSizeList.length > 1) {
        width = expressSizeList[0]?.toDouble() ?? width;
        height = expressSizeList[1]?.toDouble() ?? height;
      }
      creationParams = <String, dynamic>{
        "adId": widget.adId,
        "width": width
      };
    }

    if (width <= 0 || height <= 0 || widgetNeedClose) {
      return const SizedBox.shrink();
    }
    Widget view;
    if (Platform.isAndroid) {
      view = AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkDrawViewId,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      view = UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkDrawViewId,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    }
    // else if (Platform.isOhos) {
    //   view =  OhosView(
    //       viewType: AMPSPlatformViewRegistry.ampsSdkDrawViewId,
    //       onPlatformViewCreated: _onPlatformViewCreated,
    //       creationParams: creationParams,
    //       creationParamsCodec: const StandardMessageCodec());
    // }
    else {
      view = const Center(child: Text("暂不支持此平台"));
    }

    /// 有宽高信息了（渲染成功了）设置对应宽高
    return SizedBox.fromSize(
      size: Size(width, height),
      child: view,
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> callBack(MethodCall call) async {}

  void _onPlatformViewCreated(int id) {
    widget.adDraw?.setSizeUpdate(widget.adId,(w, h) {
      setState(() {
        width = w;
        height = h;
      });
    });
  }
}
