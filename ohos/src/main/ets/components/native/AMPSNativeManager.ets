import {
  Any, MethodCall, MethodResult
} from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSNativeAd,
  AMPSNativeAdListener,
  AMPSAdVideoPlayConfig,
  AMPSNativeAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSNativeRenderListener
} from 'xyz.adscope.amps';
import {
  AD_INSTANCE_ID,
  AMPSAdSdkMethodNames,
  AMPSNativeCallBackChannelMethod
} from '../common/common';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AdWrapperManager } from '../native/AdWrapperManager';
import { AMPSEventManager } from '../common/AMPSEventManager';

class NativeSlot {
  instanceId: string = '';
  ad?: AMPSNativeAd;
  adIds: Set<string> = new Set<string>();
}

export class AMPSNativeManager {
  private static instance: AMPSNativeManager;
  private mWindowStage?: window.WindowStage;
  private slots: Map<string, NativeSlot> = new Map();
  private mVideoConfig?: AMPSAdVideoPlayConfig;

  public static getInstance(): AMPSNativeManager {
    if (!AMPSNativeManager.instance) {
      AMPSNativeManager.instance = new AMPSNativeManager();
    }
    return AMPSNativeManager.instance;
  }

  private extractInstanceId(args: Any): string | undefined {
    if (args === null || args === undefined) {
      return undefined;
    }
    const map = args as Record<string, Object>;
    const id = map[AD_INSTANCE_ID];
    return typeof id === 'string' ? id : undefined;
  }

  private getSlot(instanceId: string): NativeSlot | undefined {
    return this.slots.get(instanceId);
  }

  private ensureSlot(instanceId: string): NativeSlot {
    let slot = this.slots.get(instanceId);
    if (!slot) {
      slot = new NativeSlot();
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
    slot.adIds.forEach((adId) => {
      AdWrapperManager.getInstance().removeAd(adId);
    });
    slot.adIds.clear();
    this.slots.delete(instanceId);
  }

  private buildInteractiveCallback(instanceId: string, slot: NativeSlot): AMPSNativeInteractiveListener {
    return {
      onAdShow: (adId?: string): void => {
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onAdShow, { adId });
      },
      onAdExposure: (adId?: string): void => {
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onAdExposure, { adId });
      },
      onAdClicked: (adId?: string): void => {
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onAdClicked, { adId });
      },
      toCloseAd: (adId?: string): void => {
        if (adId) {
          AdWrapperManager.getInstance().removeAd(adId);
          slot.adIds.delete(adId);
          this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onAdClosed, { adId });
        }
      }
    };
  }

  private buildRenderCallback(instanceId: string, slot: NativeSlot): AMPSNativeRenderListener {
    return {
      renderSuccess: (adWrapper: AMPSNativeAdWrapper): void => {
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.renderSuccess, { adId: adWrapper.adId });
        adWrapper.interactCallBack = this.buildInteractiveCallback(instanceId, slot);
        adWrapper.videoPlayCallBack = {
          onVideoReady: () => {
            this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onVideoReady, { adId: adWrapper.adId });
          },
          onVideoPlayStart: () => {
            this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onVideoPlayStart, { adId: adWrapper.adId });
          },
          onVideoPause: () => {
            this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onVideoPause, { adId: adWrapper.adId });
          },
          onVideoResume: () => {
            this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onVideoResume, { adId: adWrapper.adId });
          },
          onVideoPlayComplete: () => {
            this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onVideoPlayComplete, { adId: adWrapper.adId });
          },
          onVideoPlayError: (code, extra) => {
            this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.onVideoPlayError, { adId: adWrapper.adId, code, extra });
          }
        };
        slot.adIds.add(adWrapper.adId);
        AdWrapperManager.getInstance().addAd(adWrapper);
      },
      renderFailed: (adWrapper: AMPSNativeAdWrapper): void => {
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.renderFailed, { adId: adWrapper.adId });
      }
    };
  }

  private buildLoadCallback(instanceId: string, slot: NativeSlot): AMPSNativeAdListener {
    const renderCb = this.buildRenderCallback(instanceId, slot);
    return {
      loadOk: (adItems: AMPSNativeAdWrapper[]): void => {
        const adIdList: string[] = adItems.map((ad) => ad.adId);
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.loadOk, { adIds: adIdList });
        adItems.forEach((item) => {
          item.renderCallBack = renderCb;
          item.renderAd();
        });
      },
      loadFail: (code: number, message: string): void => {
        this.sendMessage(instanceId, AMPSNativeCallBackChannelMethod.loadFail, { code, message });
      }
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const instanceId = this.extractInstanceId(call.args);
    switch (call.method) {
      case AMPSAdSdkMethodNames.nativeCreate:
        this.handleCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.nativeLoad:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
          return;
        }
        this.handleLoadAd(instanceId, result);
        break;
      case AMPSAdSdkMethodNames.nativeGetECPM:
        result.success(this.getAdWrapper(call.args)?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.nativeIsReadyAd:
        result.success(this.getSlot(instanceId ?? '')?.ad?.isReadyAd() ?? false);
        break;
      case AMPSAdSdkMethodNames.nativeIsNativeExpress:
        result.success(this.getAdWrapper(call.args)?.isNativeExpress() ?? false);
        break;
      case AMPSAdSdkMethodNames.nativeGetVideoDuration:
        result.success(this.getAdWrapper(call.args)?.getVideoDuration() ?? 0);
        break;
      case AMPSAdSdkMethodNames.nativeDestroy:
        if (instanceId) {
          this.cleanUp(instanceId);
        }
        result.success(null);
        break;
      case AMPSAdSdkMethodNames.nativeResume:
      case AMPSAdSdkMethodNames.nativePause:
        result.success(null);
        break;
      default:
        result.success(null);
    }
  }

  private getAdWrapper(arg: ESObject): AMPSNativeAdWrapper | undefined {
    const map = arg as Record<string, Object>;
    const targetAdId = map['adId'] as string;
    return AdWrapperManager.getInstance().getAd(targetAdId);
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
      slot.ad = new AMPSNativeAd(mWindow.getUIContext(), adOption, this.buildLoadCallback(instanceId, slot));
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
