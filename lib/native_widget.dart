import 'dart:io';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';

class NativeWidget extends StatefulWidget {
  // 返回的广告 id，这里不是广告位id
  final String adId;

  // 是否显示广告
  final bool show;

  final AMPSNativeAd? adNative;

  const NativeWidget(
    this.adNative, {
    super.key,
    required this.adId,
    this.show = true
  });

  @override
  State<StatefulWidget> createState() => _NativeWidgetState();
}

class _NativeWidgetState extends State<NativeWidget> with AutomaticKeepAliveClientMixin{
  /// 创建参数
  late Map<String, dynamic> creationParams;
  /// 宽高
  double width = 375, height = 528;
  bool widgetNeedClose = false;
  @override
  void initState() {
    final expressSizeList = widget.adNative?.config.expressSize;
    if (expressSizeList != null && expressSizeList.length > 1) {
      width = expressSizeList[0]?.toDouble() ?? width;
      height = expressSizeList[1]?.toDouble() ?? height;
    }
    creationParams = <String, dynamic>{
      "adId": widget.adId,
      "width": width
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!widget.show || width <= 0 || height <= 0 || widgetNeedClose) {
      return const SizedBox.shrink();
    }
    Widget view;
    if (Platform.isAndroid) {
      view = AndroidView(
          viewType: AMPSPlatformViewRegistry.ampsSdkNativeViewId,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      view =  UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkNativeViewId,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    }
    else if (Platform.isOhos) {
      view =  OhosView(
          viewType: AMPSPlatformViewRegistry.ampsSdkNativeViewId,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec());
    }
    else {
      view =  const Center(child: Text("暂不支持此平台"));
    }
    /// 有宽高信息了（渲染成功了）设置对应宽高
    return SizedBox.fromSize(
      size: Size(width, height),
      child: view,
    );
  }
  @override
  bool get wantKeepAlive => true;

  Future<void> callBack(MethodCall call) async {

  }
  void _onPlatformViewCreated(int id) {
    widget.adNative?.setAdCloseCallBack((){
      setState(() {
        widgetNeedClose = true;
      });
    });
    widget.adNative?.setSizeUpdate((w,h){
      setState(() {
        // debugPrint("nativeSizeUpdate11111-w:${w}h:$h");
        width = w;
        height = h;
      });
    });
  }
}
