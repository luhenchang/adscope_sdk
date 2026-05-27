import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSRewardVideoAd, AMPSRewardVideoListener } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import {
  AD_INSTANCE_ID,
  AMPSRewardedVideoCallBackChannelMethod,
  AMPSAdSdkMethodNames,
} from '../common/common';

export class AMPSRewardVideoManager {
  private static instance?: AMPSRewardVideoManager;
  private rewardVideos: Map<string, AMPSRewardVideoAd> = new Map();

  private constructor() {
  }

  static getInstance() {
    if (!AMPSRewardVideoManager.instance) {
      AMPSRewardVideoManager.instance = new AMPSRewardVideoManager();
    }
    return AMPSRewardVideoManager.instance!;
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
    this.rewardVideos.delete(instanceId);
  }

  private createCallback(instanceId: string): AMPSRewardVideoListener {
    return {
      onLoadSuccess: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess);
      },
      onLoadFailure: (code: number, message: string): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onLoadFailure, { code, message });
      },
      onAdDidShow: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdShow);
      },
      onAdClicked: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdClicked);
      },
      onAdClosed: (): void => {
        this.cleanUp(instanceId);
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdClosed);
      },
      onVideoPlayStart: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onVideoPlayStart);
      },
      onVideoPlayEnd: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd);
      },
      onVideoPlayError: (code: number, message: string): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onVideoPlayError, { code, message });
      },
      onVideoSkipToEnd: (playDurationMs?: number | undefined): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs });
      },
      onAdReward: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdReward);
      },
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const instanceId = this.extractInstanceId(call.args);
    switch (call.method) {
      case AMPSAdSdkMethodNames.rewardVideoCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoLoad:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleLoadAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoPreLoad:
        if (instanceId) {
          this.rewardVideos.get(instanceId)?.load();
        }
        result.success(true);
        break;
      case AMPSAdSdkMethodNames.rewardVideoShowAd:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleShowAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.rewardVideoGetECPM:
        result.success(this.rewardVideos.get(instanceId ?? '')?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.rewardVideoIsReadyAd:
        result.success(this.rewardVideos.get(instanceId ?? '')?.isReadyAd() ?? false);
        break;
      case AMPSAdSdkMethodNames.rewardVideoDestroyAd:
        if (instanceId) {
          this.cleanUp(instanceId);
        }
        result.success(true);
        break;
      default:
        result.success(undefined);
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
      this.rewardVideos.set(instanceId, new AMPSRewardVideoAd(adOption, this.createCallback(instanceId)));
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      this.rewardVideos.get(instanceId)?.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleShowAd(instanceId: string, result: MethodResult): void {
    try {
      const context = AMPSEventManager.getInstance().getContext();
      const rewardVideo = this.rewardVideos.get(instanceId);
      if (rewardVideo && context) {
        rewardVideo.showAd(context.windowStage);
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
