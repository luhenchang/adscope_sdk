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
  final Map<String, AMPSSplashAd> _splashAds = {};
  bool _bRenderReady = false;
  bool _pendingShowB = false;
  bool couldBack = true;

  AdCallBack _callbackFor(String label) {
    return AdCallBack(
      onRenderOk: () async {
        final ad = _splashAds[label];
        debugPrint('[$label] splash onRenderOk id=${ad?.instanceId}');
        final seatId = await ad?.getSeatId();
        debugPrint('[$label] splash seatId=$seatId');
        if (label == 'A') {
          ad?.showAd();
        } else if (label == 'B') {
          _bRenderReady = true;
          if (_pendingShowB) {
            _pendingShowB = false;
            ad?.showAd();
          }
        }
      },
      onLoadFailure: (code, msg) {
        debugPrint('[$label] splash failure=$code;$msg');
      },
      onLoadSuccess: () {
        debugPrint('[$label] splash onLoadSuccess');
      },
      onAdClicked: () {
        setState(() => couldBack = true);
        debugPrint('[$label] splash onAdClicked');
      },
      onAdExposure: () {
        setState(() => couldBack = false);
        debugPrint('[$label] splash onAdExposure');
      },
      onAdClosed: () {
        setState(() => couldBack = true);
        debugPrint('[$label] splash onAdClosed');
        if (label == 'A') {
          final b = _splashAds['B'];
          if (b != null) {
            if (_bRenderReady) {
              b.showAd();
            } else {
              _pendingShowB = true;
            }
          }
        }
      },
      onAdShow: () {
        debugPrint('[$label] splash onAdShow');
        setState(() => couldBack = false);
      },
    );
  }

  void _createInstance(String label) {
    final size = MediaQuery.of(context).size;
    final options = AdOptions(
      spaceId: splashSpaceId,
      timeoutInterval: timeOut,
      expressSize: [size.width, size.height],
    );
    final ad = AMPSSplashAd(config: options, mCallBack: _callbackFor(label));
    _splashAds[label] = ad;
    debugPrint('[$label] created splash instanceId=${ad.instanceId}');
    ad.load();
  }

  void _destroyAll() {
    for (final ad in _splashAds.values) {
      ad.destroy();
    }
    _splashAds.clear();
    _bRenderReady = false;
    _pendingShowB = false;
  }

  void _startSequentialTest() {
    _destroyAll();
    _createInstance('A');
    _createInstance('B');
  }

  @override
  void dispose() {
    _destroyAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: couldBack,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const BlurredBackground(),
            Column(
              children: [
                const SizedBox(height: 80, width: 0),
                ButtonWidget(
                  buttonText: '同时创建A、B（A关闭后展示B）',
                  callBack: _startSequentialTest,
                ),
                ButtonWidget(
                  buttonText: '创建实例A并加载开屏',
                  callBack: () => _createInstance('A'),
                ),
                ButtonWidget(
                  buttonText: '创建实例B并加载开屏',
                  callBack: () => _createInstance('B'),
                ),
                ButtonWidget(
                  buttonText: '销毁全部实例',
                  callBack: _destroyAll,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
