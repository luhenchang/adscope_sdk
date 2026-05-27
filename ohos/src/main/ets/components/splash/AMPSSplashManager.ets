import { Any, MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AMPSAdCallBackChannelMethod,
  AMPSAdSdkMethodNames,
  SPLASH_BOTTOM,
  SPLASH_INSTANCE_ID,
} from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { ampsAd, AMPSSplashAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { SplashBottomModule } from '../splash/SplashBottomModule';
import { window } from '@kit.ArkUI';

export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined = wrapBuilder(SplashBottomBuilder);

export class AMPSSplashManager {
  private static instance: AMPSSplashManager;
  private mWindowStage?: window.WindowStage;
  private mWindow?: window.Window;
  private splashAds: Map<string, AMPSSplashAd> = new Map();
  private splashBottomById: Map<string, SplashBottomModule> = new Map();
  static currentShowInstanceId?: string;

  public static getInstance(): AMPSSplashManager {
    if (!AMPSSplashManager.instance) {
      AMPSSplashManager.instance = new AMPSSplashManager();
    }
    return AMPSSplashManager.instance;
  }

  getSplashAd(instanceId?: string): AMPSSplashAd | undefined {
    if (instanceId) {
      return this.splashAds.get(instanceId);
    }
    const keys = Array.from(this.splashAds.keys());
    if (keys.length === 0) {
      return undefined;
    }
    return this.splashAds.get(keys[keys.length - 1]);
  }

  static getBottomModuleForCurrentShow(): SplashBottomModule | undefined {
    if (!AMPSSplashManager.currentShowInstanceId) {
      return undefined;
    }
    return AMPSSplashManager.getInstance().splashBottomById.get(AMPSSplashManager.currentShowInstanceId);
  }

  private cleanUp(instanceId: string) {
    this.splashAds.delete(instanceId);
    this.splashBottomById.delete(instanceId);
    if (AMPSSplashManager.currentShowInstanceId === instanceId) {
      AMPSSplashManager.currentShowInstanceId = undefined;
    }
  }

  private extractInstanceId(args: ESObject): string | undefined {
    if (args === null || args === undefined) {
      return undefined;
    }
    const map = args as Record<string, Object>;
    const id = map[SPLASH_INSTANCE_ID];
    return typeof id === 'string' ? id : undefined;
  }

  private createCallback(instanceId: string): ampsAd.CallBack {
    return {
      onLoadSuccess: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onLoadSuccess),
      onLoadFailure: (code: number, message: string): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onLoadFailure, { code, message }),
      onRenderOk: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onRenderOk),
      onAdShow: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onAdShow),
      onAdExposure: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onAdExposure),
      onAdClicked: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onAdClicked),
      onAdClosed: (): void => {
        this.cleanUp(instanceId);
        this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onAdClosed);
      },
      onRenderFailure: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onRenderFailure),
      onAdShowError: (code: number, message: string): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onAdShowError, { code, message }),
      onVideoPlayStart: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onVideoPlayStart),
      onVideoPlayEnd: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onVideoPlayEnd),
      onVideoPlayError: (code: number, message: string): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onVideoPlayError, { code, message }),
      onVideoSkipToEnd: (playDurationMs?: number): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs }),
      onAdReward: (): void =>
      this.sendMessage(instanceId, AMPSAdCallBackChannelMethod.onAdReward),
    };
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const instanceId = this.extractInstanceId(call.args);
    switch (call.method) {
      case AMPSAdSdkMethodNames.splashCreate:
        this.handleSplashCreate(call, result);
        break;
      case AMPSAdSdkMethodNames.splashLoad:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'splashInstanceId is required', undefined);
          return;
        }
        this.handleSplashLoad(instanceId, call, result);
        break;
      case AMPSAdSdkMethodNames.splashShowAd:
        if (!instanceId) {
          result.error('INVALID_ARGS', 'splashInstanceId is required', undefined);
          return;
        }
        this.handleSplashShowAd(instanceId, result, call.args);
        break;
      case AMPSAdSdkMethodNames.splashGetECPM:
        result.success(this.splashAds.get(instanceId ?? '')?.getECPM() ?? 0);
        break;
      case AMPSAdSdkMethodNames.splashIsReadyAd:
        result.success(this.splashAds.get(instanceId ?? '')?.isReadyAd() ?? false);
        break;
      case AMPSAdSdkMethodNames.splashDestroy:
        if (instanceId) {
          this.cleanUp(instanceId);
        }
        result.success(null);
        break;
      default:
        result.success(null);
    }
  }

  private handleSplashLoad(instanceId: string, call: MethodCall, result: MethodResult): void {
    try {
      const ad = this.splashAds.get(instanceId);
      if (!ad) {
        this.handleSplashCreate(call, result);
      }
      this.splashAds.get(instanceId)?.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleSplashCreate(call: MethodCall, result: MethodResult): void {
    try {
      const instanceId = this.extractInstanceId(call.args);
      if (!instanceId) {
        result.error('INVALID_ARGS', 'splashInstanceId is required', undefined);
        return;
      }
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(call.args);
      adOption.adCount = 1;
      const context = AMPSEventManager.getInstance().getContext();
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        this.mWindow = this.mWindowStage.getMainWindowSync();
        if (this.mWindow) {
          this.splashAds.set(
            instanceId,
            new AMPSSplashAd(adOption, this.createCallback(instanceId), this.mWindow.getUIContext()),
          );
        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
          return;
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
        return;
      }
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private resolveBottomArgs(args: Any): Any {
    if (args === null || args === undefined) {
      return args;
    }
    const map = args as Record<string, Object>;
    const nested = map[SPLASH_BOTTOM];
    if (nested !== undefined) {
      return nested;
    }
    return args;
  }

  private handleSplashShowAd(instanceId: string, result: MethodResult, args: Any): void {
    try {
      const splashAd = this.splashAds.get(instanceId);
      if (splashAd && this.mWindowStage) {
        AMPSSplashManager.currentShowInstanceId = instanceId;
        this.splashBottomById.set(instanceId, new SplashBottomModule(this.resolveBottomArgs(args)));
        splashAd.showAd({ windowStage: this.mWindowStage, bottomWrappedBuilder: globalSplashBottomBuilder });
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
    payload[SPLASH_INSTANCE_ID] = instanceId;
    if (args !== null && args !== undefined) {
      const extra = args as Record<string, Object>;
      Object.keys(extra).forEach((key: string) => {
        payload[key] = extra[key];
      });
    }
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload);
  }
}

@Builder
export function SplashBottomBuilder() {
  const bottomModule = AMPSSplashManager.getBottomModuleForCurrentShow();
  if (bottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${bottomModule?.imgChildren?.imagePath}`))
        .width(bottomModule?.imgChildren?.width)
        .height(bottomModule?.imgChildren?.height)
        .offset({
          x: bottomModule?.imgChildren?.x,
          y: bottomModule?.imgChildren?.y,
        });
      Text(bottomModule?.textChildren?.text)
        .fontColor(bottomModule?.textChildren?.color)
        .offset({
          x: bottomModule?.textChildren?.x,
          y: bottomModule?.textChildren?.y,
        });
    }
    .backgroundColor(bottomModule?.backgroundColor)
    .height(bottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart);
  }
}
