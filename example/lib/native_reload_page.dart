import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

/// 同一 [AMPSNativeAd] 多次 load 的演示页。
///
/// 媒体每次 load 后 loadOk/renderSuccess 都会带新 adId。
/// NativeWidget 内部会缓存 PlatformView 创建参数，必须用新 adId 做 [ValueKey]
/// 拆掉旧 widget，再建新 NativeWidget，UI 才会换成新广告。
class NativeReloadPage extends StatefulWidget {
  const NativeReloadPage({super.key, required this.title});

  final String title;

  @override
  State<NativeReloadPage> createState() => _NativeReloadPageState();
}

class _NativeReloadPageState extends State<NativeReloadPage> {
  AMPSNativeAd? _nativeAd;
  final List<String> _feedList = [];
  List<String> _visibleAdIds = [];
  List<String> _latestLoadAdIds = [];
  int _loadCount = 0;

  final double expressWidth = 350;
  final double expressHeight = 128;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      _feedList.add('item name =$i');
    }
  }

  @override
  void dispose() {
    _nativeAd?.destroy();
    super.dispose();
  }

  AMPSNativeAdListener get _adListener {
    return AMPSNativeAdListener(
      loadOk: (adIds) {
        _latestLoadAdIds = List<String>.from(adIds);
        debugPrint(
          '[reload] loadOk#$_loadCount adIds=$adIds instanceId=${_nativeAd?.instanceId}',
        );
      },
      loadFail: (code, message) {
        debugPrint('[reload] loadFail=$code, $message');
      },
    );
  }

  AMPSNativeRenderListener get _renderListener {
    return AMPSNativeRenderListener(
      renderSuccess: (adId) async {
        debugPrint('[reload] renderSuccess adId=$adId latest=$_latestLoadAdIds');
        if (!_latestLoadAdIds.contains(adId)) {
          return;
        }
        setState(() {
          // 只保留本轮 load 已渲染成功的新 adId，旧 NativeWidget 从树上移除。
          _visibleAdIds = _visibleAdIds
              .where(_latestLoadAdIds.contains)
              .toList();
          if (!_visibleAdIds.contains(adId)) {
            _visibleAdIds.add(adId);
          }
        });
        final seatId = await _nativeAd?.getSeatId();
        debugPrint('[reload] render seatId=$seatId visible=$_visibleAdIds');
      },
      renderFailed: (adId, code, message) {
        debugPrint('[reload] renderFailed adId=$adId code=$code msg=$message');
      },
    );
  }

  AmpsNativeInteractiveListener get _interactiveListener {
    return AmpsNativeInteractiveListener(
      onAdShow: (adId) => debugPrint('[reload] onAdShow=$adId'),
      onAdExposure: (adId) => debugPrint('[reload] onAdExposure=$adId'),
      onAdClicked: (adId) => debugPrint('[reload] onAdClicked=$adId'),
      toCloseAd: (adId) {
        debugPrint('[reload] onClose=$adId');
        if (adId == null) return;
        setState(() {
          _visibleAdIds.remove(adId);
        });
      },
    );
  }

  void _createAndLoad() {
    _nativeAd?.destroy();
    _latestLoadAdIds = [];
    _loadCount = 1;
    setState(() => _visibleAdIds = []);
    final options = AdOptions(
      spaceId: nativeSpaceId,
      adCount: 1,
      expressSize: [expressWidth, expressHeight],
    );
    _nativeAd = AMPSNativeAd(
      config: options,
      mCallBack: _adListener,
      mRenderCallBack: _renderListener,
    );
    debugPrint('[reload] created instanceId=${_nativeAd?.instanceId}');
    _nativeAd?.load();
    setState(() {});
  }

  void _reloadSameAd() {
    if (_nativeAd == null) {
      _createAndLoad();
      return;
    }
    _loadCount += 1;
    debugPrint(
      '[reload] load again #$_loadCount instanceId=${_nativeAd?.instanceId}',
    );
    _nativeAd?.load();
  }

  void _destroyAd() {
    _nativeAd?.destroy();
    _nativeAd = null;
    _latestLoadAdIds = [];
    _loadCount = 0;
    setState(() => _visibleAdIds = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'instanceId=${_nativeAd?.instanceId ?? '-'}\n'
              'loadCount=$_loadCount latestAdIds=$_latestLoadAdIds\n'
              'visibleAdIds=$_visibleAdIds',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: _createAndLoad,
                child: const Text('创建同一NativeAd并load'),
              ),
              ElevatedButton(
                onPressed: _reloadSameAd,
                child: const Text('再次load（替换旧Widget）'),
              ),
              ElevatedButton(
                onPressed: _destroyAd,
                child: const Text('销毁'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _feedList.length + _visibleAdIds.length,
              itemBuilder: (BuildContext context, int index) {
                final adIndex = index ~/ 3;
                final feedIndex = index - adIndex;
                if (index % 3 == 2 && adIndex < _visibleAdIds.length) {
                  final adId = _visibleAdIds[adIndex];
                  return Column(
                    children: [
                      Text('reload adId=$adId'),
                      NativeWidget(
                        _nativeAd,
                        key: ValueKey(adId),
                        adId: adId,
                        mInteractiveCallBack: _interactiveListener,
                      ),
                    ],
                  );
                }
                return Center(
                  child: Column(
                    children: [
                      const Divider(height: 5, color: Colors.white),
                      Container(
                        height: 128,
                        width: 350,
                        color: Colors.blueAccent,
                        alignment: Alignment.centerLeft,
                        child: Text('List item ${_feedList[feedIndex]}'),
                      ),
                      if (index % 3 == 1 && adIndex < _visibleAdIds.length)
                        const Divider(height: 5, color: Colors.white),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
