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
  bool couldBack = true;
  bool isLoading = false;
  num eCpm = -1;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _adCallBack = BannerCallBack(onLoadSuccess: () {
      setState(() {
        couldBack = false;
        splashVisible = true;
      });
      debugPrint("ad load onRenderOk");
    }, onAdShow: () {
      debugPrint("ad load onAdShow");
    }, onLoadFailure: (code, msg) {
      isLoading = false;
      debugPrint("ad load failure=$code;$msg");
    }, onAdClicked: () {
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

    AdOptions options = AdOptions(spaceId: splashSpaceId);
    _bannerAd = AMPSBannerAd(config: options, mCallBack: _adCallBack);
    _bannerAd?.load();
  }
  @override
  void dispose() {
    _bannerAd?.destroy();
    super.dispose();
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
                if (splashVisible) _buildBannerWidget(),
                const SizedBox(height: 100, width: 0),
                ButtonWidget(
                    buttonText: '获取竞价=$eCpm',
                    callBack: () async {
                      bool? isReadyAd = await _bannerAd?.isReadyAd();
                      debugPrint("isReadyAd=$isReadyAd");
                      if (_bannerAd != null) {
                        num ecPmResult = await _bannerAd!.getECPM();
                        debugPrint("ecPm请求结果=$eCpm");
                        setState(() {
                          eCpm = ecPmResult;
                        });
                      }
                    }),
              ],
            ),
          ],
        )));
  }

  Widget _buildBannerWidget() {
    return BannerWidget(_bannerAd);
  }
}
