import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AD_ID, AD_INSTANCE_ID } from '../common/common';
import { AMPSNativeAdComponent } from './AMPSNativeAdComponent';

@Observed
export class OhosPlatformNativeView extends PlatformView {
  adId: string = ''
  instanceId: string = ''

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    this.adId = (args.get(AD_ID) as string | undefined) ?? ''
    this.instanceId = (args.get(AD_INSTANCE_ID) as string | undefined) ?? ''
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSNativeWrappedBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSNativeWrappedBuilder(params: Params) {
  AMPSNativeAdComponent({
    params: params,
    adId: (params.platformView as OhosPlatformNativeView).adId,
    instanceId: (params.platformView as OhosPlatformNativeView).instanceId
  })
}
