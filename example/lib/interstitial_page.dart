import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

class InterstitialPage extends StatefulWidget {
  const InterstitialPage({super.key, required this.title});

  final String title;

  @override
  State<InterstitialPage> createState() => _InterstitialPageState();
}

class _InterstitialPageState extends State<InterstitialPage> {
  final Map<String, AMPSInterstitialAd> _interAds = {};
  bool visibleAd = false;
  bool couldBack = true;
  String? _visibleLabel;
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
      onAdClosed: () {
        setState(() {
          couldBack = true;
          visibleAd = false;
          _visibleLabel = null;
        });
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
      onAdShow: () {
        setState(() {
          couldBack = false;
          visibleAd = true;
          _visibleLabel = label;
        });
        debugPrint('[$label] interstitial onAdShow');
      },
    );
  }

  void _createInstance(String label) {
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
      canPop: true,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: _startSequentialTest,
                  child: const Text('同时创建A、B（A关闭后展示B）'),
                ),
                ElevatedButton(
                  onPressed: () => _createInstance('A'),
                  child: const Text('创建实例A并加载插屏'),
                ),
                ElevatedButton(
                  onPressed: () => _createInstance('B'),
                  child: const Text('创建实例B并加载插屏'),
                ),
                if (_visibleLabel != null)
                  Text('当前展示回调来自: $_visibleLabel'),
              ],
            ),
            if (visibleAd) const InterstitialWidget(),
          ],
        ),
      ),
    );
  }
}
