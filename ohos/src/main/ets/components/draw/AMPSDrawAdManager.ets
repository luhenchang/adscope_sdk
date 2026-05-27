import {
  Any, MethodCall, MethodResult
} from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSDrawAd,
  AMPSDrawAdListener,
  AMPSDrawAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSDrawRenderListener
} from 'xyz.adscope.amps';
import {
  AD_INSTANCE_ID,
  AMPSAdSdkMethodNames,
  AmpsDrawCallbackChannelMethod
} from '../common/common';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AMPSEventManager } from '../common/AMPSEventManager';

class DrawSlot {
  instanceId: string = '';
  ad?: AMPSDrawAd;
  adItemMap: Map<string, AMPSDrawAdWrapper> = new Map();
}

export class AMPSDrawAdManager {
  private static instance: AMPSDrawAdManager;
  private mWindowStage?: window.WindowStage;
  private slots: Map<string, DrawSlot> = new Map();
  private adIdToInstance: Map<string, string> = new Map();

  public static getInstance(): AMPSDrawAdManager {
    if (!AMPSDrawAdManager.instance) {
      AMPSDrawAdManager.instance = new AMPSDrawAdManager();
    }
    return AMPSDrawAdManager.instance;
  }

  /** 提供给 view 组件按 adId 查询 wrapper（全局 UUID 唯一）。 */
  getAdItem(adId: string): AMPSDrawAdWrapper | undefined {
    const instanceId = this.adIdToInstance.get(adId);
    if (!instanceId) {
      return undefined;
    }
    return this.slots.get(instanceId)?.adItemMap.get(adId);
  }

  private extractInstanceId(args: Any): string | undefined {
    if (args === null || args === undefined) {
      return undefined;
    }
    const map = args as Record<string, Object>;
    const id = map[AD_INSTANCE_ID];
    return typeof id === 'string' ? id : undefined;
  }

  private getSlot(instanceId: string): DrawSlot | undefined {
    return this.slots.get(instanceId);
  }

  private ensureSlot(instanceId: string): DrawSlot {
    let slot = this.slots.get(instanceId);
    if (!slot) {
      slot = new DrawSlot();
      slot.instanceId = instanceId;
      this.slots.set(instanceId, slot);
    }
    return slot;
  }

  private cleanUp(instanceId: string): void {
    const slot = this.slots.get(instanceId);
    if (!slot) {
      return;
    }
    slot.adItemMap.forEach((_, adId) => {
      this.adIdToInstance.delete(adId);
    });
    slot.adItemMap.clear();
    this.slots.delete(instanceId);
  }

  private buildInteractiveCallback(instanceId: string, slot: DrawSlot): AMPSNativeInteractiveListener {
    return {
      onAdShow: (_adId?: string): void => {
        // 与 Native 一致：onAdShow 由 onAdExposure 触发，避免重复回调。
      },
      onAdExposure: (adId?: string): void => {
        this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onAdShow, { adId });
      },
      onAdClicked: (adId?: string): void => {
        this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onAdClicked, { adId });
      },
      toCloseAd: (adId?: string): void => {
        if (adId) {
          slot.adItemMap.delete(adId);
          this.adIdToInstance.delete(adId);
          this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onAdClosed, { adId });
        }
      }
    };
  }

  private buildRenderCallback(instanceId: string, slot: DrawSlot): AMPSDrawRenderListener {
    return {
      renderSuccess: (adWrapper: AMPSDrawAdWrapper): void => {
        this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onRenderSuccess, { adId: adWrapper.adId });
        adWrapper.interactCallBack = this.buildInteractiveCallback(instanceId, slot);
        adWrapper.videoPlayCallBack = {
          onVideoReady: () => { },
          onVideoPlayStart: () => {
            this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onVideoPlayStart, { adId: adWrapper.adId });
          },
          onVideoPause: () => {
            this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onVideoPlayPause, { adId: adWrapper.adId });
          },
          onVideoResume: () => {
            this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onVideoAdContinuePlay, { adId: adWrapper.adId });
          },
          onVideoPlayComplete: () => {
            this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onVideoAdComplete, { adId: adWrapper.adId });
          },
          onVideoPlayError: (code, extra) => {
            this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onVideoError, { adId: adWrapper.adId, code, extra });
          }
        };
        slot.adItemMap.set(adWrapper.adId, adWrapper);
        this.adIdToInstance.set(adWrapper.adId, instanceId);
      },
      renderFailed: (adWrapper: AMPSDrawAdWrapper): void => {
        this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onRenderFail, { adId: adWrapper.adId });
      }
    };
  }

  private buildLoadCallback(instanceId: string, slot: DrawSlot): AMPSDrawAdListener {
    const renderCb = this.buildRenderCallback(instanceId, slot);
    return {
      loadOk: (adItems: AMPSDrawAdWrapper[]): void => {
        const adIdList: string[] = adItems.map((ad) => ad.adId);
        this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onLoadSuccess, { adIds: adIdList });
        adItems.forEach((item) => {
          item.renderCallBack = renderCb;
          item.renderAd();
        });
      },
      loadFail: (code: number, message: string): void => {
        this.sendMessage(instanceId, AmpsDrawCallbackChannelMethod.onLoadFailure, { code, message });
      }
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const instanceId = this.extractInstanceId(call.args);
    switch (call.method) {
      case AMPSAdSdkMethodNames.drawCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.drawLoad:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleLoadAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.drawGetEcpm:
        result.success(this.getAdWrapper(call.args)?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.drawIsReadyAd:
        result.success(this.getSlot(instanceId ?? '')?.ad?.isReadyAd() ?? false);
        break;
      case AMPSAdSdkMethodNames.drawDestroyAd:
        if (instanceId) {
          this.cleanUp(instanceId);
        }
        result.success(null);
        break;
      case AMPSAdSdkMethodNames.drawPauseAd:
      case AMPSAdSdkMethodNames.drawResumeAd:
        result.success(null);
        break;
      default:
        result.success(null);
    }
  }

  private getAdWrapper(arg: ESObject): AMPSDrawAdWrapper | undefined {
    const map = arg as Record<string, Object>;
    const targetAdId = map['adId'] as string;
    return this.getAdItem(targetAdId);
  }

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
      slot.ad = new AMPSDrawAd(mWindow.getUIContext(), adOption, this.buildLoadCallback(instanceId, slot));
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      this.getSlot(instanceId)?.ad?.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
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
