import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

class InterstitialShowPage extends StatefulWidget {
  const InterstitialShowPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialShowPage> createState() => _InterstitialShowPageState();
}

class _InterstitialShowPageState extends State<InterstitialShowPage> {
  final Map<String, AMPSInterstitialAd> _interAds = {};
  bool _bRenderReady = false;
  bool _pendingShowB = false;

  AdCallBack _callbackFor(String label) {
    return AdCallBack(
      onRenderOk: () {
        final ad = _interAds[label];
        debugPrint('[$label] interstitial onRenderOk id=${ad?.instanceId}');
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
        debugPrint('[$label] interstitial failure=$code;$msg');
      },
      onAdClicked: () => debugPrint('[$label] interstitial onAdClicked'),
      onAdClosed: () {
        debugPrint('[$label] interstitial onAdClosed');
        if (label == 'A') {
          final b = _interAds['B'];
          if (b != null) {
            if (_bRenderReady) {
              b.showAd();
            } else {
              _pendingShowB = true;
            }
          }
        }
      },
      onAdShow: () => debugPrint('[$label] interstitial onAdShow'),
    );
  }

  void _createAndLoad(String label) {
    final options = AdOptions(spaceId: interstitialSpaceId);
    final ad = AMPSInterstitialAd(config: options, mCallBack: _callbackFor(label));
    _interAds[label] = ad;
    debugPrint('[$label] created interstitial instanceId=${ad.instanceId}');
    ad.load();
  }

  void _destroyAll() {
    for (final ad in _interAds.values) {
      ad.destroy();
    }
    _interAds.clear();
    _bRenderReady = false;
    _pendingShowB = false;
  }

  void _startSequentialTest() {
    _destroyAll();
    _createAndLoad('A');
    _createAndLoad('B');
  }

  @override
  void dispose() {
    _destroyAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _startSequentialTest,
            child: const Text('同时创建A、B（A关闭后展示B）'),
          ),
          ElevatedButton(
            onPressed: () => _createAndLoad('A'),
            child: const Text('创建实例A并加载插屏'),
          ),
          ElevatedButton(
            onPressed: () => _createAndLoad('B'),
            child: const Text('创建实例B并加载插屏'),
          ),
        ],
      ),
    );
  }
}
