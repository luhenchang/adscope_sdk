import 'dart:io';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common.dart';
import 'widget/native_unified_widget.dart';

class UnifiedWidget extends StatefulWidget {
  /// 返回的广告 id，这里不是广告位id
  final String adId;

  /// 是否显示广告
  final bool show;

  final AMPSNativeAd? adNative;
  final NativeUnifiedWidget? unifiedContent;

  const UnifiedWidget(
    this.adNative, {
    super.key,
    required this.adId,
    required this.unifiedContent,
    this.show = true
  });

  @override
  State<StatefulWidget> createState() => _UnifiedWidgetState();
}

class _UnifiedWidgetState extends State<UnifiedWidget> with AutomaticKeepAliveClientMixin{
  /// 创建参数
  late Map<String, dynamic> creationParams;
  /// 宽高
  double width = 375, height = 128;
  bool widgetNeedClose = false;
  @override
  void initState() {
    widget.unifiedContent?.children.forEach((child){
       if(child is DownLoadWidget) {
         widget.adNative?.setDownloadListener(child.downloadListener);
       }
    });
    final expressSizeList = widget.adNative?.config.expressSize;
    if (expressSizeList != null && expressSizeList.length > 1) {
      width = expressSizeList[0]?.toDouble() ?? width;
      height = expressSizeList[1]?.toDouble() ?? height;
    }
    creationParams = <String, dynamic>{
      "adId": widget.adId,
      'unifiedWidget': widget.unifiedContent?.toMap(width: width)
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
          viewType: AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    } else if (Platform.isIOS) {
      view =  UiKitView(
          viewType: AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParamsCodec: const StandardMessageCodec());
    }
    // else if (Platform.isOhos) {
    //   view =  OhosView(
    //       viewType: AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
    //       onPlatformViewCreated: _onPlatformViewCreated,
    //       creationParams: creationParams,
    //       creationParamsCodec: const StandardMessageCodec());
    // }
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
  }
}
