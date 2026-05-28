import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AD_ID, AD_INSTANCE_ID } from '../common/common';
import { AMPSDrawComponent } from './AMPSDrawComponent';

@Observed
export class OhosPlatformDrawView extends PlatformView {
  adId: string = ''
  instanceId: string = ''

  constructor(args: ESObject) {
    super();
    this.adId = (args.get(AD_ID) as string | undefined) ?? ''
    this.instanceId = (args.get(AD_INSTANCE_ID) as string | undefined) ?? ''
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSDrawBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSDrawBuilder(params: Params) {
  AMPSDrawComponent({
    params: params,
    adId: (params.platformView as OhosPlatformDrawView).adId,
    instanceId: (params.platformView as OhosPlatformDrawView).instanceId
  })
}
