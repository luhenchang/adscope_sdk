import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

import 'union_download_app_info_page.dart';

class NativeUnifiedPage extends StatefulWidget {
  const NativeUnifiedPage({super.key, required this.title});

  final String title;

  @override
  State<NativeUnifiedPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<NativeUnifiedPage> {
  late AMPSNativeAdListener _adCallBack;
  // late AMPSNegativeFeedbackListener _negativeFeedBackListener;
  late AMPSNativeRenderListener _renderCallBack;
  late AmpsNativeInteractiveListener _interactiveCallBack;
  late AmpsVideoPlayListener _videoPlayerCallBack;
  late AMPSUnifiedDownloadListener _downloadListener;
  AMPSNativeAd? _nativeAd;
  List<String> feedList = [];
  List<String> feedAdList = [];
  late double expressWidth = 350;
  late double expressHeight = 180;
  UnifiedAdDownloadAppInfo? downLoadAppInfo;
  AMPSUnifiedPattern adPattern = AMPSUnifiedPattern.adPatternUnknown;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      feedList.add("item name =$i");
    }
    setState(() {});
    _adCallBack = AMPSNativeAdListener(
        loadOk: (adIds) {},
        loadFail: (code, message) => {debugPrint("自渲染广告加载失败")});

    _renderCallBack = AMPSNativeRenderListener(renderSuccess: (adId) {
      _nativeAd?.getUnifiedPattern(adId).then((pattern){
        setState(() {
          debugPrint("pattern==$pattern");
          adPattern = pattern;
        });
      });
      _nativeAd?.getDownLoadInfo(adId).then((info){
        setState(() {
          downLoadAppInfo = info;
        });
      });
      setState(() {
        debugPrint("adId renderCallBack=$adId");
        feedAdList.add(adId);
      });
    }, renderFailed: (adId, code, message) {
      debugPrint("渲染失败=$code,$message");
    });

    _interactiveCallBack = AmpsNativeInteractiveListener(onAdShow: (adId) {
      debugPrint("广告展示=$adId");
    }, onAdExposure: (adId) {
      debugPrint("广告曝光=$adId");
    }, onAdClicked: (adId) {
      debugPrint("广告点击=$adId");
    }, toCloseAd: (adId) {
      debugPrint("广告关闭=$adId");
      setState(() {
        feedAdList.remove(adId);
      });
    });
    _videoPlayerCallBack = AmpsVideoPlayListener(onVideoPause: (adId) {
      debugPrint("视频暂停");
    }, onVideoPlayError: (adId, code, message) {
      debugPrint("视频播放错误");
    }, onVideoResume: (adId) {
      debugPrint("视频恢复播放");
    }, onVideoReady: (adId) {
      debugPrint("视频准备就绪");
    }, onVideoPlayStart: (adId) {
      debugPrint("视频开始播放");
    }, onVideoPlayComplete: (adId) {
      debugPrint("视频播放完成");
    });
    _downloadListener = AMPSUnifiedDownloadListener(
        onDownloadProgressUpdate: (position, adId) {
          debugPrint("下载进度=${position}adId=$adId");
        },
        onDownloadFailed: (adId) {},
        onDownloadPaused: (position, adId) {},
        onDownloadFinished: (adId) {},
        onDownloadStarted: (adId) {},
        onInstalled: (adId) {});
    AdOptions options = AdOptions(
        spaceId: unifiedSpaceId,
        adCount: 1,
        expressSize: [expressWidth, expressHeight]);
    _nativeAd = AMPSNativeAd(
        config: options,
        nativeType: NativeType.unified,
        mCallBack: _adCallBack,
        mRenderCallBack: _renderCallBack);
    _nativeAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
          itemCount: feedList.length + feedAdList.length, // 列表项总数
          itemBuilder: (BuildContext context, int index) {
            int adIndex = index ~/ 5;
            int feedIndex = index - adIndex;
            if (index % 5 == 4 && adIndex < feedAdList.length) {
              String adId = feedAdList[adIndex];
              debugPrint(adId);
              return SizedBox.fromSize(
                  size: Size(expressWidth, expressHeight),
                  child:Stack(alignment: AlignmentDirectional.center, children: [
                    UnifiedWidget(
                      _nativeAd,
                      mInteractiveCallBack: _interactiveCallBack,
                      mVideoPlayerCallBack: _videoPlayerCallBack,
                      key: ValueKey(adId),
                      adId: adId,
                      unifiedContent: NativeUnifiedWidget(
                          height: expressHeight,
                          backgroundColor: '#80F7FF',
                          children:_getChildrenByType(adPattern.value)),
                      downloadListener: _downloadListener,
                    ),
                    Positioned(
                      top: 8,
                      right: 26,
                      child: InkWell(
                          onTap: () {
                            setState(() {
                              feedAdList.remove(adId);
                            });
                          },
                          borderRadius: BorderRadius.circular(16), // 水波纹圆角
                          child: Image.asset('assets/images/close.png',
                              width: 18, height: 18)),
                    ),
                    if (downLoadAppInfo != null && downLoadAppInfoIsOk(downLoadAppInfo))
                      Positioned(
                        left: 28,
                        top: 100,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                                context, 'UnionDownloadAppInfoPage',
                                arguments: AppInfoArguments(
                                  titleContent: downLoadAppInfo?.appName ?? "",
                                  permissionContent:
                                  downLoadAppInfo?.appPermission ?? "",
                                  privacyContent:
                                  downLoadAppInfo?.appPrivacy ?? "",
                                  introContent: downLoadAppInfo?.appIntro ?? "",
                                ).toMap());
                          },
                          borderRadius: BorderRadius.circular(16), // 水波纹圆角
                          child: Text(
                              "应用名称：${downLoadAppInfo?.appName} | 开发者：${downLoadAppInfo?.appDeveloper}",
                              style: const TextStyle(
                                  color: Colors.blue,
                                  backgroundColor: Colors.white)),
                        ),
                      )
                  ]));
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
        ));
  }
// 根据类型获取对应的子组件列表
  List<LayoutWidget> _getChildrenByType(int type) {
    debugPrint("type=$type");
    switch (type) {
      case 0:
      // 类型0：基础组合（标题 + 图片 + 描述 + 操作按钮）
        return [
          UnifiedTitleWidget(
            fontSize: 18,
            color: "#1D2129",
            x: 2,
            y: 3,
          ),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
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
        ];
      case 1:
      // 类型1：视频组合（标题 + 视频 + 应用图标 + 操作按钮）
        return [
          UnifiedTitleWidget(
            fontSize: 18,
            color: "#1D2129",
            x: 2,
            y: 3,
          ),
          UnifiedVideoWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 30,
          ),
          UnifiedAppIconWidget(
            width: 25,
            height: 25,
            x: 10,
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
        ];
      case 2:
      // 类型2：抖动效果组合（标题 + 图片 + 抖动组件 + 描述）
        return [
          UnifiedTitleWidget(
            fontSize: 18,
            color: "#1D2129",
            x: 2,
            y: 3,
          ),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
          ),
          ShakeWidget(
            width: 100,
            height: 100,
            x: 100,
            y: 50,
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
        ];
      case 3:
      // 类型3：全量组合（所有组件都包含）
        return [
          UnifiedTitleWidget(
            fontSize: 18,
            color: "#1D2129",
            x: 2,
            y: 3,
          ),
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
          UnifiedAppIconWidget(
            width: 25,
            height: 25,
            x: 10,
            y: expressHeight - 30,
          ),
          ShakeWidget(
            width: 100,
            height: 100,
            x: 100,
            y: 50,
          ),
        ];
      default:
      // 默认返回基础组合（类型0）
        return [];
    }
  }

  bool downLoadAppInfoIsOk(UnifiedAdDownloadAppInfo? downLoadAppInfo) {
    if(downLoadAppInfo == null) return false;
    bool result = true;
    if(downLoadAppInfo.appName == null){
      result =  false;
    }
    if(downLoadAppInfo.appPermission == null) {
      result =  false;
    }
    if(downLoadAppInfo.appDeveloper == null) {
      result =  false;
    }
    if(downLoadAppInfo.appVersion == null) {
      result =  false;
    }
    if(downLoadAppInfo.appPrivacy == null) {
      result =  false;
    }
    if(downLoadAppInfo.appIntro == null) {
      result =  false;
    }
    if(downLoadAppInfo.appPackageName == null) {
      result =  false;
    }
    return result;
  }

}
