import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AD_INSTANCE_ID } from '../common/common';
import { AMPSBannerComponent } from './AMPSBannerComponent';

@Observed
export class OhosPlatformBannerView extends PlatformView {
  instanceId: string = ''

  constructor(args: ESObject) {
    super();
    this.instanceId = (args.get(AD_INSTANCE_ID) as string | undefined) ?? ''
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSBannerBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSBannerBuilder(params: Params) {
  AMPSBannerComponent({
    params: params,
    instanceId: (params.platformView as OhosPlatformBannerView).instanceId
  })
}
