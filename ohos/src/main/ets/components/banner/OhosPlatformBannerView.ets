import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSBannerComponent } from './AMPSBannerComponent';

@Observed
export class OhosPlatformBannerView extends PlatformView {
  constructor() {
    super();
  }
  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSBannerBuilder);
  }
  dispose(): void {
  }
}

@Builder
export function AMPSBannerBuilder(params: Params) {
  AMPSBannerComponent()
}
