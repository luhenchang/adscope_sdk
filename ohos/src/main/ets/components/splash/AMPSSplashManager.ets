import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AD_LOSS_REASON,
  AD_SEC_PRICE, AD_WIN_PRICE, AMPSAdCallBackChannelMethod, AMPSAdSdkMethodNames } from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { ampsAd, AMPSSplashAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { SplashBottomModule } from '../splash/SplashBottomModule';
import { window } from '@kit.ArkUI';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../common/StringConstants';

export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(SplashBottomBuilder);
export class AMPSSplashManager {
  private static instance: AMPSSplashManager;
  private mWindowStage?: window.WindowStage;
  private mSplashAd?: AMPSSplashAd;
  private mWindow?: window.Window;
  static splashBottomModule: SplashBottomModule | null | undefined = null

  public static getInstance(): AMPSSplashManager {
    if (!AMPSSplashManager.instance) {
      AMPSSplashManager.instance = new AMPSSplashManager();
    }
    return AMPSSplashManager.instance;
  }

  // 优化回调定义，减少重复代码
  private callback: ampsAd.CallBack = {
    onLoadSuccess: () => this.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess),
    onLoadFailure: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, { code, message }),
    onRenderOk: () => this.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk),
    onAdShow: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdShow),
    onAdExposure: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure),
    onAdClicked: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked),
    onAdClosed: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdClosed),
    onRenderFailure: () => this.sendMessage(AMPSAdCallBackChannelMethod.onRenderFailure),
    onAdShowError: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onAdShowError, { code, message }),
    onVideoPlayStart: () => this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayStart),
    onVideoPlayEnd: () => this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd),
    onVideoPlayError: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd, { code, message }),
    onVideoSkipToEnd: (playDurationMs?: number) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs }),
    onAdReward: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdReward)
  };

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.splashLoad:
        this.handleSplashLoad(call, result);
        break;
      case AMPSAdSdkMethodNames.splashShowAd:
        this.handleSplashShowAd(result, call.args);
        break;
      case AMPSAdSdkMethodNames.splashGetECPM:
        const mEcpm = this.mSplashAd?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.splashNotifyRTBWin:
        const params: HashMap<String, number> = call.args;
        const winPrice: number = params.get(AD_WIN_PRICE) ?? 0
        const secPrice: number = params.get(AD_SEC_PRICE) ?? 0
        if (winPrice != undefined && secPrice != undefined) {
          // this.mSplashAd?.notifyRTBWin(winPrice, secPrice)
        }
        break;
      case AMPSAdSdkMethodNames.splashNotifyRTBLoss:
        const lossParams: HashMap<String, Any> = call.args;
        const lossWinPrice: number = lossParams.get(AD_WIN_PRICE) ?? 0
        const lossSecPrice: number = lossParams.get(AD_SEC_PRICE) ?? 0
        const lossReason: string = lossParams.get(AD_LOSS_REASON) ?? StringConstants.EMPTY_STRING
        if (lossWinPrice != undefined  && lossSecPrice != undefined  && lossReason != undefined ) {
          // this.mSplashAd?.notifyRTBLoss(lossWinPrice, lossSecPrice, lossReason)
        }
        break;
      case AMPSAdSdkMethodNames.splashIsReadyAd:
        result.success(this.mSplashAd?.isReadyAd() ?? false);
        break;
      default:
        result.notImplemented();
    }
  }


  // 处理开屏广告加载
  private handleSplashLoad(call: MethodCall, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      let context = AMPSEventManager.getInstance().getContext()
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        this.mWindow = this.mWindowStage.getMainWindowSync();
        if (this.mWindow) {
          this.mSplashAd = new AMPSSplashAd(adOption, this.callback, this.mWindow.getUIContext());
          this.mSplashAd.load();
          result.success(true);
        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
      }
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  // 处理开屏广告显示
  private handleSplashShowAd(result: MethodResult, args: Any): void {
    try {
      if (this.mSplashAd && this.mWindowStage) {
        AMPSSplashManager.splashBottomModule = new SplashBottomModule(args);
        this.mSplashAd.showAd({ windowStage: this.mWindowStage, bottomWrappedBuilder: globalSplashBottomBuilder });
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}

@Builder
export function SplashBottomBuilder() {
  if (AMPSSplashManager.splashBottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${AMPSSplashManager.splashBottomModule?.imgChildren?.imagePath}`))
        .width(AMPSSplashManager.splashBottomModule?.imgChildren?.width)
        .height(AMPSSplashManager.splashBottomModule?.imgChildren?.height)
        .offset({
          x: AMPSSplashManager.splashBottomModule?.imgChildren?.x,
          y: AMPSSplashManager.splashBottomModule?.imgChildren?.y
        })
      Text(AMPSSplashManager.splashBottomModule?.textChildren?.text)
        .fontColor(AMPSSplashManager.splashBottomModule?.textChildren?.color)
        .offset({
          x: AMPSSplashManager.splashBottomModule?.textChildren?.x,
          y: AMPSSplashManager.splashBottomModule?.textChildren?.y
        })
    }
    .backgroundColor(AMPSSplashManager.splashBottomModule?.backgroundColor)
    .height(AMPSSplashManager.splashBottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}