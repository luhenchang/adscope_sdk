import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSRewardVideoAd, AMPSRewardVideoListener } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import {
  AMPSRewardedVideoCallBackChannelMethod,
  AMPSAdSdkMethodNames,
} from '../common/common';

export class AMPSRewardVideoManager {
  private static instance?: AMPSRewardVideoManager

  private constructor() {
  }

  static getInstance() {
    if (!AMPSRewardVideoManager.instance) {
      AMPSRewardVideoManager.instance = new AMPSRewardVideoManager()
    }
    return AMPSRewardVideoManager.instance!
  }

  rewardVideo?: AMPSRewardVideoAd
  private callBack: AMPSRewardVideoListener = {
    onLoadSuccess: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess);
    },
    onLoadFailure: (code: number, message: string): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onLoadFailure, { code, message });
    },
    onAdDidShow: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdShow);
    },
    onAdClicked: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdClicked);
    },
    onAdClosed: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdClosed);
    },
    onVideoPlayStart: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onVideoPlayStart);
    },
    onVideoPlayEnd: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd);
    },
    onVideoPlayError: (code: number, message: string): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onVideoPlayError, { code, message });
    },
    onVideoSkipToEnd: (playDurationMs?: number | undefined): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs });
    },
    onAdReward: (): void => {
      this.sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdReward);
    }
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case AMPSAdSdkMethodNames.rewardVideoCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoLoad:
        this.handleLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoPreLoad:
        this.handlePreLoadAd(call, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoShowAd:
        this.handleShowAd(result, call.args);
        break;
      case AMPSAdSdkMethodNames.rewardVideoGetECPM:
        const mEcpm = this.rewardVideo?.getECPM() ?? 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.rewardVideoIsReadyAd:
        result.success(this.rewardVideo?.isReadyAd() ?? false);
        break;
      case AMPSAdSdkMethodNames.rewardVideoDestroyAd:
        this.rewardVideo = undefined
        result.success(true);
        break;
      default:
        result.success(undefined);
    }
  }

  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      let adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);

      this.rewardVideo = new AMPSRewardVideoAd(adOption, this.callBack)
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
    result.success(true)
  }

  // 处理开屏广告加载
  private handlePreLoadAd(call: MethodCall, result: MethodResult): void {
    try {

      this.rewardVideo?.load();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
    result.success(true)
  }

  private handleLoadAd(call: MethodCall, result: MethodResult): void {
    try {

      this.rewardVideo?.load();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
    result.success(true)
  }

  // 处理开屏广告显示
  private handleShowAd(result: MethodResult, args: Any): void {
    try {
      let context = AMPSEventManager.getInstance().getContext()
      if (this.rewardVideo && context) {
        this.rewardVideo?.showAd(context.windowStage)

      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
    result.success(true)
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}