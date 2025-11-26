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
export class OhosPlatformInterstitialView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel | null | undefined
  static adOptionsWeakRef: WeakRef<ampsAd.AdOptions> | undefined;
  currentResult?: MethodResult
  static  interstitialAd?: AMPSInterstitialAd
  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    OhosPlatformInterstitialView.interstitialAd = undefined;
    const channelName = `${AMPSPlatformViewRegistry.ampsSdkInterstitialViewId}${viewId}`;
    OhosPlatformInterstitialView.adOptionsWeakRef = new WeakRef(AdOptionsModule.getAdOptionFromMap(args.get(CONFIG)));
    this.methodChannel = new MethodChannel(message, channelName, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.currentResult = result;
    let method: string = call.method;
    switch (method) {
      case AMPSAdSdkMethodNames.interstitialGetECPM:
        const mEcpm = OhosPlatformInterstitialView.interstitialAd?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.interstitialNotifyRTBWin:
        const params: HashMap<String, number> = call.args;
        const winPrice: number = params.get(AD_WIN_PRICE) ?? 0
        const secPrice: number = params.get(AD_SEC_PRICE) ?? 0
        if (winPrice != undefined && secPrice != undefined) {
          // OhosPlatformInterstitialView.interstitialAd?.notifyRTBWin(winPrice, secPrice)
        }
        break;
      case AMPSAdSdkMethodNames.interstitialNotifyRTBLoss:
        const lossParams: HashMap<String, Any> = call.args;
        const lossWinPrice: number = lossParams.get(AD_WIN_PRICE) ?? 0
        const lossSecPrice: number = lossParams.get(AD_SEC_PRICE) ?? 0
        const lossReason: string = lossParams.get(AD_LOSS_REASON) ?? StringConstants.EMPTY_STRING
        if (lossWinPrice != undefined  && lossSecPrice != undefined  && lossReason != undefined ) {
          // OhosPlatformInterstitialView.interstitialAd?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason)
        }
        break;
      case AMPSAdSdkMethodNames.interstitialIsReadyAd:
        result.success(OhosPlatformInterstitialView.interstitialAd?.isReadyAd() ?? false);
        break;
    }
  }

  public sendMessage = (methodName: string, args: Any) => {
    this.methodChannel?.invokeMethod(methodName, args);
  }


  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
  }
}

@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSInterstitialComponent(
    {
      params: params, adOption: OhosPlatformInterstitialView.adOptionsWeakRef?.deref() ?? defaultAdOption
    }
  )
}
