

import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class RewardVideoPage extends StatefulWidget {
  const RewardVideoPage({super.key, required this.title});

  final String title;

  @override
  State<RewardVideoPage> createState() => _RewardVideoPageState();
}

class _RewardVideoPageState extends State<RewardVideoPage> {
  AMPSRewardVideoAd? _rewardVideoAd;
  late AdCallBack _adCallBack;
  num eCpm = 0;
  bool initSuccess = false;
  bool couldBack = true;
  @override
  void initState() {
    super.initState();
    _adCallBack = AdCallBack(onLoadSuccess: () {
      debugPrint("ad load onLoadSuccess");
    }, onRenderOk: () {
      debugPrint("Flutter==onAmpsAdLoaded=renderOK");
      _rewardVideoAd?.showAd();
      setState(() {
        couldBack = false;
      });
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
    }, onAdReward: () {
      debugPrint("ad load onAdReward");
    }, onAdShow: () {
      debugPrint("ad load onAdShow");
    }, onAdShowError: (code, msg) {
      debugPrint("ad load onAdShowError");
    }, onRenderFailure: () {
      debugPrint("ad load onRenderFailure");
    }, onVideoPlayStart: () {
      debugPrint("ad load onVideoPlayStart");
    }, onVideoPlayError: (code, msg) {
      debugPrint("ad load onVideoPlayError");
    }, onVideoPlayEnd: () {
      debugPrint("ad load onVideoPlayEnd");
    }, onVideoSkipToEnd: (duration) {
      debugPrint("ad load onVideoSkipToEnd=$duration");
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
                        buttonText: '点击加载激励视频',
                        callBack: () {
                          AdOptions options = AdOptions(spaceId: rewardVideoSpaceId);
                          _rewardVideoAd = AMPSRewardVideoAd(config: options,adCallBack: _adCallBack);
                          _rewardVideoAd?.load();
                        }),
                    ButtonWidget(
                        buttonText: '获取竞价=$eCpm',
                        callBack: () async {
                          bool? isReadyAd = await _rewardVideoAd?.isReadyAd();
                          debugPrint("isReadyAd=$isReadyAd");
                          if(_rewardVideoAd != null){
                            num ecPmResult =  await _rewardVideoAd!.getECPM();
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
