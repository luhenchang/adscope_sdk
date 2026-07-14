import 'dart:async';

import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'exception_test_models.dart';
import 'native_callback_simulator.dart';

/// 异常测试用例注册表：所有用例预置于此，页面一键运行，无需手写代码。
class ExceptionTestRegistry {
  ExceptionTestRegistry._();

  static List<ExceptionTestGroup> build() {
    return [
      ExceptionTestGroup(
        title: 'A · 通道层兜底（Dart→原生）',
        subtitle: '使用不存在的实例 id 直连原生方法，验证 5s 内必有 PlatformException 而非挂起',
        icon: Icons.cable_rounded,
        cases: _buildChannelCases(),
      ),
      ExceptionTestGroup(
        title: 'B · 真实失败回调（原生→Flutter）',
        subtitle: '使用无效广告位真实加载，验证 onLoadFailure/loadFail 必达',
        icon: Icons.cloud_off_rounded,
        cases: _buildRealFailureCases(),
      ),
      ExceptionTestGroup(
        title: 'C · 安全默认值（实例销毁后查询）',
        subtitle: 'destroy 后调用查询类接口，验证返回 false/0/null 而非抛错或挂起',
        icon: Icons.shield_moon_rounded,
        cases: _buildSafeDefaultCases(),
      ),
      ExceptionTestGroup(
        title: 'D · 畸形回调参数注入（模拟原生）',
        subtitle: '向通道注入 code=null/"abc"/浮点、message=null、非 Map 参数，验证回调不丢、值已兜底',
        icon: Icons.bug_report_rounded,
        cases: _buildInjectionCases(),
      ),
    ];
  }

  // ---------------- A 组：通道层兜底 ----------------

  static List<ExceptionTestCase> _buildChannelCases() {
    Map<String, dynamic> fakeAd() =>
        {AMPSAdInstanceKey.adInstanceId: kExcFakeInstanceId};
    Map<String, dynamic> fakeSplash() =>
        {AMPSSplashInstanceKey.splashInstanceId: kExcFakeInstanceId};
    Map<String, dynamic> fakeNative() => {
          AMPSAdInstanceKey.adInstanceId: kExcFakeInstanceId,
          adNativeType: 0,
          adAdId: 'exc_no_such_ad',
        };

    final cases = <ExceptionTestCase>[
      _channelCase('A01', '开屏 load（实例不存在）',
          AMPSAdSdkMethodNames.splashLoad, fakeSplash()),
      _channelCase('A02', '开屏 showAd（实例不存在）',
          AMPSAdSdkMethodNames.splashShowAd, fakeSplash()),
      _channelCase('A03', '开屏 isReadyAd（实例不存在）',
          AMPSAdSdkMethodNames.splashIsReadyAd, fakeSplash()),
      _channelCase('A04', '开屏 getECPM（实例不存在）',
          AMPSAdSdkMethodNames.splashGetECPM, fakeSplash()),
      _channelCase('A05', '开屏 load（缺少 splashInstanceId）',
          AMPSAdSdkMethodNames.splashLoad, <String, dynamic>{}),
      _channelCase('A06', '插屏 load（实例不存在）',
          AMPSAdSdkMethodNames.interstitialLoad, fakeAd()),
      _channelCase('A07', '插屏 showAd（实例不存在）',
          AMPSAdSdkMethodNames.interstitialShowAd, fakeAd()),
      _channelCase('A08', '插屏 isReadyAd（实例不存在）',
          AMPSAdSdkMethodNames.interstitialIsReadyAd, fakeAd()),
      _channelCase('A09', '插屏 getECPM（实例不存在）',
          AMPSAdSdkMethodNames.interstitialGetEcpm, fakeAd()),
      _channelCase('A10', '激励视频 load（实例不存在）',
          AMPSAdSdkMethodNames.rewardVideoLoad, fakeAd()),
      _channelCase('A11', '激励视频 showAd（实例不存在）',
          AMPSAdSdkMethodNames.rewardVideoShowAd, fakeAd()),
      _channelCase('A12', '激励视频 isReadyAd（实例不存在）',
          AMPSAdSdkMethodNames.rewardVideoIsReadyAd, fakeAd()),
      _channelCase('A13', '激励视频 getECPM（实例不存在）',
          AMPSAdSdkMethodNames.rewardVideoGetECPM, fakeAd()),
      _channelCase('A14', 'Banner load（实例不存在）',
          AMPSAdSdkMethodNames.bannerLoad, fakeAd()),
      _channelCase('A15', 'Banner isReadyAd（实例不存在）',
          AMPSAdSdkMethodNames.bannerIsReadyAd, fakeAd()),
      _channelCase('A16', 'Banner getECPM（实例不存在）',
          AMPSAdSdkMethodNames.bannerGetECPM, fakeAd()),
      _channelCase('A17', '原生 load（实例不存在）',
          AMPSAdSdkMethodNames.nativeLoad, fakeNative()),
      _channelCase('A18', '原生 isReadyAd（实例不存在）',
          AMPSAdSdkMethodNames.nativeIsReadyAd, fakeNative()),
      _channelCase('A19', '原生 getECPM（实例不存在）',
          AMPSAdSdkMethodNames.nativeGetECPM, fakeNative()),
      _channelCase('A20', 'Draw load（实例不存在）',
          AMPSAdSdkMethodNames.drawLoad, fakeAd()),
      _channelCase('A21', 'Draw isReadyAd（实例不存在）',
          AMPSAdSdkMethodNames.drawIsReadyAd,
          {...fakeAd(), adAdId: 'exc_no_such_ad'}),
      _channelCase('A22', 'Draw getEcpm（实例不存在）',
          AMPSAdSdkMethodNames.drawGetEcpm,
          {...fakeAd(), adAdId: 'exc_no_such_ad'}),
    ];

    cases.add(ExceptionTestCase(
      id: 'A23',
      name: '调用不存在的方法名',
      position: '通道层 Dart→原生 · AMPSNoSuchMethod_test',
      expectation: '抛出 MissingPluginException（原生 notImplemented）',
      run: (log) async {
        try {
          final r = await AdscopeSdk.invokeMethod<dynamic>(
                  'AMPSNoSuchMethod_test', <String, dynamic>{})
              .timeout(kExcChannelTimeout);
          return ExceptionTestOutcome.warning('未知方法竟然返回了 $r');
        } on TimeoutException {
          return ExceptionTestOutcome.failed(
              '${kExcChannelTimeout.inSeconds}s 无响应：未知方法未走 notImplemented');
        } on MissingPluginException {
          log('捕获 MissingPluginException');
          return ExceptionTestOutcome.passed('收到 MissingPluginException');
        } on PlatformException catch (e) {
          log('捕获 PlatformException code=${e.code}');
          return ExceptionTestOutcome.passed('收到 PlatformException(${e.code})');
        }
      },
    ));
    return cases;
  }

  static ExceptionTestCase _channelCase(
      String id, String name, String method, dynamic args) {
    return ExceptionTestCase(
      id: id,
      name: name,
      position: '通道层 Dart→原生 · $method',
      expectation:
          '${kExcChannelTimeout.inSeconds}s 内抛出 PlatformException（不挂起、不静默）',
      run: (log) async {
        log('invokeMethod("$method")，参数: $args');
        try {
          final dynamic result = await AdscopeSdk.invokeMethod<dynamic>(
                  method, args)
              .timeout(kExcChannelTimeout);
          log('原生正常返回: $result');
          return ExceptionTestOutcome.warning(
              '未抛 PlatformException，原生直接返回 $result（请确认该路径是否应报错）');
        } on TimeoutException {
          return ExceptionTestOutcome.failed(
              '${kExcChannelTimeout.inSeconds}s 无响应：原生未调用 result，Future 挂起');
        } on PlatformException catch (e) {
          log('捕获 PlatformException code=${e.code} message=${e.message}');
          return ExceptionTestOutcome.passed(
              '收到 PlatformException(${e.code}: ${e.message})');
        } on MissingPluginException {
          return ExceptionTestOutcome.warning(
              '方法未实现（MissingPluginException），当前平台可能未提供该方法');
        }
      },
    );
  }

  // ---------------- B 组：真实失败回调 ----------------

  static List<ExceptionTestCase> _buildRealFailureCases() {
    return [
      ExceptionTestCase(
        id: 'B01',
        name: '开屏加载失败回调必达',
        position: '开屏 · 无效广告位 $kExcInvalidSpaceId · load',
        expectation:
            '${kExcLoadCallbackTimeout.inSeconds}s 内收到 onLoadFailure(code, message)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSSplashAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(
              onLoadSuccess: () => waiter.complete('意外 onLoadSuccess'),
              onLoadFailure: (code, msg) {
                log('onLoadFailure(code=$code, message=$msg)');
                waiter.complete('onLoadFailure(code=$code)');
              },
            ),
          );
          ad.load();
          final r = await waiter.wait(kExcLoadCallbackTimeout);
          await ad.destroy();
          return _judgeLoadResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B02',
        name: '插屏加载失败回调必达',
        position: '插屏 · 无效广告位 $kExcInvalidSpaceId · load',
        expectation:
            '${kExcLoadCallbackTimeout.inSeconds}s 内收到 onLoadFailure(code, message)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSInterstitialAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(
              onLoadSuccess: () => waiter.complete('意外 onLoadSuccess'),
              onLoadFailure: (code, msg) {
                log('onLoadFailure(code=$code, message=$msg)');
                waiter.complete('onLoadFailure(code=$code)');
              },
            ),
          );
          ad.load();
          final r = await waiter.wait(kExcLoadCallbackTimeout);
          await ad.destroy();
          return _judgeLoadResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B03',
        name: '激励视频加载失败回调必达',
        position: '激励视频 · 无效广告位 $kExcInvalidSpaceId · load',
        expectation:
            '${kExcLoadCallbackTimeout.inSeconds}s 内收到 onLoadFailure(code, message)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSRewardVideoAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            adCallBack: RewardVideoCallBack(
              onLoadSuccess: () => waiter.complete('意外 onLoadSuccess'),
              onLoadFailure: (code, msg) {
                log('onLoadFailure(code=$code, message=$msg)');
                waiter.complete('onLoadFailure(code=$code)');
              },
            ),
          );
          ad.load();
          final r = await waiter.wait(kExcLoadCallbackTimeout);
          await ad.destroy();
          return _judgeLoadResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B04',
        name: 'Banner加载失败回调必达',
        position: 'Banner · 无效广告位 $kExcInvalidSpaceId · load',
        expectation:
            '${kExcLoadCallbackTimeout.inSeconds}s 内收到 onLoadFailure(code, message)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSBannerAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, expressSize: [360, 60]),
            mCallBack: BannerCallBack(
              onLoadSuccess: () => waiter.complete('意外 onLoadSuccess'),
              onLoadFailure: (code, msg) {
                log('onLoadFailure(code=$code, message=$msg)');
                waiter.complete('onLoadFailure(code=$code)');
              },
            ),
          );
          ad.load();
          final r = await waiter.wait(kExcLoadCallbackTimeout);
          await ad.destroy();
          return _judgeLoadResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B05',
        name: '原生广告加载失败回调必达',
        position: '原生 · 无效广告位 $kExcInvalidSpaceId · load',
        expectation:
            '${kExcLoadCallbackTimeout.inSeconds}s 内收到 loadFail(code, message)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSNativeAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1),
            mCallBack: AMPSNativeAdListener(
              loadOk: (ads) => waiter.complete('意外 loadOk(${ads.length}条)'),
              loadFail: (code, msg) {
                log('loadFail(code=$code, message=$msg)');
                waiter.complete('loadFail(code=$code)');
              },
            ),
          );
          ad.load();
          final r = await waiter.wait(kExcLoadCallbackTimeout);
          await ad.destroy();
          return _judgeLoadResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B06',
        name: 'Draw加载失败回调必达',
        position: 'Draw · 无效广告位 $kExcInvalidSpaceId · load',
        expectation:
            '${kExcLoadCallbackTimeout.inSeconds}s 内收到 loadFail(code, message)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSDrawAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1),
            mCallBack: AMPSDrawAdListener(
              loadOk: (ads) => waiter.complete('意外 loadOk(${ads.length}条)'),
              loadFail: (code, msg) {
                log('loadFail(code=$code, message=$msg)');
                waiter.complete('loadFail(code=$code)');
              },
            ),
          );
          ad.load();
          final r = await waiter.wait(kExcLoadCallbackTimeout);
          ad.destroy();
          return _judgeLoadResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B07',
        name: '开屏未加载直接 show',
        position: '开屏 · create 后未 load 直接 showAd',
        expectation: '收到 onAdShowError（原生若静默忽略则标记警告）',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSSplashAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(
              onAdShowError: (code, msg) {
                log('onAdShowError(code=$code, message=$msg)');
                waiter.complete('onAdShowError(code=$code)');
              },
              onLoadFailure: (code, msg) =>
                  log('onLoadFailure(code=$code, message=$msg)'),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          ad.showAd();
          final r = await waiter.wait(kExcSoftCallbackTimeout);
          await ad.destroy();
          return _judgeSoftShowResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B08',
        name: '插屏未加载直接 show',
        position: '插屏 · create 后未 load 直接 showAd',
        expectation: '收到 onAdShowError（原生若静默忽略则标记警告）',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSInterstitialAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(
              onAdShowError: (code, msg) {
                log('onAdShowError(code=$code, message=$msg)');
                waiter.complete('onAdShowError(code=$code)');
              },
              onLoadFailure: (code, msg) =>
                  log('onLoadFailure(code=$code, message=$msg)'),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          ad.showAd();
          final r = await waiter.wait(kExcSoftCallbackTimeout);
          await ad.destroy();
          return _judgeSoftShowResult(r);
        },
      ),
      ExceptionTestCase(
        id: 'B09',
        name: '激励视频未加载直接 show',
        position: '激励视频 · create 后未 load 直接 showAd',
        expectation: '收到 onVideoPlayError（原生若静默忽略则标记警告）',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSRewardVideoAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            adCallBack: RewardVideoCallBack(
              onVideoPlayError: (code, msg) {
                log('onVideoPlayError(code=$code, message=$msg)');
                waiter.complete('onVideoPlayError(code=$code)');
              },
              onLoadFailure: (code, msg) =>
                  log('onLoadFailure(code=$code, message=$msg)'),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          ad.showAd();
          final r = await waiter.wait(kExcSoftCallbackTimeout);
          await ad.destroy();
          return _judgeSoftShowResult(r);
        },
      ),
    ];
  }

  static ExceptionTestOutcome _judgeLoadResult(String? r) {
    if (r == null) {
      return ExceptionTestOutcome.failed(
          '${kExcLoadCallbackTimeout.inSeconds}s 内未收到任何加载回调（错误被吞或原生挂起）');
    }
    if (r.startsWith('意外')) {
      return ExceptionTestOutcome.warning('无效广告位竟然加载成功：$r（请检查广告位配置）');
    }
    return ExceptionTestOutcome.passed('收到失败回调 $r');
  }

  static ExceptionTestOutcome _judgeSoftShowResult(String? r) {
    if (r == null) {
      return ExceptionTestOutcome.warning(
          '未收到 show 错误回调（原生可能静默忽略未加载的 show，请结合原生日志确认）');
    }
    return ExceptionTestOutcome.passed('收到 $r');
  }

  // ---------------- C 组：安全默认值 ----------------

  static List<ExceptionTestCase> _buildSafeDefaultCases() {
    return [
      ExceptionTestCase(
        id: 'C01',
        name: '开屏销毁后查询',
        position: '开屏 · destroy 后 isReadyAd/getECPM/getSeatId',
        expectation: '返回 false / 0 / null，不抛错不挂起',
        run: (log) async {
          final ad = AMPSSplashAd(config: AdOptions(spaceId: kExcInvalidSpaceId));
          await Future.delayed(const Duration(milliseconds: 300));
          await ad.destroy();
          return _checkSafeDefaults(
            log,
            ready: () => ad.isReadyAd(),
            ecpm: () => ad.getECPM(),
            seatId: () => ad.getSeatId(),
          );
        },
      ),
      ExceptionTestCase(
        id: 'C02',
        name: '插屏销毁后查询',
        position: '插屏 · destroy 后 isReadyAd/getECPM/getSeatId',
        expectation: '返回 false / 0 / null，不抛错不挂起',
        run: (log) async {
          final ad =
              AMPSInterstitialAd(config: AdOptions(spaceId: kExcInvalidSpaceId));
          await Future.delayed(const Duration(milliseconds: 300));
          await ad.destroy();
          return _checkSafeDefaults(
            log,
            ready: () => ad.isReadyAd(),
            ecpm: () => ad.getECPM(),
            seatId: () => ad.getSeatId(),
          );
        },
      ),
      ExceptionTestCase(
        id: 'C03',
        name: '激励视频销毁后查询',
        position: '激励视频 · destroy 后 isReadyAd/getECPM/getSeatId',
        expectation: '返回 false / 0 / null，不抛错不挂起',
        run: (log) async {
          final ad =
              AMPSRewardVideoAd(config: AdOptions(spaceId: kExcInvalidSpaceId));
          await Future.delayed(const Duration(milliseconds: 300));
          await ad.destroy();
          return _checkSafeDefaults(
            log,
            ready: () => ad.isReadyAd(),
            ecpm: () => ad.getECPM(),
            seatId: () => ad.getSeatId(),
          );
        },
      ),
      ExceptionTestCase(
        id: 'C04',
        name: 'Banner销毁后查询',
        position: 'Banner · destroy 后 isReadyAd/getECPM/getSeatId',
        expectation: '返回 false / 0 / null，不抛错不挂起',
        run: (log) async {
          final ad = AMPSBannerAd(
              config: AdOptions(spaceId: kExcInvalidSpaceId, expressSize: [360, 60]));
          await Future.delayed(const Duration(milliseconds: 300));
          await ad.destroy();
          return _checkSafeDefaults(
            log,
            ready: () => ad.isReadyAd(),
            ecpm: () => ad.getECPM(),
            seatId: () => ad.getSeatId(),
          );
        },
      ),
      ExceptionTestCase(
        id: 'C05',
        name: '原生广告销毁后查询',
        position: '原生 · destroy 后 isReadyAd/getECPM/getSeatId',
        expectation: '返回 false / 0 / null，不抛错不挂起',
        run: (log) async {
          final ad = AMPSNativeAd(
              config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1));
          await Future.delayed(const Duration(milliseconds: 300));
          await ad.destroy();
          return _checkSafeDefaults(
            log,
            ready: () => ad.isReadyAd('exc_no_such_ad'),
            ecpm: () => ad.getECPM('exc_no_such_ad'),
            seatId: () => ad.getSeatId(),
          );
        },
      ),
      ExceptionTestCase(
        id: 'C06',
        name: 'Draw销毁后查询',
        position: 'Draw · destroy 后 isReadyAd/getECPM/getSeatId',
        expectation: '返回 false / 0 / null，不抛错不挂起',
        run: (log) async {
          final ad =
              AMPSDrawAd(config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1));
          await Future.delayed(const Duration(milliseconds: 300));
          ad.destroy();
          await Future.delayed(const Duration(milliseconds: 300));
          return _checkSafeDefaults(
            log,
            ready: () => ad.isReadyAd('exc_no_such_ad'),
            ecpm: () => ad.getECPM('exc_no_such_ad'),
            seatId: () => ad.getSeatId(),
          );
        },
      ),
    ];
  }

  static Future<ExceptionTestOutcome> _checkSafeDefaults(
    ExceptionTestLog log, {
    required Future<bool> Function() ready,
    required Future<num> Function() ecpm,
    required Future<String?> Function() seatId,
  }) async {
    try {
      final r1 = await ready().timeout(kExcChannelTimeout);
      final r2 = await ecpm().timeout(kExcChannelTimeout);
      final r3 = await seatId().timeout(kExcChannelTimeout);
      log('isReadyAd=$r1, getECPM=$r2, getSeatId=$r3');
      if (r1 == false && r2 == 0 && (r3 == null || r3.isEmpty)) {
        return ExceptionTestOutcome.passed('安全默认值正确：false / 0 / $r3');
      }
      return ExceptionTestOutcome.warning(
          '返回值与预期默认值不一致：ready=$r1 ecpm=$r2 seatId=$r3');
    } on TimeoutException {
      return ExceptionTestOutcome.failed('查询接口挂起：原生未调用 result');
    } catch (e) {
      return ExceptionTestOutcome.failed('查询接口抛出未捕获异常：$e');
    }
  }

  // ---------------- D 组：畸形回调参数注入 ----------------

  static List<ExceptionTestCase> _buildInjectionCases() {
    return [
      ExceptionTestCase(
        id: 'D01',
        name: '开屏 onLoadFailure：code=null',
        position: '回调层 原生→Flutter · Splash_onLoadFailure',
        expectation: '回调送达且 code 被安全转换为 -1',
        run: (log) async {
          const marker = 'EXC注入-开屏-code为null';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSSplashAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(onLoadFailure: (code, msg) {
              log('onLoadFailure(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSSplashAdCallBackChannelMethod.onLoadFailure, {
            AMPSSplashInstanceKey.splashInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: null,
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=-1', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D02',
        name: '开屏 onAdShowError：code="abc"',
        position: '回调层 原生→Flutter · Splash_onAdShowError',
        expectation: '回调送达且非法字符串 code 转换为 -1',
        run: (log) async {
          const marker = 'EXC注入-开屏-code非法字符串';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSSplashAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(onAdShowError: (code, msg) {
              log('onAdShowError(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSSplashAdCallBackChannelMethod.onAdShowError, {
            AMPSSplashInstanceKey.splashInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: 'abc',
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=-1', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D03',
        name: '开屏 onLoadFailure：arguments 非 Map',
        position: '回调层 原生→Flutter · Splash_onLoadFailure',
        expectation: '无法路由到实例但不崩溃、不抛未捕获异常',
        run: (log) async {
          await NativeCallbackSimulator.push(
              AMPSSplashAdCallBackChannelMethod.onLoadFailure, '这不是一个Map参数');
          await Future.delayed(const Duration(milliseconds: 300));
          log('注入完成，应用未崩溃');
          return ExceptionTestOutcome.passed('非 Map 参数被安全忽略，无崩溃、无异常');
        },
      ),
      ExceptionTestCase(
        id: 'D04',
        name: '插屏 onLoadFailure：code="90001"（数字字符串）',
        position: '回调层 原生→Flutter · Interstitial_onLoadFailure',
        expectation: '字符串数字被解析为 90001',
        run: (log) async {
          const marker = 'EXC注入-插屏-code数字字符串';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSInterstitialAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            mCallBack: AdCallBack(onLoadFailure: (code, msg) {
              log('onLoadFailure(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSInterstitialAdCallBackChannelMethod.onLoadFailure, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: '90001',
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=90001', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D05',
        name: '激励视频 onLoadFailure：message=null',
        position: '回调层 原生→Flutter · RewardedVideo_onLoadFailure',
        expectation: "message 被安全转换为 'unknown error'",
        run: (log) async {
          const gateCode = 90003;
          final waiter = CallbackWaiter<String>();
          final ad = AMPSRewardVideoAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            adCallBack: RewardVideoCallBack(onLoadFailure: (code, msg) {
              log('onLoadFailure(code=$code, message=$msg)');
              if (code == gateCode) waiter.complete('message=$msg');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSRewardedVideoCallBackChannelMethod.onLoadFailure, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: gateCode,
            AMPSSdkCallBackErrorKey.message: null,
          });
          return _awaitInjection(
              waiter, 'message=unknown error', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D06',
        name: '激励视频 ServerRewardDidFail：code=90011.7（浮点）',
        position: '回调层 原生→Flutter · RewardedVideo_ServerRewardDidFail',
        expectation: '浮点 code 被截断为 90011',
        run: (log) async {
          const marker = 'EXC注入-激励-code浮点';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSRewardVideoAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            adCallBack: RewardVideoCallBack(onServerRewardFailed: (code, msg) {
              log('onServerRewardFailed(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSRewardedVideoCallBackChannelMethod.onServerRewardDidFail, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: 90011.7,
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=90011', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D07',
        name: '激励视频 onVideoSkipToEnd：playDurationMs=null',
        position: '回调层 原生→Flutter · RewardedVideo_onVideoSkipToEnd',
        expectation: '可空参数透传 null，不崩溃',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSRewardVideoAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId),
            adCallBack: RewardVideoCallBack(onVideoSkipToEnd: (ms) {
              log('onVideoSkipToEnd(playDurationMs=$ms)');
              waiter.complete('ms=$ms');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSRewardedVideoCallBackChannelMethod.onVideoSkipToEnd, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackParamsKey.playDurationMs: null,
          });
          return _awaitInjection(waiter, 'ms=null', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D08',
        name: 'Banner onLoadFailure：code=null',
        position: '回调层 原生→Flutter · Banner_onLoadFailure',
        expectation: '回调送达且 code 被安全转换为 -1',
        run: (log) async {
          const marker = 'EXC注入-Banner-code为null';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSBannerAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, expressSize: [360, 60]),
            mCallBack: BannerCallBack(onLoadFailure: (code, msg) {
              log('onLoadFailure(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSBannerCallBackChannelMethod.onLoadFailure, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: null,
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=-1', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D09',
        name: 'Banner onVideoPlayError：arguments 非 Map',
        position: '回调层 原生→Flutter · Banner_onVideoPlayError',
        expectation: '不崩溃；若恰好可路由则回调收到 (-1, unknown error)',
        run: (log) async {
          final waiter = CallbackWaiter<String>();
          final ad = AMPSBannerAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, expressSize: [360, 60]),
            mCallBack: BannerCallBack(onVideoPlayError: (code, msg) {
              log('onVideoPlayError(code=$code, message=$msg)');
              waiter.complete('code=$code, message=$msg');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSBannerCallBackChannelMethod.onVideoPlayError, '坏参数');
          final r = await waiter.wait(kExcInjectTimeout);
          await ad.destroy();
          if (r == null) {
            return ExceptionTestOutcome.passed(
                '非 Map 参数未导致崩溃（存在多实例时无法路由，属预期防御行为）');
          }
          if (r == 'code=-1, message=unknown error') {
            return ExceptionTestOutcome.passed('回调送达且参数已兜底：$r');
          }
          return ExceptionTestOutcome.failed('收到异常值：$r');
        },
      ),
      ExceptionTestCase(
        id: 'D10',
        name: '原生 loadFail：code="abc"',
        position: '回调层 原生→Flutter · loadFail',
        expectation: '非法字符串 code 转换为 -1，回调不丢',
        run: (log) async {
          const marker = 'EXC注入-原生-code非法字符串';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSNativeAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1),
            mCallBack: AMPSNativeAdListener(loadFail: (code, msg) {
              log('loadFail(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSNativeCallBackChannelMethod.loadFail, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: 'abc',
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=-1', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D11',
        name: '原生 renderFailed：adId=null 且 code=null',
        position: '回调层 原生→Flutter · renderFailed',
        expectation: "adId 兜底为 ''，code 兜底为 -1",
        run: (log) async {
          const marker = 'EXC注入-原生-渲染失败参数缺失';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSNativeAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1),
            mRenderCallBack:
                AMPSNativeRenderListener(renderFailed: (adId, code, msg) {
              log("renderFailed(adId='$adId', code=$code, message=$msg)");
              if (msg == marker) waiter.complete("adId='$adId', code=$code");
            }),
          );
          await NativeCallbackSimulator.push(
              AMPSNativeCallBackChannelMethod.renderFailed, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.adId: null,
            AMPSSdkCallBackErrorKey.code: null,
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, "adId='', code=-1", () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D12',
        name: '原生 onVideoPlayError：extra=null 且 code="xyz"',
        position: '回调层 原生→Flutter · onVideoPlayError（视频组件按 adId 分发）',
        expectation: "code 转换为 -1，extra 兜底为 'unknown error'",
        run: (log) async {
          const injectAdId = 'exc_native_video_ad';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSNativeAd(
              config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1));
          ad.mVideoPlayerCallBackMap[injectAdId] = AmpsVideoPlayListener(
            onVideoPlayError: (adId, code, extra) {
              log("onVideoPlayError(adId='$adId', code=$code, extra=$extra)");
              waiter.complete('code=$code, extra=$extra');
            },
          );
          await NativeCallbackSimulator.push(
              AMPSNativeCallBackChannelMethod.onVideoPlayError, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.adId: injectAdId,
            AMPSSdkCallBackErrorKey.code: 'xyz',
            AMPSSdkCallBackErrorKey.extra: null,
          });
          return _awaitInjection(
              waiter, 'code=-1, extra=unknown error', () => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D13',
        name: 'Draw loadFail：code=null',
        position: '回调层 原生→Flutter · Draw_onLoadFailure',
        expectation: '回调送达且 code 被安全转换为 -1',
        run: (log) async {
          const marker = 'EXC注入-Draw-code为null';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSDrawAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1),
            mCallBack: AMPSDrawAdListener(loadFail: (code, msg) {
              log('loadFail(code=$code, message=$msg)');
              if (msg == marker) waiter.complete('code=$code');
            }),
          );
          await NativeCallbackSimulator.push(
              AmpsDrawCallbackChannelMethod.onLoadFailure, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.code: null,
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(waiter, 'code=-1', () async => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D14',
        name: 'Draw onRenderFail：adId=null',
        position: '回调层 原生→Flutter · Draw_onRenderFail',
        expectation: "adId 兜底为 ''，code 兜底为 -1",
        run: (log) async {
          const marker = 'EXC注入-Draw-渲染失败参数缺失';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSDrawAd(
            config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1),
            mRenderCallBack:
                AMPSDrawRenderListener(renderFailed: (adId, code, msg) {
              log("renderFailed(adId='$adId', code=$code, message=$msg)");
              if (msg == marker) waiter.complete("adId='$adId', code=$code");
            }),
          );
          await NativeCallbackSimulator.push(
              AmpsDrawCallbackChannelMethod.onRenderFail, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.adId: null,
            AMPSSdkCallBackErrorKey.code: null,
            AMPSSdkCallBackErrorKey.message: marker,
          });
          return _awaitInjection(
              waiter, "adId='', code=-1", () async => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D15',
        name: 'Draw onVideoError：code="abc" 且 message=null',
        position: '回调层 原生→Flutter · Draw_onVideoError（视频组件按 adId 分发）',
        expectation: "code 转换为 -1，message 兜底为 'unknown error'",
        run: (log) async {
          const injectAdId = 'exc_draw_video_ad';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSDrawAd(
              config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1));
          ad.mVideoPlayerCallBackMap[injectAdId] = AMPSDrawVideoListener(
            onVideoError: (adId, code, msg) {
              log("onVideoError(adId='$adId', code=$code, message=$msg)");
              waiter.complete('code=$code, message=$msg');
            },
          );
          await NativeCallbackSimulator.push(
              AmpsDrawCallbackChannelMethod.onVideoError, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.adId: injectAdId,
            AMPSSdkCallBackErrorKey.code: 'abc',
            AMPSSdkCallBackErrorKey.message: null,
          });
          return _awaitInjection(
              waiter, 'code=-1, message=unknown error', () async => ad.destroy());
        },
      ),
      ExceptionTestCase(
        id: 'D16',
        name: 'Draw onProgressUpdate：current/duration=null',
        position: '回调层 原生→Flutter · Draw_onProgressUpdate',
        expectation: 'current/duration 兜底为 0，回调不丢',
        run: (log) async {
          const injectAdId = 'exc_draw_progress_ad';
          final waiter = CallbackWaiter<String>();
          final ad = AMPSDrawAd(
              config: AdOptions(spaceId: kExcInvalidSpaceId, adCount: 1));
          ad.mVideoPlayerCallBackMap[injectAdId] = AMPSDrawVideoListener(
            onProgressUpdate: (adId, current, duration) {
              log("onProgressUpdate(adId='$adId', current=$current, duration=$duration)");
              waiter.complete('current=$current, duration=$duration');
            },
          );
          await NativeCallbackSimulator.push(
              AmpsDrawCallbackChannelMethod.onProgressUpdate, {
            AMPSAdInstanceKey.adInstanceId: ad.instanceId,
            AMPSSdkCallBackErrorKey.adId: injectAdId,
            AMPSSdkCallBackErrorKey.current: null,
            AMPSSdkCallBackErrorKey.duration: null,
          });
          return _awaitInjection(
              waiter, 'current=0, duration=0', () async => ad.destroy());
        },
      ),
    ];
  }

  static Future<ExceptionTestOutcome> _awaitInjection(
    CallbackWaiter<String> waiter,
    String expected,
    Future<void> Function() cleanup,
  ) async {
    final r = await waiter.wait(kExcInjectTimeout);
    try {
      await cleanup();
    } catch (_) {}
    if (r == null) {
      return ExceptionTestOutcome.failed(
          '注入后 ${kExcInjectTimeout.inSeconds}s 未收到回调：畸形参数导致回调丢失');
    }
    if (r == expected) {
      return ExceptionTestOutcome.passed('回调送达且已安全转换：$r');
    }
    return ExceptionTestOutcome.failed('收到 $r，预期 $expected');
  }
}
