
import 'adscope_sdk_platform_interface.dart';

class AdscopeSdk {
  Future<String?> getPlatformVersion() {
    return AdscopeSdkPlatform.instance.getPlatformVersion();
  }
}
