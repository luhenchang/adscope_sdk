import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
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

    AdOptions options = AdOptions(
        spaceId: nativeSpaceId,
        adCount: 2,
        expressSize: [expressWidth, expressHeight]
    );
    _nativeAd = AMPSNativeAd(
        config: options,
        mCallBack: _adCallBack,
        mRenderCallBack: _renderCallBack);
    _nativeAd?.load();
  }
  @override
  void dispose() {
    debugPrint("页面关闭完成");
    _nativeAd?.destroy();
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
            int adIndex = index ~/ 3;
            int feedIndex = index - adIndex;
            if (index % 3 == 2 && adIndex < feedAdList.length) {
              String adId = feedAdList[adIndex];
              debugPrint(adId);

              return NativeWidget(_nativeAd,
                  mInteractiveCallBack: _interactiveCallBack,
                  key: ValueKey(adId),
                  adId: adId);

            }
            return Center(
              child:Column(
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
              )
            );
          },
        ));
  }
}
