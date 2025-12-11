

import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSDrawComponent } from './AMPSDrawComponent';

@Observed
export class OhosPlatformDrawView extends PlatformView {
  static adId?:string
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
  AMPSDrawComponent()
}
