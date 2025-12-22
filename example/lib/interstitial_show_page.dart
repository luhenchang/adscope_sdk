import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';
class InterstitialShowPage extends StatefulWidget {
  const InterstitialShowPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialShowPage> createState() => _InterstitialShowPageState();
}

class _InterstitialShowPageState extends State<InterstitialShowPage> {
  late AdCallBack _adCallBack;
  AMPSInterstitialAd? _interAd;
  bool couldBack = true;
  num eCpm = 0;
  @override
  void initState() {
    super.initState();
    _adCallBack = AdCallBack(
        onRenderOk: () {
          _interAd?.showAd();
          debugPrint("ad load onRenderOk");
        },
        onLoadFailure: (code, msg) {
          debugPrint("ad load failure=$code;$msg");
        },
        onAdClicked: () {
          setState(() {
            couldBack = true;
          });
          debugPrint("ad load onAdClicked");
        },
        onAdExposure: () {
          debugPrint("ad load onAdExposure");
        },
        onAdClosed: () {
          setState(() {
            couldBack = true;
          });
          debugPrint("ad load onAdClosed");
        },
        onAdReward: () {
          debugPrint("ad load onAdReward");
        },
        onAdShow: () {
          setState(() {
            couldBack = false;
          });
          debugPrint("ad load onAdShow");
        },
        onAdShowError: (code, msg) {
          debugPrint("ad load onAdShowError");
        },
        onRenderFailure: () {
          debugPrint("ad load onRenderFailure");
        },
        onVideoPlayStart: () {
          debugPrint("ad load onVideoPlayStart");
        },
        onVideoPlayError: (code,msg) {
          debugPrint("ad load onVideoPlayError");
        },
        onVideoPlayEnd: () {
          debugPrint("ad load onVideoPlayEnd");
        },
        onVideoSkipToEnd: (duration) {
          debugPrint("ad load onVideoSkipToEnd=$duration");
        });

    AdOptions options = AdOptions(spaceId: interstitialSpaceId);
    _interAd = AMPSInterstitialAd(config: options, mCallBack: _adCallBack);
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: couldBack,
        child:   Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(children: [
        Column(
          children:[
            ElevatedButton(
            child: const Text('点击展示插屏'),
            onPressed: () {
              // 返回上一页
              AdOptions options = AdOptions(spaceId: interstitialSpaceId);
              _interAd = AMPSInterstitialAd(config: options, mCallBack: _adCallBack);
              _interAd?.load();
            },
          ),
            ButtonWidget(
                buttonText: '获取竞价=$eCpm',
                callBack: () async {
                  bool? isReadyAd = await _interAd?.isReadyAd();
                  debugPrint("isReadyAd=$isReadyAd");
                  if(_interAd != null){
                    num ecPmResult =  await _interAd!.getECPM();
                    setState(() {
                      eCpm = ecPmResult;
                      debugPrint("ecPm请求结果=$eCpm");
                    });
                  }
                })
          ]
        ),
      ],)
    ));
  }
}