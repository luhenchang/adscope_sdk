import 'package:flutter_test/flutter_test.dart';
import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/adscope_sdk_platform_interface.dart';
import 'package:adscope_sdk/adscope_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdscopeSdkPlatform
    with MockPlatformInterfaceMixin
    implements AdscopeSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdscopeSdkPlatform initialPlatform = AdscopeSdkPlatform.instance;

  test('$MethodChannelAdscopeSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdscopeSdk>());
  });

  test('getPlatformVersion', () async {
    AdscopeSdk adscopeSdkPlugin = AdscopeSdk();
    MockAdscopeSdkPlatform fakePlatform = MockAdscopeSdkPlatform();
    AdscopeSdkPlatform.instance = fakePlatform;

    expect(await adscopeSdkPlugin.getPlatformVersion(), '42');
  });
}
