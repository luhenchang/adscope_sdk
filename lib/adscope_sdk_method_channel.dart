import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adscope_sdk_platform_interface.dart';

/// An implementation of [AdscopeSdkPlatform] that uses method channels.
class MethodChannelAdscopeSdk extends AdscopeSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adscope_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
