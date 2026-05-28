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
  AMPSBannerAd? _bannerAdA;
  AMPSBannerAd? _bannerAdB;
  bool showA = false;
  bool showB = false;
  bool _bLoaded = false;
  bool _pendingShowB = false;

  BannerCallBack _callbackFor(String label) {
    return BannerCallBack(
      onLoadSuccess: () {
        debugPrint('[$label] banner onLoadSuccess id=${label == 'A' ? _bannerAdA?.instanceId : _bannerAdB?.instanceId}');
        if (label == 'A') {
          setState(() => showA = true);
        } else if (label == 'B') {
          _bLoaded = true;
          if (_pendingShowB) {
            _pendingShowB = false;
            setState(() => showB = true);
          }
        }
      },
      onAdShow: () => debugPrint('[$label] banner onAdShow'),
      onLoadFailure: (code, msg) {
        debugPrint('[$label] banner failure=$code;$msg');
      },
      onAdClicked: () => debugPrint('[$label] banner onAdClicked'),
      onAdClosed: () {
        debugPrint('[$label] banner onAdClosed');
        if (label == 'A') {
          setState(() => showA = false);
          if (_bannerAdB != null) {
            debugPrint('[$label] banner _bannerAdBss!');
            if (_bLoaded) {
              debugPrint('[$label] banner _bannerAdBss! showB = true');
              setState(() => showB = true);
            } else {
              _pendingShowB = true;
            }
          }
        } else if (label == 'B') {
          setState(() => showB = false);
        }
      },
    );
  }

  AdOptions _buildOptions() {
    final mediaQuery = MediaQuery.of(context);
    return AdOptions(
      spaceId: bannerSpaceId,
      expressSize: [mediaQuery.size.width - 20, 120],
    );
  }

  void _createInstance(String label) {
    final opts = _buildOptions();
    if (label == 'A') {
      _bannerAdA?.destroy();
      _bannerAdA = AMPSBannerAd(config: opts, mCallBack: _callbackFor('A'));
      debugPrint('[A] created banner instanceId=${_bannerAdA!.instanceId}');
      _bannerAdA!.load();
    } else {
      _bannerAdB?.destroy();
      _bannerAdB = AMPSBannerAd(config: opts, mCallBack: _callbackFor('B'));
      debugPrint('[B] created banner instanceId=${_bannerAdB!.instanceId}');
      _bannerAdB!.load();
    }
  }

  void _destroyAll() {
    _bannerAdA?.destroy();
    _bannerAdB?.destroy();
    _bannerAdA = null;
    _bannerAdB = null;
    _bLoaded = false;
    _pendingShowB = false;
    setState(() {
      showA = false;
      showB = false;
    });
  }

  void _startSequentialTest() {
    _destroyAll();
    _createInstance('A');
    _createInstance('B');
  }

  void _manualCloseCurrent() {
    if (showA) {
      _bannerAdA?.destroy();
      _bannerAdA = null;
      setState(() => showA = false);
      if (_bannerAdB != null) {
        if (_bLoaded) {
          setState(() => showB = true);
        } else {
          _pendingShowB = true;
        }
      }
    } else if (showB) {
      _bannerAdB?.destroy();
      _bannerAdB = null;
      setState(() => showB = false);
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
  }

  @override
  void dispose() {
    _bannerAdA?.destroy();
    _bannerAdB?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          const BlurredBackground(),
          Column(
            children: [
              ButtonWidget(
                buttonText: '同时创建A、B（A关闭后展示B）',
                callBack: _startSequentialTest,
              ),
              ButtonWidget(
                buttonText: '手动关闭当前Banner',
                callBack: _manualCloseCurrent,
              ),
              ButtonWidget(
                buttonText: '创建实例A并加载Banner',
                callBack: () => _createInstance('A'),
              ),
              ButtonWidget(
                buttonText: '创建实例B并加载Banner',
                callBack: () => _createInstance('B'),
              ),
              if (showA && _bannerAdA != null)
                BannerWidget(_bannerAdA, key: ValueKey('banner_${_bannerAdA!.instanceId}')),
              if (showB && _bannerAdB != null)
                BannerWidget(_bannerAdB, key: ValueKey('banner_${_bannerAdB!.instanceId}')),
              const SizedBox(height: 100, width: 0),
            ],
          ),
        ],
      ),
    );
  }
}
