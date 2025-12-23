import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class InterstitialPage extends StatefulWidget {
  const InterstitialPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialPage> createState() => _InterstitialPageState();
}

class _InterstitialPageState extends State<InterstitialPage> {
  late AdCallBack _adCallBack;
  AMPSInterstitialAd? _interAd;
  bool visibleAd = false;
  bool couldBack = true;

  num eCpm = -1;
  @override
  void initState() {
    super.initState();
    _adCallBack = AdCallBack(
        onRenderOk: () {
          setState(() {
            visibleAd = true;
          });
          debugPrint("ad load onRenderOk");
        },
        onAdClosed: () {
          setState(() {
            couldBack = true;
            visibleAd = false;
          });
          debugPrint("ad load onAdClosed");
        },
        onAdShow: () {
          setState(() {
            couldBack = false;
          });
          debugPrint("ad load onAdShow");
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
        canPop: true,
        child: Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(children: [
                  ElevatedButton(
                    child: const Text('点击展示插屏'),
                    onPressed: () {
                      // 返回上一页
                      debugPrint("差评调用来了11");
                      _interAd?.load();
                    },
                  )
                ]),
                if (visibleAd) const InterstitialWidget()
              ],
            )));
  }
}