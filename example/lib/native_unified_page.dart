import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

import 'union_download_app_info_page.dart';

class NativeUnifiedPage extends StatefulWidget {
  const NativeUnifiedPage({super.key, required this.title});

  final String title;

  @override
  State<NativeUnifiedPage> createState() => _NativeUnifiedPageState();
}

class _NativeUnifiedPageState extends State<NativeUnifiedPage> {
  final Map<String, AMPSNativeAd> _nativeAds = {};
  final Map<String, List<String>> _adIdsByLabel = {'A': [], 'B': []};
  final Map<String, String> _adIdToLabel = {};
  final Map<String, UnifiedAdDownloadAppInfo?> _downloadInfoByAdId = {};
  final Map<String, AMPSUnifiedPattern> _patternByAdId = {};

  List<String> feedList = [];
  List<String> feedAdList = [];

  bool _sequentialMode = false;
  List<String> _pendingBAdIds = [];

  final double expressWidth = 350;
  final double expressHeight = 180;

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
        debugPrint('[$label] unified loadOk adIds=$adIds instanceId=${_nativeAds[label]?.instanceId}');
      },
      loadFail: (code, message) {
        debugPrint('[$label] unified loadFail=$code, $message');
      },
    );
  }

  AMPSNativeRenderListener _renderListenerFor(String label) {
    return AMPSNativeRenderListener(
      renderSuccess: (adId) {
        debugPrint('[$label] unified renderSuccess adId=$adId');
        final ad = _nativeAds[label];
        ad?.getUnifiedPattern(adId).then((pattern) {
          if (!mounted) return;
          setState(() {
            _patternByAdId[adId] = pattern;
          });
        });
        ad?.getDownLoadInfo(adId).then((info) {
          if (!mounted) return;
          setState(() {
            _downloadInfoByAdId[adId] = info;
          });
        });
        _adIdsByLabel[label]?.add(adId);
        _adIdToLabel[adId] = label;
        if (_sequentialMode && label == 'B') {
          final aAdIds = _adIdsByLabel['A'] ?? const <String>[];
          final aHasShown = aAdIds.any(feedAdList.contains);
          if (aHasShown) {
            _pendingBAdIds.add(adId);
            return;
          }
        }
        setState(() => feedAdList.add(adId));
      },
      renderFailed: (adId, code, message) {
        debugPrint('[$label] unified renderFailed=$code, $message');
      },
    );
  }

  AmpsNativeInteractiveListener _interactiveListenerFor(String label) {
    return AmpsNativeInteractiveListener(
      onAdShow: (adId) => debugPrint('[$label] unified onAdShow=$adId'),
      onAdExposure: (adId) => debugPrint('[$label] unified onAdExposure=$adId'),
      onAdClicked: (adId) => debugPrint('[$label] unified onAdClicked=$adId'),
      toCloseAd: (adId) {
        debugPrint('[$label] unified onClose=$adId');
        _handleAdClosed(label, adId);
      },
    );
  }

  void _handleAdClosed(String label, String? adId) {
    if (adId == null) return;
    setState(() {
      feedAdList.remove(adId);
    });
    _adIdsByLabel[label]?.remove(adId);
    _adIdToLabel.remove(adId);
    _downloadInfoByAdId.remove(adId);
    _patternByAdId.remove(adId);
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
  }

  void _createInstance(String label, {int adCount = 1}) {
    _nativeAds[label]?.destroy();
    _adIdsByLabel[label] = [];
    final options = AdOptions(
      spaceId: unifiedSpaceId,
      adCount: adCount,
      expressSize: [expressWidth, expressHeight],
    );
    final ad = AMPSNativeAd(
      config: options,
      nativeType: NativeType.unified,
      mCallBack: _adListenerFor(label),
      mRenderCallBack: _renderListenerFor(label),
    );
    _nativeAds[label] = ad;
    debugPrint('[$label] created unified instanceId=${ad.instanceId}');
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
    _downloadInfoByAdId.clear();
    _patternByAdId.clear();
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
                  _createInstance('A', adCount: 1);
                },
                child: const Text('创建实例A'),
              ),
              ElevatedButton(
                onPressed: () {
                  _sequentialMode = false;
                  _createInstance('B', adCount: 1);
                },
                child: const Text('创建实例B'),
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
                int adIndex = index ~/ 5;
                int feedIndex = index - adIndex;
                if (index % 5 == 4 && adIndex < feedAdList.length) {
                  final adId = feedAdList[adIndex];
                  final label = _adIdToLabel[adId] ?? '?';
                  final nativeAd = _nativeAds[label];
                  final pattern = _patternByAdId[adId] ?? AMPSUnifiedPattern.adPatternUnknown;
                  final downloadInfo = _downloadInfoByAdId[adId];
                  return Column(
                    children: [
                      Text('实例[$label] adId=$adId'),
                      SizedBox.fromSize(
                        size: Size(expressWidth, expressHeight),
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            UnifiedWidget(
                              nativeAd,
                              mInteractiveCallBack: _interactiveListenerFor(label),
                              key: ValueKey(adId),
                              adId: adId,
                              unifiedContent: NativeUnifiedWidget(
                                width: expressWidth,
                                height: expressHeight,
                                backgroundColor: '#80F7FF',
                                children: _getChildrenByType(pattern.value),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 26,
                              child: InkWell(
                                onTap: () => _handleAdClosed(label, adId),
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset('assets/images/close.png',
                                    width: 18, height: 18),
                              ),
                            ),
                            if (downloadInfo != null && downLoadAppInfoIsOk(downloadInfo))
                              Positioned(
                                left: 28,
                                top: 100,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      'UnionDownloadAppInfoPage',
                                      arguments: AppInfoArguments(
                                        titleContent: downloadInfo.appName ?? "",
                                        permissionContent: downloadInfo.appPermission ?? "",
                                        privacyContent: downloadInfo.appPrivacy ?? "",
                                        introContent: downloadInfo.appIntro ?? "",
                                      ).toMap(),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Text(
                                    "应用名称：${downloadInfo.appName} | 开发者：${downloadInfo.appDeveloper}",
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    const Divider(height: 5, color: Colors.white),
                    Container(
                      height: expressHeight,
                      width: expressWidth,
                      color: Colors.blueAccent,
                      alignment: Alignment.centerLeft,
                      child: Text('List item ${feedList[feedIndex]}'),
                    ),
                    if (index % 5 == 3 && adIndex < feedAdList.length)
                      const Divider(height: 5, color: Colors.white)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<LayoutWidget> _getChildrenByType(int type) {
    debugPrint("type=$type");
    switch (type) {
      case 0:
        return [
          UnifiedTitleWidget(fontSize: 18, color: "#1D2129", x: 2, y: 3),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
            clickType: AMPSAdItemClickType.click
          ),
          UnifiedDescWidget(
            fontSize: 14,
            width: expressWidth - 8,
            color: "#4E5969",
            ellipsize: Ellipsize.end,
            maxLines: 1,
            x: 37,
            y: expressHeight - 30,
          ),
          UnifiedAppIconWidget(width: 25, height: 25, x: 10, y: expressHeight - 30),
          UnifiedAdSourceLogoWidget(
            width: 50,
            height: 25,
            x: expressWidth - 50,
            y: expressHeight - 30,
          ),
          UnifiedActionButtonWidget(
            fontSize: 12,
            width: 50,
            height: 20,
            fontColor: '#FFFFFF',
            backgroundColor: '#2F80ED',
            x: expressWidth - 60,
            y: expressHeight - 60,
          ),
        ];
      case 2:
        return [
          UnifiedTitleWidget(fontSize: 18, color: "#1D2129", x: 2, y: 3),
          UnifiedVideoWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 30,
          ),
          UnifiedAppIconWidget(width: 25, height: 25, x: 10, y: expressHeight - 30),
          UnifiedActionButtonWidget(
            fontSize: 12,
            width: 50,
            height: 20,
            fontColor: '#FFFFFF',
            backgroundColor: '#2F80ED',
            x: expressWidth - 60,
            y: expressHeight - 32,
          ),
        ];
      case 1:
        return [
          UnifiedTitleWidget(fontSize: 18, color: "#1D2129", x: 2, y: 3),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
          ),
          ShakeWidget(width: 100, height: 100, x: 100, y: 50),
          UnifiedDescWidget(
            fontSize: 14,
            width: 180,
            color: "#4E5969",
            ellipsize: Ellipsize.end,
            maxLines: 1,
            x: 2,
            y: expressHeight - 30,
          ),
        ];
      case 3:
        return [
          UnifiedTitleWidget(fontSize: 18, color: "#1D2129", x: 2, y: 3),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
          ),
          UnifiedVideoWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 30,
          ),
          UnifiedDescWidget(
            fontSize: 14,
            width: 180,
            color: "#4E5969",
            ellipsize: Ellipsize.end,
            maxLines: 1,
            x: 2,
            y: expressHeight - 30,
          ),
          UnifiedActionButtonWidget(
            fontSize: 12,
            width: 50,
            height: 20,
            fontColor: '#FFFFFF',
            backgroundColor: '#2F80ED',
            x: expressWidth - 60,
            y: expressHeight - 32,
          ),
          UnifiedAppIconWidget(width: 25, height: 25, x: 10, y: expressHeight - 30),
          ShakeWidget(width: 100, height: 100, x: 100, y: 50),
        ];
      default:
        return [];
    }
  }

  bool downLoadAppInfoIsOk(UnifiedAdDownloadAppInfo? downLoadAppInfo) {
    if (downLoadAppInfo == null) return false;
    bool result = true;
    if (downLoadAppInfo.appName == null) result = false;
    if (downLoadAppInfo.appPermission == null) result = false;
    if (downLoadAppInfo.appDeveloper == null) result = false;
    if (downLoadAppInfo.appVersion == null) result = false;
    if (downLoadAppInfo.appPrivacy == null) result = false;
    if (downLoadAppInfo.appIntro == null) result = false;
    if (downLoadAppInfo.appPackageName == null) result = false;
    return result;
  }
}
