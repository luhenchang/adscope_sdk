import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adscope_sdk_method_channel.dart';

abstract class AdscopeSdkPlatform extends PlatformInterface {
  /// Constructs a AdscopeSdkPlatform.
  AdscopeSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdscopeSdkPlatform _instance = MethodChannelAdscopeSdk();

  /// The default instance of [AdscopeSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdscopeSdk].
  static AdscopeSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdscopeSdkPlatform] when
  /// they register themselves.
  static set instance(AdscopeSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
