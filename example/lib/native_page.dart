import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class NativePage extends StatefulWidget {
  const NativePage({super.key, required this.title});

  final String title;

  @override
  State<NativePage> createState() => _SplashPageState();
}

class _SplashPageState extends State<NativePage> {
  late AMPSNativeAdListener _adCallBack;
  late AMPSNativeRenderListener _renderCallBack;
  late AmpsNativeInteractiveListener _interactiveCallBack;
  late AmpsVideoPlayListener _videoPlayerCallBack;
  AMPSNativeAd? _nativeAd;
  List<String> feedList = [];
  List<String> feedAdList = [];
  late double expressWidth = 350;
  late double expressHeight = 128;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 30; i++) {
      feedList.add("item name =$i");
    }
    setState(() {});
    _adCallBack = AMPSNativeAdListener(
        loadOk: (adIds) {
        },
        loadFail: (code, message) => {

        });

    _renderCallBack = AMPSNativeRenderListener(renderSuccess: (adId) {
      setState(() {
       _nativeAd?.isNativeExpress(adId).then((isNativeExpress){
         debugPrint("isNativeExpress=$isNativeExpress");
       });
       _nativeAd?.getVideoDuration(adId).then((duration){
         debugPrint("getVideoDuration=$duration");
       });
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
    }, onVideoPlayError: (adId ,code, message) {
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

    AdOptions options = AdOptions(
        spaceId: nativeSpaceId,
        adCount: 2,
        expressSize: [expressWidth, expressHeight]
    );
    _nativeAd = AMPSNativeAd(
        config: options,
        mCallBack: _adCallBack,
        mRenderCallBack: _renderCallBack,
        mInteractiveCallBack: _interactiveCallBack,
        mVideoPlayerCallBack: _videoPlayerCallBack);
    _nativeAd?.setVideoPlayConfig(
        const AMPSAdVideoPlayConfig(
          videoSoundEnable: true, // 启用声音
          videoAutoPlayType: 3, // 设置自动播放类型
          videoLoopReplay: true, // 启用循环播放
        ));
    _nativeAd?.load();
  }
  @override
  void dispose() {
    debugPrint("页面关闭完成");
    super.dispose();
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
              return NativeWidget(_nativeAd,
                  key: ValueKey(adId),
                  adId: adId);
            }
            return Center(
              child:Column(
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
                  ),
                ],
              )
            );
          },
        ));
  }
}
