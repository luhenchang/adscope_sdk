import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AD_ID, AD_INSTANCE_ID } from '../common/common';
import { AMPSUnifiedAdComponent } from './AMPSUnifiedAdComponent';
import { NativeUnifiedModule } from '../native/UnifiedNativeModule';
import { AMPSEventManager } from '../common/AMPSEventManager';

@Observed
export class OhosPlatformUnifiedView extends PlatformView {
  adId: string = ''
  instanceId: string = ''
  engine: AMPSEventManager
  nativeUnifiedModule?: NativeUnifiedModule = undefined

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger,
    engine: AMPSEventManager) {
    super();
    this.engine = engine
    this.adId = (args.get(AD_ID) as string | undefined) ?? ''
    this.instanceId = (args.get(AD_INSTANCE_ID) as string | undefined) ?? ''
    const unifiedWidget = args.get('unifiedWidget') as Map<string, Object> | undefined
    if (unifiedWidget) {
      this.nativeUnifiedModule = new NativeUnifiedModule(unifiedWidget)
    }
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSUnifiedWrappedBuilder);
  }

  dispose(): void {
    this.engine.native.unregisterReloader(this.adId)
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
