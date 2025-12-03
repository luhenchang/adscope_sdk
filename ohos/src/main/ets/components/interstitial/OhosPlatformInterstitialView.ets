import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSInterstitialComponent } from './AMPSInterstitialComponent';

@Observed
export class OhosPlatformInterstitialView extends PlatformView {
  constructor() {
    super();
  }
  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSInterstitialBuilder);
  }
  dispose(): void {
  }
}

@Builder
export function AMPSInterstitialBuilder(params: Params) {
    AMPSInterstitialComponent()
}


