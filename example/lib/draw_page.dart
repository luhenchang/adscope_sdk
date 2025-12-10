import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key, required this.title});

  final String title;

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  late AMPSDrawAdListener _adCallBack;
  late AMPSDrawRenderListener _renderCallBack;
  late AMPSDrawVideoListener _videoPlayerCallBack;
  AMPSDrawAd? _drawAd;

  List<String> feedList = []; // 10条内容
  List<String> feedAdList = []; // 广告ID列表

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    for (var i = 0; i < 10; i++) {
      feedList.add("item name =$i");
    }

    // ... (广告回调和加载逻辑保持不变)
    _adCallBack =
        AMPSDrawAdListener(loadOk: (adIds) {}, loadFail: (code, message) => {});

    _renderCallBack = AMPSDrawRenderListener(
        onAdShow: (adId) {},
        onAdClick: (adId) {},
        onAdClose: (adId) {},
        renderFailed: (adId, code, message) {},
        renderSuccess: (adId) {
          setState(() {
            debugPrint("adId renderCallBack=$adId");
            if (!feedAdList.contains(adId)) {
              feedAdList.add(adId);
            }
          });
        });

    _videoPlayerCallBack = AMPSDrawVideoListener(
        onVideoAdPaused: (adId) {
          debugPrint("adId video play onVideoAdPaused=\$adId");
        },
        onVideoAdContinuePlay: (adId) {
          debugPrint("adId video play onVideoAdContinuePlay=\$adId");
        },
        onVideoError: (adId, code, message) {},
        onVideoAdComplete: (adId) {
          debugPrint("adId video play complete=\$adId");
        },
        onVideoLoad: (adId) {},
        onVideoAdStartPlay: (adId) {
          debugPrint("adId video play start=\$adId");
        },
        onProgressUpdate: (adId, current, position) {
          debugPrint("adId video play onProgressUpdate=\$current");
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final expressWidth = MediaQuery.of(context).size.width;
        final expressHeight = MediaQuery.of(context).size.height;
        AdOptions options = AdOptions(
            spaceId: drawSpaceId,
            adCount: 5,
            expressSize: [expressWidth, expressHeight]);

        _drawAd = AMPSDrawAd(
          config: options,
          mRenderCallBack: _renderCallBack,
          mCallBack: _adCallBack
        );
        _drawAd?.load();
      }
    });
  }

  @override
  void dispose() {
    debugPrint("页面关闭完成");
    _pageController.dispose();
    _drawAd?.destroy();
    super.dispose();
  }

  int get totalItemCount {
    return feedList.length + feedAdList.length;
  }

  bool _isAdPosition(int index) {
    if (index == 1) return true;
    return false;
  }

  int _calculateSkippedAds(int pageViewIndex) {
    int skipped = 0;
    if (pageViewIndex > 1 && _isAdPosition(1)) skipped++;
    return skipped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: totalItemCount,
        physics: const ClampingScrollPhysics(),

        itemBuilder: (BuildContext context, int index) {
          if (_isAdPosition(index)) {
            int adIndex = _calculateSkippedAds(index);
            if (adIndex < feedAdList.length) {
              String adId = feedAdList[adIndex];
              debugPrint("插入广告: PageView Index=$index, Ad Index=$adIndex, AdId=$adId");

              if (_drawAd != null) {
                return DrawWidget(
                  _drawAd,
                  mVideoPlayerCallBack: _videoPlayerCallBack,
                  key: ValueKey(adId),
                  adId: adId,
                );
              }
            }

            return Container(
                color: Colors.black,
                child: const Center(
                    child: Text("广告加载中...",
                        style: TextStyle(color: Colors.white))));
          }

          int skippedAds = _calculateSkippedAds(index);
          int feedIndex = index - skippedAds;
          if (feedIndex >= 0 && feedIndex < feedList.length) {
            // 返回内容组件
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '这是第 ${feedIndex + 1} 条内容',
                      style: const TextStyle(color: Colors.white70, fontSize: 24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Item Index == ${feedIndex.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '(PageView Index: $index)',
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          // 列表末尾的容错处理
          return Container(
            color: Colors.black,
            child: const Center(
                child: Text("列表已到末尾", style: TextStyle(color: Colors.white))),
          );
        },
      ),
    );
  }
}