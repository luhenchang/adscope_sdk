import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

// 1. 定义列表项类型枚举（区分普通内容/广告）
enum FeedItemType { content, ad }

// 2. 定义列表项数据模型
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
  late AMPSDrawAdListener _adCallBack;
  late AMPSDrawRenderListener _renderCallBack;
  late AMPSDrawVideoListener _videoPlayerCallBack;
  AMPSDrawAd? _drawAd;

  List<FeedItem> mergedFeedList = [];
  late PageController _pageController;

  final List<Map<String, String>> _douyinStyleContent = [
    {
      "title": "开屏广告功能集成",
      "description": "支持自定义展示时长、跳过按钮样式，平衡用户体验与广告曝光效率",
      "bgUrl": ""
    },
    {
      "title": "激励视频广告优化",
      "description": "基于用户行为分析的智能展示策略，提升广告转化与用户留存率",
      "bgUrl": ""
    },
    {
      "title": "Banner广告自适应适配",
      "description": "自动适配多屏幕尺寸，简化Flutter/原生多端集成流程",
      "bgUrl": ""
    },
    {
      "title": "原生广告样式定制",
      "description": "支持布局结构、字体样式自定义，贴合App视觉风格与交互逻辑",
      "bgUrl": ""
    },
    {
      "title": "广告数据统计分析",
      "description": "实时监控曝光、点击、转化数据，助力运营决策与效果优化",
      "bgUrl": ""
    },
    {
      "title": "跨平台兼容性保障",
      "description": "适配Flutter/Android/iOS/HarmonyOS，保障多端一致展示效果",
      "bgUrl": ""
    },
    {
      "title": "广告加载性能优化",
      "description": "预加载+缓存机制，降低加载耗时，提升广告展示成功率",
      "bgUrl": ""
    },
    {
      "title": "隐私合规性支持",
      "description": "符合GDPR/CCPA等法规要求，提供用户授权管理与数据加密传输",
      "bgUrl": ""
    },
    {
      "title": "自定义广告触发逻辑",
      "description": "支持基于场景/行为的触发条件配置，提升广告相关性",
      "bgUrl": ""
    },
    {
      "title": "多广告源聚合管理",
      "description": "集成多家广告平台资源，智能选路提升填充率与收益",
      "bgUrl": ""
    }
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

    // 广告回调逻辑（保持不变）
    _adCallBack = AMPSDrawAdListener(
      loadOk: (adIds) {},
      loadFail: (code, message) => {},
    );

    _renderCallBack = AMPSDrawRenderListener(
      onAdShow: (adId) {},
      onAdClick: (adId) {},
      onAdClose: (adId) {},
      renderFailed: (adId, code, message) {},
      renderSuccess: (adId) {
        setState(() {
          debugPrint("adId renderCallBack=$adId");
          bool adExists = mergedFeedList.any(
                (item) => item.type == FeedItemType.ad && item.data == adId,
          );
          if (!adExists) {
            if (mergedFeedList.length > 1) {
              mergedFeedList.insert(
                1,
                FeedItem(type: FeedItemType.ad, data: adId),
              );
            } else {
              mergedFeedList.add(
                FeedItem(type: FeedItemType.ad, data: adId),
              );
            }
          }
        });
      },
    );

    _videoPlayerCallBack = AMPSDrawVideoListener(
      onVideoAdPaused: (adId) => debugPrint("adId video play onVideoAdPaused=$adId"),
      onVideoAdContinuePlay: (adId) => debugPrint("adId video play onVideoAdContinuePlay=$adId"),
      onVideoError: (adId, code, message) {},
      onVideoAdComplete: (adId) => debugPrint("adId video play complete=$adId"),
      onVideoLoad: (adId) {},
      onVideoAdStartPlay: (adId) => debugPrint("adId video play start=$adId"),
      onProgressUpdate: (adId, current, position) => debugPrint("adId video play onProgressUpdate=$current"),
    );


    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final expressWidth = MediaQuery.of(context).size.width;
        final expressHeight = MediaQuery.of(context).size.height;
        AdOptions options = AdOptions(
          spaceId: drawSpaceId,
          adCount: 2,
          expressSize: [expressWidth, expressHeight],
          timeoutInterval: 15000
        );
        _drawAd = AMPSDrawAd(
          config: options,
          mRenderCallBack: _renderCallBack,
          mCallBack: _adCallBack,
        );
        _drawAd?.load();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _drawAd?.resumeAd();
        break;
      case AppLifecycleState.paused:
        _drawAd?.pauseAd();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _drawAd?.destroy();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int get totalItemCount => mergedFeedList.length;

  // 抖音风格加载占位图
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF121212),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // 抖音风格错误占位图
  Widget _buildErrorWidget() {
    return Container(
      color: const Color(0xFF121212),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 全屏尺寸
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // 去掉默认背景和padding，实现沉浸式
      backgroundColor: Colors.black,
      body: PageView.builder(
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

          FeedItem currentItem = mergedFeedList[index];

          if (currentItem.type == FeedItemType.ad) {
            String adId = currentItem.data;
            debugPrint("插入广告: PageView Index=$index, AdId=$adId");
            if (_drawAd != null) {
              return Container(
                width: screenSize.width,
                height: screenSize.height,
                color: const Color(0xFF121212),
                child: DrawWidget(
                  _drawAd,
                  mVideoPlayerCallBack: _videoPlayerCallBack,
                  key: ValueKey(adId),
                  adId: adId,
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

                // 2. 渐变蒙版（抖音经典：上暗下渐变，突出文字）
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

                // 3. 文字内容（抖音风格：居中偏下，层级分明）
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: screenSize.height * 0.2, // 居中偏下（抖音经典位置）
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题（抖音大字体、粗体、白色）
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
                        // 描述（抖音小字体、浅白、轻盈）
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

                // 4. 索引（抖音风格：角落弱化显示）
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
    );
  }
}