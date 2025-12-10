import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AD_LOSS_REASON,
  AD_SEC_PRICE, AD_WIN_PRICE, AMPSAdCallBackChannelMethod, AMPSAdSdkMethodNames } from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { ampsAd, AMPSInterstitialAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { HashMap } from '@kit.ArkTS';
import { StringConstants } from '../common/StringConstants';
import { thirdPaymentService } from '@kit.PaymentKit';

export class AMPSInterstitialManager {
  private static instance: AMPSInterstitialManager;
  private interstitialAd?: AMPSInterstitialAd
  // 优化回调定义，减少重复代码
  private callback: ampsAd.CallBack = {
    onLoadSuccess: () => this.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess),
    onLoadFailure: (code: number, message: string) =>
    this.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, { code, message }),
    onRenderOk: () => this.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk),
    onAdShow: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdShow),
    onAdExposure: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure),
    onAdClicked: () => this.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked),
    onAdClosed: () => {
      this.cleanUp()
      this.sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
    },
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

  public static getInstance(): AMPSInterstitialManager {
    if (!AMPSInterstitialManager.instance) {
      AMPSInterstitialManager.instance = new AMPSInterstitialManager();
    }
    return AMPSInterstitialManager.instance;
  }
  getInterstitialAd(){
    return this.interstitialAd
  }
  private cleanUp(){

    this.interstitialAd = undefined
  }
  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.interstitialCreate:
        this.handleCreate(call, result)
        break;
      case AMPSAdSdkMethodNames.interstitialPreLoad:
        this.handlePreLoadAd(result);
        break;
      case AMPSAdSdkMethodNames.interstitialLoad:
        this.handleLoadAd(result);
        break;
      case AMPSAdSdkMethodNames.interstitialShowAd:
        this.handleShowAd(result, call.args);
        break;
      case AMPSAdSdkMethodNames.interstitialGetECPM:
        const mEcpm = this.interstitialAd?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.interstitialIsReadyAd:
        result.success(this.interstitialAd?.isReadyAd() ?? false);
        break;
      default:
        result.success(null);
    }
  }
  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      this.interstitialAd = new AMPSInterstitialAd(adOption, this.callback);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }
  // 处理开屏广告加载
  private handleLoadAd( result: MethodResult): void {
    try {
      this.interstitialAd?.load();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }
  private handlePreLoadAd( result: MethodResult): void {
    try {
      this.interstitialAd?.preloadAd();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }

  // 处理开屏广告显示
  private handleShowAd(result: MethodResult, args: Any): void {
    try {
      let context = AMPSEventManager.getInstance().getContext()
      if (this.interstitialAd && context) {
        this.interstitialAd?.showAd({windowStage:context.windowStage,uiContext:context.windowStage.getMainWindowSync().getUIContext()})
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在',undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true);
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}