import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { AMPSNativeAdWrapper } from 'xyz.adscope.amps';
import { AdWrapperManager } from '../native/AdWrapperManager';
import { AMPSNativeAdComponent } from './AMPSNativeAdComponent';

@Observed
export class OhosPlatformNativeView extends PlatformView {
  static adId: string | undefined;
  static wrapper: AMPSNativeAdWrapper | undefined
  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    OhosPlatformNativeView.adId = args.get("adId")
    if (OhosPlatformNativeView.adId) {
      OhosPlatformNativeView.wrapper = AdWrapperManager.getInstance().getAd(OhosPlatformNativeView.adId)
    }
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSNativeWrappedBuilder);
  }

  dispose(): void {
  }
}


@Builder
export function AMPSNativeWrappedBuilder(params: Params) {
  AMPSNativeAdComponent({ params: params, adId: OhosPlatformNativeView.adId })
}
