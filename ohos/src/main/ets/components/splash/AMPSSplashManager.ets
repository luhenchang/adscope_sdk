import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AMPSAdSdkMethodNames,
  AMPSSplashAdCallBackChannelMethod,
  SPLASH_BOTTOM,
  SPLASH_INSTANCE_ID
} from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { ampsAd, AMPSSplashAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { SplashBottomImageChild, SplashBottomModule, SplashBottomTextChild } from '../splash/SplashBottomModule';
import { window } from '@kit.ArkUI';

export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(SplashBottomBuilder);

class SplashCallbackPayload {
  splashInstanceId: string = ''
  code?: number = undefined
  message?: string = undefined
  playDurationMs?: number = undefined
}

class SplashShowAdOptions {
  windowStage: window.WindowStage
  bottomWrappedBuilder?: WrappedBuilder<[]> = undefined

  constructor(windowStage: window.WindowStage, bottomWrappedBuilder?: WrappedBuilder<[]>) {
    this.windowStage = windowStage
    this.bottomWrappedBuilder = bottomWrappedBuilder
  }
}

export class AMPSSplashManager {
  private static instance: AMPSSplashManager;
  private mWindowStage?: window.WindowStage;
  private mWindow?: window.Window;
  private splashAds: Map<string, AMPSSplashAd> = new Map<string, AMPSSplashAd>();
  private splashBottomModules: Map<string, SplashBottomModule> = new Map<string, SplashBottomModule>();
  private currentShowingInstanceId?: string;

  public static getInstance(): AMPSSplashManager {
    if (!AMPSSplashManager.instance) {
      AMPSSplashManager.instance = new AMPSSplashManager();
    }
    return AMPSSplashManager.instance;
  }

  getSplashAd(instanceId?: string): AMPSSplashAd | undefined {
    if (instanceId) {
      return this.splashAds.get(instanceId)
    }
    let latestSplashAd: AMPSSplashAd | undefined = undefined
    this.splashAds.forEach((value: AMPSSplashAd) => {
      latestSplashAd = value
    })
    return latestSplashAd
  }

  getCurrentSplashBottomModule(): SplashBottomModule | undefined {
    if (!this.currentShowingInstanceId) {
      return undefined
    }
    return this.splashBottomModules.get(this.currentShowingInstanceId)
  }

  private argsAsMap(args: Object | undefined): Map<string, Object> | undefined {
    return args as Map<string, Object> | undefined
  }

  private extractInstanceId(args: Map<string, Object> | undefined): string | undefined {
    return args?.get(SPLASH_INSTANCE_ID) as string | undefined
  }

  private requireInstanceId(instanceId: string | undefined, result: MethodResult): string | undefined {
    if (!instanceId) {
      result.error('INVALID_ARGS', 'splashInstanceId is required', undefined)
      return undefined
    }
    return instanceId
  }

  private resolveBottomModule(args: Map<string, Object> | undefined): SplashBottomModule | undefined {
    if (!args) {
      return undefined
    }
    let bottomMap = args.get(SPLASH_BOTTOM) as Map<string, Object> | undefined
    if (!bottomMap && args.get('type') === 'parent') {
      bottomMap = args
    }
    if (!bottomMap) {
      return undefined
    }
    const module = new SplashBottomModule(bottomMap)
    return module.initialized ? module : undefined
  }

  private cleanUp(instanceId: string) {
    this.splashAds.delete(instanceId)
    this.splashBottomModules.delete(instanceId)
    if (this.currentShowingInstanceId === instanceId) {
      this.currentShowingInstanceId = undefined
    }
  }

  private releaseSplashAd(instanceId: string) {
    this.cleanUp(instanceId)
  }

  private createPayload(instanceId: string): SplashCallbackPayload {
    const payload = new SplashCallbackPayload()
    payload.splashInstanceId = instanceId
    return payload
  }

  private createErrorPayload(instanceId: string, code: number, message: string): SplashCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.code = code
    payload.message = message
    return payload
  }

  private createVideoSkipPayload(instanceId: string, playDurationMs?: number): SplashCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.playDurationMs = playDurationMs
    return payload
  }

  private createCallBack(instanceId: string): ampsAd.CallBack {
    return {
      onLoadSuccess: () => {
        this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onLoadSuccess)
      },
      onLoadFailure: (code: number, message: string) =>
        this.sendPayload(AMPSSplashAdCallBackChannelMethod.onLoadFailure, this.createErrorPayload(instanceId, code, message)),
      onRenderOk: () => {
        this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onRenderOk)
      },
      onAdShow: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onAdShow),
      onAdExposure: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onAdExposure),
      onAdClicked: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onAdClicked),
      onAdClosed: () => {
        this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onAdClosed)
        this.cleanUp(instanceId)
      },
      onRenderFailure: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onRenderFailure),
      onAdShowError: (code: number, message: string) =>
        this.sendPayload(AMPSSplashAdCallBackChannelMethod.onAdShowError, this.createErrorPayload(instanceId, code, message)),
      onVideoPlayStart: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onVideoPlayStart),
      onVideoPlayEnd: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onVideoPlayEnd),
      onVideoPlayError: (code: number, message: string) =>
        this.sendPayload(AMPSSplashAdCallBackChannelMethod.onVideoPlayError, this.createErrorPayload(instanceId, code, message)),
      onVideoSkipToEnd: (playDurationMs?: number) =>
        this.sendPayload(AMPSSplashAdCallBackChannelMethod.onVideoSkipToEnd, this.createVideoSkipPayload(instanceId, playDurationMs)),
      onAdReward: () => this.sendMessage(instanceId, AMPSSplashAdCallBackChannelMethod.onAdReward)
    }
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const args = this.argsAsMap(call.args as Object | undefined)
    const instanceId = this.extractInstanceId(args)
    switch (call.method) {
      case AMPSAdSdkMethodNames.splashCreate:
        this.handleSplashCreate(call, result)
        break
      case AMPSAdSdkMethodNames.splashLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleSplashLoad(requiredInstanceId, result);
        }
        break;
      case AMPSAdSdkMethodNames.splashPreLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleSplashPreLoad(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.splashShowAd:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleSplashShowAd(requiredInstanceId, args, result);
        }
        break;
      case AMPSAdSdkMethodNames.splashGetECPM:
        const mEcpm = instanceId ? (this.splashAds.get(instanceId)?.getECPM() ?? 0) : 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.splashGetSeatId:
        const mSeatId = instanceId ? (this.splashAds.get(instanceId)?.getSeatID() ?? '') : ''
        result.success(mSeatId);
        break;
      case AMPSAdSdkMethodNames.splashIsReadyAd:
        result.success(instanceId ? (this.splashAds.get(instanceId)?.isReadyAd() ?? false) : false);
        break;
      case AMPSAdSdkMethodNames.splashDestroy:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.releaseSplashAd(requiredInstanceId)
        }
        result.success(null)
        break;
      default:
        result.success(null);
    }
  }

  // 处理开屏广告加载
  private handleSplashPreLoad(instanceId: string, result: MethodResult): void {
    try {
      const splashAd = this.splashAds.get(instanceId)
      if (!splashAd) {
        result.error('LOAD_FAILED', `Splash ad instance not found: ${instanceId}`, undefined);
        return
      }
      splashAd.preloadAd()
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  // 处理开屏广告加载
  private handleSplashLoad(instanceId: string, result: MethodResult): void {
    try {
      const splashAd = this.splashAds.get(instanceId)
      if (!splashAd) {
        result.error('LOAD_FAILED', `Splash ad instance not found: ${instanceId}`, undefined);
        return
      }
      splashAd.load();
      result.success(true);
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private handleSplashCreate(call: MethodCall, result: MethodResult): void {
    try {
      const args = this.argsAsMap(call.args)
      const instanceId = this.extractInstanceId(args)
      if (!args || !instanceId) {
        result.error('INVALID_ARGS', 'splashInstanceId is required', undefined);
        return
      }

      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(args);
      adOption.adCount = 1
      let context = AMPSEventManager.getInstance().getContext()
      this.mWindowStage = context?.windowStage;
      if (this.mWindowStage) {
        this.mWindow = this.mWindowStage.getMainWindowSync();
        if (this.mWindow) {
          this.releaseSplashAd(instanceId)
          this.splashAds.set(instanceId, new AMPSSplashAd(adOption, this.createCallBack(instanceId), this.mWindow.getUIContext()));
          result.success(true);
        } else {
          result.error('LOAD_FAILED', '获取窗口或UI上下文失败', undefined);
          return
        }
      } else {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined);
        return
      }
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined);
      return
    }
  }

  // 处理开屏广告显示
  private handleSplashShowAd(instanceId: string, args: Map<string, Object> | undefined, result: MethodResult): void {
    try {
      const splashAd = this.splashAds.get(instanceId)
      const context = AMPSEventManager.getInstance().getContext()
      const windowStage = context?.windowStage ?? this.mWindowStage
      if (splashAd && windowStage) {
        const splashBottomModule = this.resolveBottomModule(args)
        this.currentShowingInstanceId = instanceId
        if (splashBottomModule) {
          this.splashBottomModules.set(instanceId, splashBottomModule)
        } else {
          this.splashBottomModules.delete(instanceId)
        }
        const showOptions = new SplashShowAdOptions(windowStage, globalSplashBottomBuilder)
        splashAd.showAd(showOptions);
        result.success(true);
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined);
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined);
    }
  }

  private sendPayload(method: string, payload: SplashCallbackPayload): void {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload as ESObject)
  }

  private sendMessage(instanceId: string, method: string): void {
    this.sendPayload(method, this.createPayload(instanceId))
  }
}

@Builder
export function SplashBottomBuilder() {
  if (AMPSSplashManager.getInstance().getCurrentSplashBottomModule()?.initialized) {
    Stack() {
      ForEach(AMPSSplashManager.getInstance().getCurrentSplashBottomModule()?.textChildrens ?? [], (item: SplashBottomTextChild) => {
        Text(item?.text)
          .fontColor(item?.color)
          .fontSize(item?.fontSize)
          .offset({
            x: item?.x,
            y: item?.y
          })
      })
      ForEach(AMPSSplashManager.getInstance().getCurrentSplashBottomModule()?.imgChildrens ?? [], (imgItem: SplashBottomImageChild) => {
        Image($rawfile(`flutter_assets/${imgItem.imagePath}`))
          .width(imgItem?.width)
          .height(imgItem?.height)
          .offset({
            x: imgItem?.x,
            y: imgItem?.y
          })
      })
    }
    .backgroundColor(AMPSSplashManager.getInstance().getCurrentSplashBottomModule()?.backgroundColor)
    .height(AMPSSplashManager.getInstance().getCurrentSplashBottomModule()?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}