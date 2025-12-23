import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BannerWidgetPage extends StatefulWidget {
  const BannerWidgetPage({super.key, required this.title});

  final String title;

  @override
  State<BannerWidgetPage> createState() => _BannerWidgetPageState();
}

class _BannerWidgetPageState extends State<BannerWidgetPage> {
  AMPSBannerAd? _bannerAd;
  late BannerCallBack _adCallBack;
  bool splashVisible = false;
  bool isLoading = false;
  num eCpm = -1;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _adCallBack = BannerCallBack(onLoadSuccess: () {
      isLoading = false;
      setState(() {
        splashVisible = true;
      });
      debugPrint("ad load onLoadSuccess");
    }, onAdShow: () {
      debugPrint("ad load onAdShow");
    }, onLoadFailure: (code, msg) {
      isLoading = false;
      debugPrint("ad load failure=$code;$msg");
    }, onAdClicked: () {
      debugPrint("ad load onAdClicked");
    }, onAdClosed: () {
      setState(() {
        splashVisible = false;
      });
      debugPrint("ad load onAdClosed");
    });
    //监听第一帧绘制完成（布局已完成，可安全获取 MediaQuery）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 获取屏幕尺寸（包含状态栏、导航栏等系统UI的整体屏幕尺寸）
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = 120;
      AdOptions options = AdOptions(
          spaceId: bannerSpaceId, expressSize: [screenWidth-20, screenHeight]);
      _bannerAd = AMPSBannerAd(config: options, mCallBack: _adCallBack);
      _bannerAd?.load();
    });
  }

  @override
  void dispose() {
    _bannerAd?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const BlurredBackground(),
            Column(children: [
              if (splashVisible) BannerWidget(_bannerAd),
              const SizedBox(height: 100, width: 0)
            ]),
          ],
        ));
  }
}
