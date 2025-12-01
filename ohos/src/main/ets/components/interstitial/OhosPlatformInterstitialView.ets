import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import { AMPSPlatformViewRegistry, defaultAdOption, CONFIG, AMPSAdSdkMethodNames, AD_WIN_PRICE,
  AD_SEC_PRICE,
  AD_LOSS_REASON} from '../common/common';
import { Any, MethodCall, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd,AMPSInterstitialAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSInterstitialComponent } from './AMPSInterstitialComponent';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../common/StringConstants';

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


