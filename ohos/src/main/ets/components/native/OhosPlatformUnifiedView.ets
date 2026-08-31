import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AD_ID, AD_INSTANCE_ID } from '../common/common';
import { AMPSUnifiedAdComponent } from './AMPSUnifiedAdComponent';
import { NativeUnifiedModule } from '../native/UnifiedNativeModule';

@Observed
export class OhosPlatformUnifiedView extends PlatformView {
  private static reloaders: Map<string, () => void> = new Map()
  adId: string = ''
  instanceId: string = ''
  nativeUnifiedModule?: NativeUnifiedModule = undefined

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    this.adId = (args.get(AD_ID) as string | undefined) ?? ''
    this.instanceId = (args.get(AD_INSTANCE_ID) as string | undefined) ?? ''
    const unifiedWidget = args.get('unifiedWidget') as Map<string, Object> | undefined
    if (unifiedWidget) {
      this.nativeUnifiedModule = new NativeUnifiedModule(unifiedWidget)
    }
  }

  static register(adId: string, reloader: () => void): void {
    if (adId) {
      OhosPlatformUnifiedView.reloaders.set(adId, reloader)
    }
  }

  static unregister(adId: string): void {
    if (adId) {
      OhosPlatformUnifiedView.reloaders.delete(adId)
    }
  }

  static refresh(adId: string): void {
    OhosPlatformUnifiedView.reloaders.get(adId)?.()
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSUnifiedWrappedBuilder);
  }

  dispose(): void {
    OhosPlatformUnifiedView.unregister(this.adId)
  }
}

@Builder
export function AMPSUnifiedWrappedBuilder(params: Params) {
  AMPSUnifiedAdComponent({
    params: params,
    adId: (params.platformView as OhosPlatformUnifiedView).adId,
    unifiedModule: (params.platformView as OhosPlatformUnifiedView).nativeUnifiedModule
  })
}
