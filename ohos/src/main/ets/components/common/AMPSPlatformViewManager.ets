import { FlutterPluginBinding, StandardMessageCodec } from '@ohos/flutter_ohos';
import { AMPSPlatformViewRegistry } from '../common/common';
import { InterstitialFactory } from '../interstitial/InterstitialFactory';
import { NativeFactory } from '../native/NativeFactory';
import { SplashFactory } from '../splash/SplashFactory';
import { UnifiedFactory } from '../native/UnifiedFactory';
import { BannerFactory } from '../banner/BannerFactory';

export class AMPSPlatformViewManager {
  private static sInstance: AMPSPlatformViewManager;

  private AMPSEventManger() {
  }

  static getInstance() {
    if (AMPSPlatformViewManager.sInstance == null) {
      AMPSPlatformViewManager.sInstance = new AMPSPlatformViewManager();
    }
    return AMPSPlatformViewManager.sInstance;
  }

  init(binding: FlutterPluginBinding) {
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkSplashViewId,
      new SplashFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
      new InterstitialFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkNativeViewId,
      new NativeFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
      new UnifiedFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkBannerViewId,
      new BannerFactory(binding.getBinaryMessenger(), StandardMessageCodec.INSTANCE));

  }
}