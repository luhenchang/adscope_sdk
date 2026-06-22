import 'dart:io';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

class RewardVideoPage extends StatefulWidget {
  const RewardVideoPage({super.key, required this.title});

  final String title;

  @override
  State<RewardVideoPage> createState() => _RewardVideoPageState();
}

// 2. 需要给渠道氮素设置时候再选择渠道设置。
//     Map<String, dynamic>? extraDataMap;
//     if (Platform.isAndroid) {
//       extraDataMap = <String, String>{
//         AmpsAndroidConstants.ampsAdnCsj: '{"name":"csj_data"}',
//         AmpsAndroidConstants.ampsAdnGm: '{"name":"gm_data"}',
//         AmpsAndroidConstants.ampsAdnKs: '{"name":"ks_data"}',
//         AmpsAndroidConstants.ampsAdnBd: '{"name":"bd_data"}',
//         AmpsAndroidConstants.ampsAdnGdt: '{"name":"gdt_data"}',
//       };
//     } else if (Platform.isIOS) {
//       extraDataMap = {
//         AmpsIosConstants.ampsAdnGdt: {
//           "userID": "111",
//           "extra": '{"orderId":"order001"}',
//         },
//         AmpsIosConstants.ampsAdnKs: {
//           "userID": "222",
//           "extra": '{"orderId":"order001"}',
//         },
//         AmpsIosConstants.ampsAdnCsj: {
//           "userID": "333",
//           "extra": '{"orderId":"order001"}',
//         },
//         AmpsIosConstants.ampsAdnGm: {
//           "userID": "444",
//           "extra": '{"orderId":"order001"}',
//         },
//         AmpsIosConstants.ampsAdnBd: {
//           "userID": "555",
//           "extra": '{"orderId":"order001"}',
//         },
//       };
//     }
// 鸿蒙跟iOS一样
class _RewardVideoPageState extends State<RewardVideoPage> {
  final Map<String, AMPSRewardVideoAd> _rewardAds = {};
  bool couldBack = true;
  bool _bLoaded = false;
  bool _pendingShowB = false;

  RewardVideoCallBack _callbackFor(String label) {
    return RewardVideoCallBack(
      onLoadSuccess: () async {
        final ad = _rewardAds[label];
        debugPrint('[$label] reward onLoadSuccess id=${ad?.instanceId}');
        final seatId = await ad?.getSeatId();
        debugPrint('[$label] reward seatId=$seatId');
        if (label == 'A') {
          ad?.showAd();
          setState(() => couldBack = false);
        } else if (label == 'B') {
          _bLoaded = true;
          if (_pendingShowB) {
            _pendingShowB = false;
            ad?.showAd();
          }
        }
      },
      onLoadFailure: (code, msg) {
        debugPrint('[$label] reward failure=$code;$msg');
      },
      onAdClicked: () {
        setState(() => couldBack = true);
        debugPrint('[$label] reward onAdClicked');
      },
      onAdClosed: () {
        setState(() => couldBack = true);
        debugPrint('[$label] reward onAdClosed');
        if (label == 'A') {
          final b = _rewardAds['B'];
          if (b != null) {
            if (_bLoaded) {
              b.showAd();
            } else {
              _pendingShowB = true;
            }
          }
        }
      },
      onAdReward: () => debugPrint('[$label] reward onAdReward'),
      onAdShow: () => debugPrint('[$label] reward onAdShow'),
      onVideoPlayStart: () => debugPrint('[$label] reward onVideoPlayStart'),
      onVideoPlayEnd: () => debugPrint('[$label] reward onVideoPlayEnd'),
      onVideoSkipToEnd: (duration) {
        debugPrint('[$label] reward onVideoSkipToEnd=$duration');
      },
      onServerRewardFailed: (code, msg) {
        debugPrint('[$label] reward onServerRewardFailed=$code;$msg');
      },
    );
  }

  AdOptions _buildOptions() {
    const data = 'xxxxxx';
    const useId = 'xxxxx';
    if (Platform.isAndroid) {
      return AdOptions(
        spaceId: rewardVideoSpaceId,
        extraDataMap: <String, String>{'adn_amps': data},
      );
    }
    if (Platform.isIOS) {
      return AdOptions(spaceId: rewardVideoSpaceId, extra: data, userId: useId);
    }
    return AdOptions(spaceId: rewardVideoSpaceId);
  }

  void _createInstance(String label) {
    final ad = AMPSRewardVideoAd(
      config: _buildOptions(),
      adCallBack: _callbackFor(label),
    );
    _rewardAds[label] = ad;
    debugPrint('[$label] created reward instanceId=${ad.instanceId}');
    ad.load();
  }

  void _destroyAll() {
    for (final ad in _rewardAds.values) {
      ad.destroy();
    }
    _rewardAds.clear();
    _bLoaded = false;
    _pendingShowB = false;
  }

  void _startSequentialTest() {
    _destroyAll();
    _createInstance('A');
    _createInstance('B');
  }

  @override
  void dispose() {
    _destroyAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: couldBack,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            const BlurredBackground(),
            Column(
              children: [
                const SizedBox(height: 100, width: 0),
                ButtonWidget(
                  buttonText: '同时创建A、B（A关闭后展示B）',
                  callBack: _startSequentialTest,
                ),
                ButtonWidget(
                  buttonText: '创建实例A并加载激励',
                  callBack: () => _createInstance('A'),
                ),
                ButtonWidget(
                  buttonText: '创建实例B并加载激励',
                  callBack: () => _createInstance('B'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
