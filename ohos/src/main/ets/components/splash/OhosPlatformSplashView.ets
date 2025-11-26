import MethodChannel from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';
import { AMPSSplashComponent } from './AMPSSplashComponent';
import { AMPSPlatformViewRegistry, defaultAdOption, SPLASH_BOTTOM, CONFIG, AMPSAdSdkMethodNames,
  AD_WIN_PRICE,
  AD_SEC_PRICE,
  AD_LOSS_REASON} from '../common/common';
import { Any, MethodCallHandler, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd,AMPSSplashAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { SplashBottomModule } from '../splash/SplashBottomModule';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../common/StringConstants';

//底部自定义组件全局WrappedBuilder
export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(MyBuilder);
@Observed
export class OhosPlatformSplashView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel | null | undefined
  static adOptionsWeakRef: WeakRef<ampsAd.AdOptions> | undefined;
  static splashBottomModule: SplashBottomModule | null | undefined = null
  static  mSplashAd?: AMPSSplashAd | null = null
  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    OhosPlatformSplashView.mSplashAd = null;
    const channelName = `${AMPSPlatformViewRegistry.ampsSdkSplashViewId}${viewId}`;
    OhosPlatformSplashView.splashBottomModule = new SplashBottomModule(args.get(SPLASH_BOTTOM));
    OhosPlatformSplashView.adOptionsWeakRef = new WeakRef(AdOptionsModule.getAdOptionFromMap(args.get(CONFIG)));
    this.methodChannel = new MethodChannel(message, channelName, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(call: MethodCall, result: MethodResult){
      switch (call.method){
        case AMPSAdSdkMethodNames.splashGetECPM:
          const mEcpm = OhosPlatformSplashView.mSplashAd?.getECPM() ?? 0
          result.success(mEcpm);
          break;
        case AMPSAdSdkMethodNames.splashNotifyRTBWin:
          const params: HashMap<String, number> = call.args;
          const winPrice: number = params.get(AD_WIN_PRICE) ?? 0
          const secPrice: number = params.get(AD_SEC_PRICE) ?? 0
          if (winPrice != undefined && secPrice != undefined) {
            // OhosPlatformSplashView.mSplashAd?.notifyRTBWin(winPrice, secPrice)
          }
          break;
        case AMPSAdSdkMethodNames.splashNotifyRTBLoss:
          const lossParams: HashMap<String, Any> = call.args;
          const lossWinPrice: number = lossParams.get(AD_WIN_PRICE) ?? 0
          const lossSecPrice: number = lossParams.get(AD_SEC_PRICE) ?? 0
          const lossReason: string = lossParams.get(AD_LOSS_REASON) ?? StringConstants.EMPTY_STRING
          if (lossWinPrice != undefined  && lossSecPrice != undefined  && lossReason != undefined ) {
            // OhosPlatformSplashView.mSplashAd?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason)
          }
          break;
        case AMPSAdSdkMethodNames.splashIsReadyAd:
          result.success(OhosPlatformSplashView.mSplashAd?.isReadyAd() ?? false);
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
    OhosPlatformSplashView.splashBottomModule = null;
  }
}


@Builder
export function MyBuilder() {
  if (OhosPlatformSplashView.splashBottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${OhosPlatformSplashView.splashBottomModule?.imgChildren?.imagePath}`))
        .width(OhosPlatformSplashView.splashBottomModule?.imgChildren?.width)
        .height(OhosPlatformSplashView.splashBottomModule?.imgChildren?.height)
        .offset({
          x: OhosPlatformSplashView.splashBottomModule?.imgChildren?.x,
          y: OhosPlatformSplashView.splashBottomModule?.imgChildren?.y
        })
      Text(OhosPlatformSplashView.splashBottomModule?.textChildren?.text)
        .fontColor(OhosPlatformSplashView.splashBottomModule?.textChildren?.color)
        .offset({
          x: OhosPlatformSplashView.splashBottomModule?.textChildren?.x,
          y: OhosPlatformSplashView.splashBottomModule?.textChildren?.y
        })
    }
    .backgroundColor(OhosPlatformSplashView.splashBottomModule?.backgroundColor)
    .height(OhosPlatformSplashView.splashBottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}


@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSSplashComponent(
    {
      params: params, adOption: OhosPlatformSplashView.adOptionsWeakRef?.deref() ?? defaultAdOption
    }
  )
}
