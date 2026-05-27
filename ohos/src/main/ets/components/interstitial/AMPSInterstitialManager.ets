import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AD_INSTANCE_ID,
  AMPSInterstitialAdCallBackChannelMethod,
  AMPSAdSdkMethodNames,
} from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { ampsAd, AMPSInterstitialAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';

export class AMPSInterstitialManager {
  private static instance: AMPSInterstitialManager;
  private interstitialAds: Map<string, AMPSInterstitialAd> = new Map();

  public static getInstance(): AMPSInterstitialManager {
    if (!AMPSInterstitialManager.instance) {
      AMPSInterstitialManager.instance = new AMPSInterstitialManager();
    }
    return AMPSInterstitialManager.instance;
  }

  getInterstitialAd(instanceId?: string): AMPSInterstitialAd | undefined {
    if (instanceId) {
      return this.interstitialAds.get(instanceId);
    }
    const keys = Array.from(this.interstitialAds.keys());
    if (keys.length === 0) {
      return undefined;
    }
    return this.interstitialAds.get(keys[keys.length - 1]);
  }

  private extractInstanceId(args: Any): string | undefined {
    if (args === null || args === undefined) {
      return undefined;
    }
    const map = args as Record<string, Object>;
    const id = map[AD_INSTANCE_ID];
    return typeof id === 'string' ? id : undefined;
  }

  private cleanUp(instanceId: string) {
    this.interstitialAds.delete(instanceId);
  }

  private createCallback(instanceId: string): ampsAd.CallBack {
    return {
      onLoadSuccess: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onLoadSuccess),
      onLoadFailure: (code: number, message: string): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onLoadFailure, { code, message }),
      onRenderOk: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onRenderOk),
      onAdShow: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdShow),
      onAdExposure: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdExposure),
      onAdClicked: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdClicked),
      onAdClosed: (): void => {
        this.cleanUp(instanceId);
        this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdClosed);
      },
      onRenderFailure: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onRenderFailure),
      onAdShowError: (code: number, message: string): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdShowError, { code, message }),
      onVideoPlayStart: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onVideoPlayStart),
      onVideoPlayEnd: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onVideoPlayEnd),
      onVideoPlayError: (code: number, message: string): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onVideoPlayEnd, { code, message }),
      onVideoSkipToEnd: (playDurationMs?: number): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs }),
      onAdReward: (): void =>
      this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdReward),
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const instanceId = this.extractInstanceId(call.args);
    switch (call.method) {
      case AMPSAdSdkMethodNames.interstitialCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.interstitialPreLoad:
        if (instanceId) {
          this.interstitialAds.get(instanceId)?.preloadAd();
        }
        result.success(true);
        break;
      case AMPSAdSdkMethodNames.interstitialLoad:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleLoadAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.interstitialShowAd:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleShowAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.interstitialGetECPM:
        result.success(this.interstitialAds.get(instanceId ?? '')?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.interstitialIsReadyAd:
        result.success(this.interstitialAds.get(instanceId ?? '')?.isReadyAd() ?? false);
        break;
      case AMPSAdSdkMethodNames.interstitialDestroy:
        if (instanceId) {
          this.cleanUp(instanceId);
        }
        result.success(null);
        break;
      default:
        result.success(null);
    }
  }

  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const instanceId = this.extractInstanceId(call.args);
      if (!instanceId) {
        result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
        return;
      }
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      this.interstitialAds.set(
        instanceId,
        new AMPSInterstitialAd(adOption, this.createCallback(instanceId)),
      );
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      this.interstitialAds.get(instanceId)?.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleShowAd(instanceId: string, result: MethodResult): void {
    try {
      const context = AMPSEventManager.getInstance().getContext();
      const interstitialAd = this.interstitialAds.get(instanceId);
      if (interstitialAd && context) {
        interstitialAd.showAd({
          windowStage: context.windowStage,
          uiContext: context.windowStage.getMainWindowSync().getUIContext(),
        });
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  public sendMessage(instanceId: string, method: string, args?: Any) {
    const payload: Record<string, Object> = {};
    payload[AD_INSTANCE_ID] = instanceId;
    if (args !== null && args !== undefined) {
      const extra = args as Record<string, Object>;
      Object.keys(extra).forEach((key: string) => {
        payload[key] = extra[key];
      });
    }
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload);
  }
}
