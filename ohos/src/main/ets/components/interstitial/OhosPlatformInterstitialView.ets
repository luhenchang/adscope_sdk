import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSInterstitialComponent } from './AMPSInterstitialComponent';
import { AD_INSTANCE_ID } from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';

@Observed
export class OhosPlatformInterstitialView extends PlatformView {
  engine: AMPSEventManager
  instanceId: string = ''

  constructor(args: ESObject, engine: AMPSEventManager) {
    super();
    this.engine = engine
    if (args) {
      this.instanceId = (args.get(AD_INSTANCE_ID) as string | undefined) ?? ''
    }
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSInterstitialBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSInterstitialBuilder(params: Params) {
  AMPSInterstitialComponent({ platformView: params.platformView as OhosPlatformInterstitialView })
}
