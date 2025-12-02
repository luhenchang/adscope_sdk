

import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk/widget/native_unified_widget.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class NativeUnifiedPage extends StatefulWidget {
  const NativeUnifiedPage({super.key, required this.title});

  final String title;

  @override
  State<NativeUnifiedPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<NativeUnifiedPage> {
  late AmpsNativeAdListener _adCallBack;
  late AMPSNativeRenderListener _renderCallBack;
  late AmpsNativeInteractiveListener _interactiveCallBack;
  late AmpsVideoPlayListener _videoPlayerCallBack;
  late AMPSUnifiedDownloadListener _downloadListener;
  AMPSNativeAd? _nativeAd;
  List<String> feedList = [];
  List<String> feedAdList = [];
  late double expressWidth = 350;
  late double expressHeight = 228;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      feedList.add("item name =$i");
    }
    setState(() {});
    _adCallBack = AmpsNativeAdListener(
        loadOk: (adIds) {}, loadFail: (code, message) => {});

    _renderCallBack = AMPSNativeRenderListener(renderSuccess: (adId) {
      setState(() {
        debugPrint("adId renderCallBack=$adId");
        feedAdList.add(adId);
        _nativeAd?.notifyRTBWin(11, 12, adId);
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
      onDownloadProgressUpdate: (position,adId) {
        debugPrint("下载进度=${position}adId=$adId");
      },
      onDownloadFailed: (adId) {

      },
      onDownloadPaused: (position,adId){

      },
      onDownloadFinished: (adId){

      },
      onDownloadStarted: (adId){

      },
      onInstalled: (adId) {

      }
    );
    AdOptions options = AdOptions(
        spaceId: unifiedSpaceId,
        adCount: 1,
        expressSize: [expressWidth, expressHeight]);
    _nativeAd = AMPSNativeAd(
        config: options,
        nativeType: NativeType.unified,
        mCallBack: _adCallBack,
        mRenderCallBack: _renderCallBack,
        mInteractiveCallBack: _interactiveCallBack,
        mVideoPlayerCallBack: _videoPlayerCallBack);
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
              return UnifiedWidget(
                _nativeAd,
                key: ValueKey(adId),
                adId: adId,
                unifiedContent: NativeUnifiedWidget(
                    height: expressHeight,
                    backgroundColor: '#F0EDF4',
                    children: [
                      UnifiedMainImgWidget(
                          width: expressWidth-40,
                          height: expressHeight-40,
                          x: 20,
                          y: 20,
                          backgroundColor: '#FFFFFF',
                          clickType: AMPSAdItemClickType.click),
                      UnifiedTitleWidget(
                          fontSize: 16,
                          color: "#FFFFFF",
                          x: 5,
                          y: 5,
                          clickType: AMPSAdItemClickType.click),
                      UnifiedDescWidget(
                          fontSize: 16,
                          width: 200,
                          color: "#FFFFFF",
                          x: 5,
                          y: 30),
                      UnifiedActionButtonWidget(
                          fontSize: 12,
                          width: 50,
                          height: 20,
                          fontColor: '#FF00FF',
                          backgroundColor: '#FFFF33',
                          x: expressWidth - 60,
                          y: expressHeight - 20),
                      UnifiedAppIconWidget(
                          width: 25,
                          height: 25,
                          x: 10,
                          y: expressHeight - 25),
                      DownLoadWidget(
                          width: 200,
                          x: 22,
                          y: 60,
                          fontSize: 11,
                          fontColor: "#0000FF",
                          content: "应用名称：${AppDetail.appName} | 开发者：${AppDetail.appDeveloper}",
                              //"| 应用版本：${AppDetail.appVersion} | 权限详情 | 隐私协议 | 功能介绍"
                          downloadListener: _downloadListener
                      ),
                      UnifiedVideoWidget(
                          width: expressWidth-40,
                          height: expressHeight-40,
                          x: 20,
                          y: 20
                      ),
                      UnifiedCloseWidget(
                          imagePath: 'assets/images/close.png',
                          width: 16,
                          height: 16,
                          x: expressWidth-20,
                          y: 5)
                    ]
                ),
              );
            }
          return Column(
                  children: [
                    ButtonWidget(buttonText: "buttonText", callBack: ()=>{
                      _nativeAd?.notifyRTBLoss(2,1,"失败",feedAdList[0])
                    }),
                    Container(
                      height: 128,
                      width: 350,
                      color: Colors.blueAccent,
                      alignment: Alignment.centerLeft,
                      child: Text('List item ${feedList[feedIndex]}'),
                    )
                  ],
                );
          },
        ));
  }
}
