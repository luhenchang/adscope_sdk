import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

enum FeedItemType { content, ad }

class FeedItem {
  final FeedItemType type;
  final String data;
  final String? title;
  final String? description;
  final String? bgImageUrl;

  FeedItem({
    required this.type,
    required this.data,
    this.title,
    this.description,
    this.bgImageUrl,
  });
}

class DrawPage extends StatefulWidget {
  const DrawPage({super.key, required this.title});

  final String title;

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> with WidgetsBindingObserver {
  final Map<String, AMPSDrawAd> _drawAds = {};
  final Map<String, List<String>> _adIdsByLabel = {'A': [], 'B': []};
  final Map<String, String> _adIdToLabel = {};

  List<FeedItem> mergedFeedList = [];
  late PageController _pageController;

  bool _sequentialMode = false;
  List<String> _pendingBAdIds = [];

  final List<Map<String, String>> _douyinStyleContent = [
    {"title": "开屏广告功能集成", "description": "支持自定义展示时长、跳过按钮样式，平衡用户体验与广告曝光效率", "bgUrl": ""},
    {"title": "激励视频广告优化", "description": "基于用户行为分析的智能展示策略，提升广告转化与用户留存率", "bgUrl": ""},
    {"title": "Banner广告自适应适配", "description": "自动适配多屏幕尺寸，简化Flutter/原生多端集成流程", "bgUrl": ""},
    {"title": "原生广告样式定制", "description": "支持布局结构、字体样式自定义，贴合App视觉风格与交互逻辑", "bgUrl": ""},
    {"title": "广告数据统计分析", "description": "实时监控曝光、点击、转化数据，助力运营决策与效果优化", "bgUrl": ""},
    {"title": "跨平台兼容性保障", "description": "适配Flutter/Android/iOS/HarmonyOS，保障多端一致展示效果", "bgUrl": ""},
    {"title": "广告加载性能优化", "description": "预加载+缓存机制，降低加载耗时，提升广告展示成功率", "bgUrl": ""},
    {"title": "隐私合规性支持", "description": "符合GDPR/CCPA等法规要求，提供用户授权管理与数据加密传输", "bgUrl": ""},
    {"title": "自定义广告触发逻辑", "description": "支持基于场景/行为的触发条件配置，提升广告相关性", "bgUrl": ""},
    {"title": "多广告源聚合管理", "description": "集成多家广告平台资源，智能选路提升填充率与收益", "bgUrl": ""}
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();

    for (var i = 0; i < 10; i++) {
      mergedFeedList.add(
        FeedItem(
          type: FeedItemType.content,
          data: "item name =$i",
          title: _douyinStyleContent[i]["title"],
          description: _douyinStyleContent[i]["description"],
          bgImageUrl: _douyinStyleContent[i]["bgUrl"],
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        for (final ad in _drawAds.values) {
          ad.resumeAd();
        }
        break;
      case AppLifecycleState.paused:
        for (final ad in _drawAds.values) {
          ad.pauseAd();
        }
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final ad in _drawAds.values) {
      ad.destroy();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AMPSDrawAdListener _adListenerFor(String label) {
    return AMPSDrawAdListener(
      loadOk: (adIds) {
        debugPrint('[$label] draw loadOk adIds=$adIds instanceId=${_drawAds[label]?.instanceId}');
      },
      loadFail: (code, message) {
        debugPrint('[$label] draw loadFail=$code, $message');
      },
    );
  }

  AMPSDrawRenderListener _renderListenerFor(String label) {
    return AMPSDrawRenderListener(
      onAdShow: (adId) => debugPrint('[$label] draw onAdShow=$adId'),
      onAdClick: (adId) => debugPrint('[$label] draw onAdClick=$adId'),
      onAdClose: (adId) {
        debugPrint('[$label] draw onAdClose=$adId');
        setState(() {
          mergedFeedList.removeWhere(
            (item) => item.type == FeedItemType.ad && item.data == adId,
          );
        });
        _adIdsByLabel[label]?.remove(adId);
        _adIdToLabel.remove(adId);
        if (_sequentialMode && label == 'A') {
          final remaining = _adIdsByLabel['A'] ?? const <String>[];
          final aStillVisible = remaining.any((id) =>
              mergedFeedList.any((it) => it.type == FeedItemType.ad && it.data == id));
          if (!aStillVisible && _pendingBAdIds.isNotEmpty) {
            setState(() {
              for (final id in _pendingBAdIds) {
                if (mergedFeedList.length > 1) {
                  mergedFeedList.insert(1, FeedItem(type: FeedItemType.ad, data: id));
                } else {
                  mergedFeedList.add(FeedItem(type: FeedItemType.ad, data: id));
                }
              }
            });
            _pendingBAdIds = [];
          }
        }
      },
      renderFailed: (adId, code, message) {
        debugPrint('[$label] draw renderFailed adId=$adId code=$code msg=$message');
      },
      renderSuccess: (adId) {
        debugPrint('[$label] draw renderSuccess=$adId');
        _adIdsByLabel[label]?.add(adId);
        _adIdToLabel[adId] = label;
        if (_sequentialMode && label == 'B') {
          final aAdIds = _adIdsByLabel['A'] ?? const <String>[];
          final aHasShown = aAdIds.any((id) =>
              mergedFeedList.any((it) => it.type == FeedItemType.ad && it.data == id));
          if (aHasShown) {
            _pendingBAdIds.add(adId);
            return;
          }
        }
        setState(() {
          final exists = mergedFeedList.any(
            (item) => item.type == FeedItemType.ad && item.data == adId,
          );
          if (!exists) {
            if (mergedFeedList.length > 1) {
              mergedFeedList.insert(1, FeedItem(type: FeedItemType.ad, data: adId));
            } else {
              mergedFeedList.add(FeedItem(type: FeedItemType.ad, data: adId));
            }
          }
        });
      },
    );
  }

  AMPSDrawVideoListener _videoListenerFor(String label) {
    return AMPSDrawVideoListener(
      onVideoAdPaused: (adId) => debugPrint('[$label] draw video paused=$adId'),
      onVideoAdContinuePlay: (adId) => debugPrint('[$label] draw video continue=$adId'),
      onVideoError: (adId, code, message) {},
      onVideoAdComplete: (adId) => debugPrint('[$label] draw video complete=$adId'),
      onVideoLoad: (adId) {},
      onVideoAdStartPlay: (adId) => debugPrint('[$label] draw video start=$adId'),
      onProgressUpdate: (adId, current, position) {},
    );
  }

  void _createInstance(String label, {int adCount = 1}) {
    _drawAds[label]?.destroy();
    _adIdsByLabel[label] = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final expressWidth = MediaQuery.of(context).size.width;
      final expressHeight = MediaQuery.of(context).size.height;
      final options = AdOptions(
        spaceId: drawSpaceId,
        adCount: adCount,
        expressSize: [expressWidth, expressHeight],
        timeoutInterval: 15000,
      );
      final ad = AMPSDrawAd(
        config: options,
        mRenderCallBack: _renderListenerFor(label),
        mCallBack: _adListenerFor(label),
      );
      _drawAds[label] = ad;
      debugPrint('[$label] created draw instanceId=${ad.instanceId}');
      ad.load();
    });
  }

  void _destroyAll() {
    for (final ad in _drawAds.values) {
      ad.destroy();
    }
    _drawAds.clear();
    _adIdsByLabel['A'] = [];
    _adIdsByLabel['B'] = [];
    _adIdToLabel.clear();
    _pendingBAdIds = [];
    setState(() {
      mergedFeedList.removeWhere((item) => item.type == FeedItemType.ad);
    });
  }

  void _startSequentialTest() {
    _destroyAll();
    _sequentialMode = true;
    _createInstance('A', adCount: 1);
    _createInstance('B', adCount: 1);
  }

  int get totalItemCount => mergedFeedList.length;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: totalItemCount,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              if (index >= mergedFeedList.length) {
                return Container(
                  color: const Color(0xFF121212),
                  child: const Center(
                    child: Text(
                      "列表已到末尾",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }

              final currentItem = mergedFeedList[index];

              if (currentItem.type == FeedItemType.ad) {
                final adId = currentItem.data;
                final label = _adIdToLabel[adId] ?? '?';
                final drawAd = _drawAds[label];
                debugPrint("插入广告: PageView Index=$index, AdId=$adId, label=$label");
                if (drawAd != null) {
                  return Container(
                    width: screenSize.width,
                    height: screenSize.height,
                    color: const Color(0xFF121212),
                    child: Stack(
                      children: [
                        DrawWidget(
                          drawAd,
                          mVideoPlayerCallBack: _videoListenerFor(label),
                          key: ValueKey(adId),
                          adId: adId,
                        ),
                        Positioned(
                          top: 40,
                          left: 20,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(6),
                            child: Text(
                              '实例[$label] $adId',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  width: screenSize.width,
                  height: screenSize.height,
                  color: const Color(0xFF121212),
                  child: const Center(
                    child: Text(
                      "广告加载中...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }

              return SizedBox(
                width: screenSize.width,
                height: screenSize.height,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/video_bg.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black87,
                              Colors.black54,
                              Colors.black38,
                              Colors.black12,
                              Colors.black12,
                              Colors.black38,
                              Colors.black54,
                              Colors.black87,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: screenSize.height * 0.2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentItem.title ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentItem.description ?? "",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: Text(
                        '#${index.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
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
            ),
          ),
        ],
      ),
    );
  }
}
