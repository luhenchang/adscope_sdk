import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

class NativePage extends StatefulWidget {
  const NativePage({super.key, required this.title});

  final String title;

  @override
  State<NativePage> createState() => _NativePageState();
}

class _NativePageState extends State<NativePage> {
  final Map<String, AMPSNativeAd> _nativeAds = {};
  final Map<String, List<String>> _adIdsByLabel = {'A': [], 'B': []};
  final Map<String, String> _adIdToLabel = {};

  List<String> feedList = [];
  List<String> feedAdList = [];

  bool _sequentialMode = false;
  List<String> _pendingBAdIds = [];

  final double expressWidth = 350;
  final double expressHeight = 128;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      feedList.add("item name =$i");
    }
  }

  @override
  void dispose() {
    for (final ad in _nativeAds.values) {
      ad.destroy();
    }
    super.dispose();
  }

  AMPSNativeAdListener _adListenerFor(String label) {
    return AMPSNativeAdListener(
      loadOk: (adIds) {
        debugPrint('[$label] native loadOk adIds=$adIds instanceId=${_nativeAds[label]?.instanceId}');
      },
      loadFail: (code, message) {
        debugPrint('[$label] native loadFail=$code, $message');
      },
    );
  }

  AMPSNativeRenderListener _renderListenerFor(String label) {
    return AMPSNativeRenderListener(
      renderSuccess: (adId) async {
        if (_sequentialMode) {
          _adIdsByLabel[label]?.add(adId);
          _adIdToLabel[adId] = label;
          // 顺序模式：A 渲染成功立即展示；B 渲染成功在 A 未关时缓存。
          if (label == 'A') {
            setState(() => feedAdList.add(adId));
          } else if (label == 'B') {
            final aAdIds = _adIdsByLabel['A'] ?? const <String>[];
            final aHasShown = aAdIds.any(feedAdList.contains);
            if (!aHasShown) {
              setState(() => feedAdList.add(adId));
            } else {
              _pendingBAdIds.add(adId);
            }
          }
        } else {
          _adIdToLabel[adId] = label;
          setState(() => feedAdList.add(adId));
        }
        // 新增api 获取 seatId
        final seatId = await _nativeAds[label]?.getSeatId();
        debugPrint('[$label] native render seatId=$seatId');
      },
      renderFailed: (adId, code, message) {
        debugPrint('[$label] native renderFailed adId=$adId code=$code msg=$message');
      },
    );
  }

  AmpsNativeInteractiveListener _interactiveListenerFor(String label) {
    return AmpsNativeInteractiveListener(
      onAdShow: (adId) => debugPrint('[$label] native onAdShow=$adId'),
      onAdExposure: (adId) => debugPrint('[$label] native onAdExposure=$adId'),
      onAdClicked: (adId) => debugPrint('[$label] native onAdClicked=$adId'),
      toCloseAd: (adId) {
        debugPrint('[$label] native onClose=$adId');
        if (adId == null) return;
        setState(() {
          feedAdList.remove(adId);
        });
        _adIdsByLabel[label]?.remove(adId);
        _adIdToLabel.remove(adId);
        if (_sequentialMode && label == 'A') {
          final remaining = _adIdsByLabel['A'] ?? const <String>[];
          final aStillVisible = remaining.any(feedAdList.contains);
          if (!aStillVisible && _pendingBAdIds.isNotEmpty) {
            setState(() {
              feedAdList.addAll(_pendingBAdIds);
            });
            _pendingBAdIds = [];
          }
        }
      },
    );
  }

  void _createInstance(String label, {int adCount = 1}) {
    final options = AdOptions(
      spaceId: nativeSpaceId,
      adCount: adCount,
      expressSize: [expressWidth, expressHeight],
    );
    _nativeAds[label]?.destroy();
    _adIdsByLabel[label] = [];
    final ad = AMPSNativeAd(
      config: options,
      mCallBack: _adListenerFor(label),
      mRenderCallBack: _renderListenerFor(label),
    );
    _nativeAds[label] = ad;
    debugPrint('[$label] created native instanceId=${ad.instanceId}');
    ad.load();
  }

  void _destroyAll() {
    for (final ad in _nativeAds.values) {
      ad.destroy();
    }
    _nativeAds.clear();
    _adIdsByLabel['A'] = [];
    _adIdsByLabel['B'] = [];
    _adIdToLabel.clear();
    _pendingBAdIds = [];
    setState(() => feedAdList.clear());
  }

  void _startSequentialTest() {
    _destroyAll();
    _sequentialMode = true;
    _createInstance('A', adCount: 1);
    _createInstance('B', adCount: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: _startSequentialTest,
                child: const Text('同时创建A、B（A关闭后展示B）'),
              ),
              ElevatedButton(
                onPressed: () {
                  _sequentialMode = false;
                  _createInstance('A', adCount: 2);
                },
                child: const Text('创建实例A加载2条'),
              ),
              ElevatedButton(
                onPressed: () {
                  _sequentialMode = false;
                  _createInstance('B', adCount: 2);
                },
                child: const Text('创建实例B加载2条'),
              ),
              ElevatedButton(
                onPressed: _destroyAll,
                child: const Text('销毁全部'),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: feedList.length + feedAdList.length,
              itemBuilder: (BuildContext context, int index) {
                int adIndex = index ~/ 3;
                int feedIndex = index - adIndex;
                if (index % 3 == 2 && adIndex < feedAdList.length) {
                  final adId = feedAdList[adIndex];
                  final label = _adIdToLabel[adId] ?? '?';
                  final nativeAd = _nativeAds[label];
                  return Column(
                    children: [
                      Text('实例[$label] adId=$adId'),
                      NativeWidget(
                        nativeAd,
                        mInteractiveCallBack: _interactiveListenerFor(label),
                        key: ValueKey(adId),
                        adId: adId,
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
                        child: Text('List item ${feedList[feedIndex]}'),
                      ),
                      if (index % 3 == 1 && adIndex < feedAdList.length)
                        const Divider(height: 5, color: Colors.white)
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
