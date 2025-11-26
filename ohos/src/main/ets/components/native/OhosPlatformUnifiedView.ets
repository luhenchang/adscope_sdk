import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AMPSUnifiedAdComponent } from './AMPSUnifiedAdComponent';
import { NativeUnifiedModule } from '../native/UnifiedNativeModule';

@Observed
export class OhosPlatformUnifiedView extends PlatformView {
  static adId: string | undefined;
  static nativeUnifiedModule: NativeUnifiedModule | undefined;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    OhosPlatformUnifiedView.adId = args.get("adId");
    OhosPlatformUnifiedView.nativeUnifiedModule = new NativeUnifiedModule(args.get("unifiedWidget"));
  }


  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSUnifiedWrappedBuilder);
  }

  dispose(): void {
  }
}


@Builder
export function AMPSUnifiedWrappedBuilder(params: Params) {
  AMPSUnifiedAdComponent({
    params: params,
    adId: OhosPlatformUnifiedView.adId,
    unifiedModule: OhosPlatformUnifiedView.nativeUnifiedModule
  })
}
