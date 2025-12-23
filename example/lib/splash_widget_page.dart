import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class SplashWidgetPage extends StatefulWidget {
  const SplashWidgetPage({super.key, required this.title});

  final String title;

  @override
  State<SplashWidgetPage> createState() => _SplashWidgetPageState();
}

class _SplashWidgetPageState extends State<SplashWidgetPage> {
  AMPSSplashAd? _splashAd;
  late AdCallBack _adCallBack;
  bool splashVisible = false;
  bool couldBack = true;
  bool isLoading = false;
  num eCpm = -1;

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _adCallBack = AdCallBack(onRenderOk: () {
      setState(() {
        couldBack = false;
        splashVisible = true;
      });
      debugPrint("ad load onRenderOk");
    },onAdShow: () {
      debugPrint("ad load onAdShow");
    },onAdExposure: () {
      debugPrint("ad load onAdExposure");
    },onLoadFailure: (code, msg) {
      isLoading = false;
      debugPrint("ad load failure=$code;$msg");
    },onAdClicked: () {
      isLoading = false;
      setState(() {
        couldBack = true;
        splashVisible = false;
      });
      debugPrint("ad load onAdClicked");
    }, onAdClosed: () {
      isLoading = false;
      setState(() {
        couldBack = true;
        splashVisible = false;
      });
      debugPrint("ad load onAdClosed");
    });

    //TODO 保证开屏的宽高获取到
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        var size = MediaQuery.of(context).size;
        AdOptions options = AdOptions(spaceId: splashSpaceId, expressSize: [
          size.width,
          size.height - 100 //TODO 需要注意添加了底部自定义高度是100所以需要减去
        ]);
        _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
        _splashAd?.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: couldBack,
        child: Scaffold(
            body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const BlurredBackground(),
            Column(
              children: [
                const SizedBox(height: 100, width: 0),
                ButtonWidget(
                    buttonText: '点击加载开屏页面',
                    callBack: () {
                      if(isLoading) {
                        return;
                      }
                      isLoading = true;
                      AdOptions options = AdOptions(spaceId: splashSpaceId, splashAdBottomBuilderHeight: 100);
                      _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
                      // 点击再次刷新，加载广告。
                      _splashAd?.load();
                    }),
                ButtonWidget(
                    buttonText: '获取竞价=$eCpm',
                    callBack: () async {
                      bool? isReadyAd = await _splashAd?.isReadyAd();
                      debugPrint("isReadyAd=$isReadyAd");
                      if(_splashAd != null){
                        num ecPmResult =  await _splashAd!.getECPM();
                        debugPrint("ecPm请求结果=$eCpm");
                        setState(() {
                          eCpm = ecPmResult;
                        });
                      }
                    }),
              ],
            ),
            if (splashVisible) _buildSplashWidget()
          ],
        )));
  }

  Widget _buildSplashWidget() {
    return SplashWidget(_splashAd,
        splashBottomWidget: SplashBottomWidget(
            height: 100,
            backgroundColor: "#FFFFFFFF",
            children: [
              ImageComponent(
                width: 25,
                height: 25,
                x: 170,
                y: 10,
                imagePath: 'assets/images/img.png',
              ),
              TextComponent(
                fontSize: 24,
                color: "#00ff00",
                x: 140,
                y: 50,
                text: 'Hello Android!',
              ),
            ])
    );
  }
}
