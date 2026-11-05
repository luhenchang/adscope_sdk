import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/services.dart';

import '../common.dart';
import '../data/amps_mall_parameters.dart';
import 'reward_video_callback_router.dart';

class AMPSRewardVideoAd {
  static int _instanceCounter = 0;
  final String instanceId;
  AdOptions config;
  RewardVideoCallBack? adCallBack;
  late final Future<PlatformException?> _creation;
  bool _isDestroyed = false;

  AMPSRewardVideoAd({required this.config, this.adCallBack, String? instanceId})
      : instanceId = instanceId ?? _generateInstanceId() {
    // 先合并原有 name/value 项，再用显式任务字段覆盖同名项。
    // 在注册回调前校验配置，避免无效 JSON 导致路由残留。
    final userData =
        config.mallReward?.toUserData() == null ? null : mallUserData(config);
    final arguments = _wrapArgs({
      ...config.toMap(),
      if (userData != null) 'gmMallRewardUserData': userData,
    });
    RewardVideoCallbackRouter.instance.register(this.instanceId, adCallBack);
    // 构造器不能 await；将创建错误保存到加载流程，避免未处理的平台异常。
    _creation = AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.rewardVideoCreate,
      arguments,
    ).then<PlatformException?>((_) => null, onError: (Object error) {
      return error is PlatformException
          ? error
          : PlatformException(code: 'CREATE_FAILED', message: error.toString());
    });
  }

  static String _generateInstanceId() {
    _instanceCounter += 1;
    return 'reward_${_instanceCounter}_${DateTime.now().microsecondsSinceEpoch}';
  }

  Map<String, dynamic> _wrapArgs(Map<dynamic, dynamic> args) {
    return {
      AMPSAdInstanceKey.adInstanceId: instanceId,
      ...args,
    };
  }

  Map<String, dynamic> _instanceOnlyArgs() {
    return {AMPSAdInstanceKey.adInstanceId: instanceId};
  }

  ///激励服务回调参数，整体覆盖 extraDataMap
  void setExtraDataMap(Map<String, dynamic>? extraDataMap) {
    AdscopeSdk.invokeMethod(
      AMPSAdSdkMethodNames.rewardVideoSetExtraDataMap,
      {
        ..._instanceOnlyArgs(),
        'extraDataMap': extraDataMap,
      },
    );
  }

  Future<bool> _ensureCreated() async {
    final error = await _creation;
    if (_isDestroyed) return false;
    if (error == null) return true;
    final onFailure = adCallBack?.onLoadFailure;
    if (onFailure == null) throw error;
    onFailure(int.tryParse(error.code) ?? -1,
        '${error.code}: ${error.message ?? "Reward ad creation failed"}');
    return false;
  }

  /// 等待创建后发起加载；Future 表示平台调用完成，加载结果通过回调报告。
  /// 创建失败时调用 onLoadFailure；未提供此回调时 Future 抛出平台异常。
  Future<void> load() async {
    if (!await _ensureCreated()) return;
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoLoad, _instanceOnlyArgs());
  }

  /// 等待创建后发起预加载，错误处理与 load 相同。
  Future<void> preLoad() async {
    if (!await _ensureCreated()) return;
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoPreLoad, _instanceOnlyArgs());
  }

  ///激励视频广告显示调用
  Future<void> showAd() async {
    final shown = await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoShowAd, _instanceOnlyArgs());
    if (shown == false) {
      throw PlatformException(
        code: 'SHOW_FAILED',
        message: 'Reward ad instance or owning view controller is unavailable',
      );
    }
  }

  ///激励视频广告是否有预加载
  Future<bool> isReadyAd() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoIsReadyAd, _instanceOnlyArgs());
  }

  ///销毁视频广告
  Future<void> destroy() async {
    if (_isDestroyed) return;
    _isDestroyed = true;
    RewardVideoCallbackRouter.instance.unregister(instanceId);
    await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoDestroyAd, _instanceOnlyArgs());
  }

  ///获取ecpm
  Future<num> getECPM() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoGetECPM, _instanceOnlyArgs());
  }

  ///获取胜出渠道的seatId
  Future<String?> getSeatId() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoGetSeatId, _instanceOnlyArgs());
  }

  ///添加预加载广告
  addPreLoadAdInfo() async {
    AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoAddPreLoadAdInfo, _instanceOnlyArgs());
  }

  ///获取MediaExtraInfo
  Future<dynamic> addPreGetMediaExtraInfo() async {
    return await AdscopeSdk.invokeMethod(
        AMPSAdSdkMethodNames.rewardVideoGetMediaExtraInfo, _instanceOnlyArgs());
  }
}
