import 'dart:io';

import '../adscope_sdk.dart';
import '../common.dart';
import '../data/amps_log_level.dart';

class SDKLog {
  ///Android日志调试
  static setLogLevel(LogLevel level) {
    if (Platform.isAndroid) {
      AdscopeSdk.channel.invokeMethod(
        AMPSAdSdkMethodNames.setLogLevel,
        level.value,
      );
    }
  }
}
