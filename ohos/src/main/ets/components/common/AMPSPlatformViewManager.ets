import { FlutterPluginBinding, StandardMessageCodec } from '@ohos/flutter_ohos';
import { AMPSPlatformViewRegistry } from '../common/common';
import { InterstitialFactory } from '../interstitial/InterstitialFactory';
import { NativeFactory } from '../native/NativeFactory';
import { SplashFactory } from '../splash/SplashFactory';
import { UnifiedFactory } from '../native/UnifiedFactory';
import { BannerFactory } from '../banner/BannerFactory';
import { DrawFactory } from '../draw/DrawFactory';
import { AMPSEventManager } from './AMPSEventManager';

export class AMPSPlatformViewManager {
  private engine: AMPSEventManager

  constructor(engine: AMPSEventManager) {
    this.engine = engine
  }

  init(binding: FlutterPluginBinding) {
    const messenger = binding.getBinaryMessenger()
    const codec = StandardMessageCodec.INSTANCE
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkSplashViewId,
      new SplashFactory(messenger, codec, this.engine));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkInterstitialViewId,
      new InterstitialFactory(messenger, codec, this.engine));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkNativeViewId,
      new NativeFactory(messenger, codec, this.engine));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkUnifiedViewId,
      new UnifiedFactory(messenger, codec, this.engine));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkBannerViewId,
      new BannerFactory(messenger, codec, this.engine));
    binding.getPlatformViewRegistry().registerViewFactory(AMPSPlatformViewRegistry.ampsSdkDrawViewId,
      new DrawFactory(messenger, codec, this.engine));
  }
}
