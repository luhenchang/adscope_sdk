import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class SplashShowPage extends StatefulWidget {
  const SplashShowPage({super.key, required this.title});

  final String title;

  @override
  State<SplashShowPage> createState() => _SplashShowPageState();
}

class _SplashShowPageState extends State<SplashShowPage> {
  AMPSSplashAd? _splashAd;
  late AdCallBack _adCallBack;
  num eCpm = 0;
  bool initSuccess = false;
  bool couldBack = true;
  @override
  void initState() {
    super.initState();
    _adCallBack = AdCallBack(
        onRenderOk: () {
      _splashAd?.showAd();
          //TODO 如果添加了底部自定义，那么开屏的高度 = size.height - 100（这里的100是底部自定义部分的高度）
          // splashBottomWidget: SplashBottomWidget(
          //     height: 100,
          //     backgroundColor: "#FFFFFFFF",
          //     children: [
          //   ImageComponent(
          //     width: 25,
          //     height: 25,
          //     x: 170,
          //     y: 10,
          //     imagePath: 'assets/images/img.png',
          //   ),
          //   TextComponent(
          //     fontSize: 24,
          //     color: "#00ff00",
          //     x: 140,
          //     y: 50,
          //     text: 'Hello Android!',
          //   ),
          // ]));
      debugPrint("ad load onRenderOk");
    }, onLoadFailure: (code, msg) {
      debugPrint("ad load failure=$code;$msg");
    }, onAdClicked: () {
      setState(() {
        couldBack = true;
      });
      debugPrint("ad load onAdClicked");
    }, onAdExposure: () {
      setState(() {
        couldBack = false;
      });
      debugPrint("ad load onAdExposure");
    }, onAdClosed: () {
      setState(() {
        couldBack = true;
      });
      debugPrint("ad load onAdClosed");
    }, onAdShow: () {
      debugPrint("ad load onAdShow");
      setState(() {
        couldBack = false;
      });
    });
    //TODO 保证开屏的宽高获取到
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        var size = MediaQuery.of(context).size;
        AdOptions options = AdOptions(
            spaceId: splashSpaceId,expressSize: [size.width,size.height]);
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
            appBar: AppBar(
              title: Text(widget.title),
            ),
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
                          var size = MediaQuery.of(context).size;
                          AdOptions options = AdOptions(
                              spaceId: splashSpaceId,expressSize: [size.width,size.height]);
                          _splashAd = AMPSSplashAd(config: options, mCallBack: _adCallBack);
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
                        })
                  ],
                )
              ],
            )));
  }
}
