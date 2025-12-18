import 'dart:async';
import 'dart:ui';
import 'package:adscope_sdk/adscope_sdk.dart';

import '../common.dart';
import '../data/amps_init_config.dart';
import '../data/amps_sdk_Init_status.dart';
///SDK初始化入口类
class AMPSAdSDK {
  static bool testModel = false;
  AMPSAdSDK._();
  /// 发送数据给native
  static Future<void> init(AMPSInitConfig sdkConfig,AMPSIInitCallBack callBack) async {
    AdscopeSdk.channel.setMethodCallHandler(
          (call) async {
        switch (call.method) {
          case AMPSInitChannelMethod.initSuccess:
            callBack.initSuccess?.call();
            break;
          case AMPSInitChannelMethod.initializing:
            callBack.initializing?.call();
            break;
          case AMPSInitChannelMethod.alreadyInit:
            callBack.alreadyInit?.call();
            break;
          case AMPSInitChannelMethod.initFailed:
            final map = call.arguments as Map<dynamic, dynamic>?;
            final code = map?[AMPSSdkCallBackErrorKey.code];
            final message = map?[AMPSSdkCallBackErrorKey.message];
            callBack.initFailed?.call(code, message);
            break;
        }
      },
    );
    // 使用时
    await AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.init,
      sdkConfig.toMap(AMPSAdSDK.testModel),
    );
  }

  static Future<void> setPersonalRecommend(bool flag) async {
    await AdscopeSdk.channel.invokeMethod(
      AMPSAdSdkMethodNames.setPersonalRecommend,
      flag,
    );
  }

  ///获取SDK版本
  static Future<String> getSdkVersion() async {
    final sdkVersion = await AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.getSdkVersion
    );
    return sdkVersion;
  }

  ///获取SDK状态
  static Future<AMPSSDKInitStatus?> getSdkInitStatus() async {
    final statusCode = await AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.getInitStatus
    );
    return AMPSSDKInitStatus.fromCode(statusCode);
  }
}


typedef InitFailedCallBack = void Function(int? code, String? msg);
/// 1. 定义回调接口（抽象类）
class AMPSIInitCallBack {
  /// 初始化成功的回调
  late final VoidCallback? initSuccess;

  /// 正在初始化的回调
  late final VoidCallback? initializing;

  /// 已经初始化的回调
  late final  VoidCallback? alreadyInit;

  /// 初始化失败的回调
  late final  InitFailedCallBack? initFailed;

  AMPSIInitCallBack({this.initSuccess, this.initializing, this.alreadyInit, this.initFailed});
}