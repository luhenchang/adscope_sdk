import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSBannerAd, AMPSBannerAdWrapper } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AD_INSTANCE_ID, AMPSBannerCallBackChannelMethod, AMPSAdSdkMethodNames } from '../common/common';
import { window } from '@kit.ArkUI';

class BannerSlot {
  bannerAd?: AMPSBannerAd;
  bannerAdItem?: AMPSBannerAdWrapper;
}

export class AMPSBannerManager {
  private static instance?: AMPSBannerManager;
  private bannerSlots: Map<string, BannerSlot> = new Map();
  static currentViewInstanceId?: string;

  private constructor() {}

  static getInstance() {
    if (!AMPSBannerManager.instance) {
      AMPSBannerManager.instance = new AMPSBannerManager();
    }
    return AMPSBannerManager.instance!;
  }

  private extractInstanceId(args: Any): string | undefined {
    if (args === null || args === undefined) {
      return undefined;
    }
    const map = args as Record<string, Object>;
    const id = map[AD_INSTANCE_ID];
    return typeof id === 'string' ? id : undefined;
  }

  getBannerAdItem(instanceId?: string): AMPSBannerAdWrapper | undefined {
    const id = instanceId ?? AMPSBannerManager.currentViewInstanceId;
    if (id) {
      return this.bannerSlots.get(id)?.bannerAdItem;
    }
    const keys = Array.from(this.bannerSlots.keys());
    if (keys.length === 0) {
      return undefined;
    }
    return this.bannerSlots.get(keys[keys.length - 1])?.bannerAdItem;
  }

  private cleanUp(instanceId: string) {
    this.bannerSlots.delete(instanceId);
    if (AMPSBannerManager.currentViewInstanceId === instanceId) {
      AMPSBannerManager.currentViewInstanceId = undefined;
    }
  }

  private ensureSlot(instanceId: string): BannerSlot {
    let slot = this.bannerSlots.get(instanceId);
    if (!slot) {
      slot = new BannerSlot();
      this.bannerSlots.set(instanceId, slot);
    }
    return slot;
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const instanceId = this.extractInstanceId(call.args);
    switch (call.method) {
      case AMPSAdSdkMethodNames.bannerCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.bannerLoad:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleLoadAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.bannerPreLoad:
        if (instanceId) {
          this.bannerSlots.get(instanceId)?.bannerAd?.load();
        }
        result.success(true);
        break;
      case AMPSAdSdkMethodNames.bannerSetSlideTime:
        this.setSlideIntervalTime(instanceId, result, call.args);
        break;
      case AMPSAdSdkMethodNames.bannerGetECPM:
        result.success(this.getBannerAdItem(instanceId)?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.bannerDestroyAd:
        if (instanceId) {
          this.cleanUp(instanceId);
        }
        result.success(true);
        break;
      case AMPSAdSdkMethodNames.bannerIsReadyAd:
        result.success(this.bannerSlots.get(instanceId ?? '')?.bannerAd?.isReadyAd() ?? false);
        break;
      default:
        result.success(undefined);
    }
  }

  mWindowStage?: window.WindowStage;

  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const instanceId = this.extractInstanceId(call.args);
      if (!instanceId) {
        result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
        return;
      }
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      const context = AMPSEventManager.getInstance().getContext();
      this.mWindowStage = context?.windowStage;
      if (!this.mWindowStage) {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
        return;
      }
      const mWindow = this.mWindowStage.getMainWindowSync();
      if (!mWindow) {
        result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
        return;
      }
      const slot = this.ensureSlot(instanceId);
      const that = this;
      slot.bannerAd = new AMPSBannerAd(mWindow.getUIContext(), adOption, {
        loadOk: (ads) => {
          slot.bannerAdItem = ads[0];
          AMPSBannerManager.currentViewInstanceId = instanceId;
          slot.bannerAdItem.renderCallBack = {
            renderSuccess() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onLoadSuccess);
            },
            renderFailed(code, message) {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onLoadFailure, { code, message });
            },
          };
          slot.bannerAdItem.interactCallBack = {
            onAdShow() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdShow);
            },
            onAdExposure() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdShow);
            },
            onAdClicked() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdClicked);
            },
            toCloseAd() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdClosed);
            },
          };
          slot.bannerAdItem.videoPlayCallBack = {
            onVideoReady() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoReady);
            },
            onVideoPlayStart() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoPlayStart);
            },
            onVideoPause() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoPause);
            },
            onVideoResume() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoResume);
            },
            onVideoPlayComplete() {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoPlayEnd);
            },
            onVideoPlayError(code, message) {
              that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onLoadFailure, { code, message });
            },
          };
          ads[0].renderAd();
        },
        loadFail: (code, message) => {
          that.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onLoadFailure, { code, message });
        },
      });
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      this.bannerSlots.get(instanceId)?.bannerAd?.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private setSlideIntervalTime(instanceId: string | undefined, result: MethodResult, args: Any): void {
    try {
      if (instanceId && args as number) {
        const time = args as number;
        this.bannerSlots.get(instanceId)?.bannerAdItem?.setSlideIntervalTime(time);
        result.success(true);
      } else {
        result.error('SHOW_FAILED', 'adInstanceId or slide time missing', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `设置轮播间隔异常: ${error instanceof Error ? error.message : error}`, undefined);
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
