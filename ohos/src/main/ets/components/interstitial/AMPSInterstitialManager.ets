import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  AD_INSTANCE_ID,
  AMPSInterstitialAdCallBackChannelMethod,
  AMPSAdSdkMethodNames
} from '../common/common';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { ampsAd, AMPSInterstitialAd } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { window } from '@kit.ArkUI';

class InterstitialCallbackPayload {
  adInstanceId: string = ''
  code?: number = undefined
  message?: string = undefined
  playDurationMs?: number = undefined
}

class InterstitialShowAdOptions {
  windowStage: window.WindowStage
  uiContext: UIContext

  constructor(windowStage: window.WindowStage, uiContext: UIContext) {
    this.windowStage = windowStage
    this.uiContext = uiContext
  }
}

export class AMPSInterstitialManager {
  private static instance: AMPSInterstitialManager;
  private interstitialAds: Map<string, AMPSInterstitialAd> = new Map<string, AMPSInterstitialAd>()

  public static getInstance(): AMPSInterstitialManager {
    if (!AMPSInterstitialManager.instance) {
      AMPSInterstitialManager.instance = new AMPSInterstitialManager();
    }
    return AMPSInterstitialManager.instance;
  }

  getInterstitialAd(instanceId?: string): AMPSInterstitialAd | undefined {
    if (instanceId) {
      return this.interstitialAds.get(instanceId)
    }
    let latestInterstitialAd: AMPSInterstitialAd | undefined = undefined
    this.interstitialAds.forEach((value: AMPSInterstitialAd) => {
      latestInterstitialAd = value
    })
    return latestInterstitialAd
  }

  private argsAsMap(args: Object | undefined): Map<string, Object> | undefined {
    return args as Map<string, Object> | undefined
  }

  private extractInstanceId(args: Map<string, Object> | undefined): string | undefined {
    return args?.get(AD_INSTANCE_ID) as string | undefined
  }

  private requireInstanceId(instanceId: string | undefined, result: MethodResult): string | undefined {
    if (!instanceId) {
      result.error('INVALID_ARGS', 'adInstanceId is required', undefined)
      return undefined
    }
    return instanceId
  }

  private cleanUp(instanceId: string) {
    this.interstitialAds.delete(instanceId)
  }

  private releaseInterstitialAd(instanceId: string) {
    this.cleanUp(instanceId)
  }

  private createPayload(instanceId: string): InterstitialCallbackPayload {
    const payload = new InterstitialCallbackPayload()
    payload.adInstanceId = instanceId
    return payload
  }

  private createErrorPayload(instanceId: string, code: number, message: string): InterstitialCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.code = code
    payload.message = message
    return payload
  }

  private createVideoSkipPayload(instanceId: string, playDurationMs?: number): InterstitialCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.playDurationMs = playDurationMs
    return payload
  }

  private createCallBack(instanceId: string): ampsAd.CallBack {
    return {
      onLoadSuccess: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onLoadSuccess),
      onLoadFailure: (code: number, message: string) =>
        this.sendPayload(AMPSInterstitialAdCallBackChannelMethod.onLoadFailure, this.createErrorPayload(instanceId, code, message)),
      onRenderOk: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onRenderOk),
      onAdShow: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdShow),
      onAdExposure: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdExposure),
      onAdClicked: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdClicked),
      onAdClosed: () => {
        this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdClosed)
        this.cleanUp(instanceId)
      },
      onRenderFailure: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onRenderFailure),
      onAdShowError: (code: number, message: string) =>
        this.sendPayload(AMPSInterstitialAdCallBackChannelMethod.onAdShowError, this.createErrorPayload(instanceId, code, message)),
      onVideoPlayStart: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onVideoPlayStart),
      onVideoPlayEnd: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onVideoPlayEnd),
      onVideoPlayError: (code: number, message: string) =>
        this.sendPayload(AMPSInterstitialAdCallBackChannelMethod.onVideoPlayError, this.createErrorPayload(instanceId, code, message)),
      onVideoSkipToEnd: (playDurationMs?: number) =>
        this.sendPayload(AMPSInterstitialAdCallBackChannelMethod.onVideoSkipToEnd, this.createVideoSkipPayload(instanceId, playDurationMs)),
      onAdReward: () => this.sendMessage(instanceId, AMPSInterstitialAdCallBackChannelMethod.onAdReward)
    }
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const args = this.argsAsMap(call.args as Object | undefined)
    const instanceId = this.extractInstanceId(args)
    switch (call.method) {
      case AMPSAdSdkMethodNames.interstitialCreate:
        this.handleCreate(call, result)
        break;
      case AMPSAdSdkMethodNames.interstitialPreLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handlePreLoadAd(requiredInstanceId, result);
        }
        break;
      case AMPSAdSdkMethodNames.interstitialLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleLoadAd(requiredInstanceId, result);
        }
        break;
      case AMPSAdSdkMethodNames.interstitialShowAd:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleShowAd(requiredInstanceId, result);
        }
        break;
      case AMPSAdSdkMethodNames.interstitialGetECPM:
        const mEcpm = instanceId ? (this.interstitialAds.get(instanceId)?.getECPM() ?? 0) : 0
        result.success(mEcpm);
        break;
      case AMPSAdSdkMethodNames.interstitialAddPreLoadAdInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.interstitialGetMediaExtraInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.interstitialIsReadyAd:
        result.success(instanceId ? (this.interstitialAds.get(instanceId)?.isReadyAd() ?? false) : false);
        break;
      case AMPSAdSdkMethodNames.interstitialDestroy:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.releaseInterstitialAd(requiredInstanceId)
        }
        result.success(null)
        break;
      default:
        result.success(null);
    }
  }
  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const args = this.argsAsMap(call.args as Object | undefined)
      const instanceId = this.extractInstanceId(args)
      if (!args || !instanceId) {
        result.error('INVALID_ARGS', 'adInstanceId is required', undefined);
        return
      }
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(args);
      this.releaseInterstitialAd(instanceId)
      this.interstitialAds.set(instanceId, new AMPSInterstitialAd(adOption, this.createCallBack(instanceId)));
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
      return
    }
    result.success(true)
  }
  // 处理开屏广告加载
  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const interstitialAd = this.interstitialAds.get(instanceId)
      if (!interstitialAd) {
        result.error('LOAD_FAILED', `Interstitial ad instance not found: ${instanceId}`, undefined);
        return
      }
      interstitialAd.load();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }
  private handlePreLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const interstitialAd = this.interstitialAds.get(instanceId)
      if (!interstitialAd) {
        result.error('LOAD_FAILED', `Interstitial ad instance not found: ${instanceId}`, undefined);
        return
      }
      interstitialAd.preloadAd();
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`,undefined);
    }
    result.success(true)
  }

  // 处理开屏广告显示
  private handleShowAd(instanceId: string, result: MethodResult): void {
    try {
      let context = AMPSEventManager.getInstance().getContext()
      const interstitialAd = this.interstitialAds.get(instanceId)
      if (interstitialAd && context) {
        const showOptions = new InterstitialShowAdOptions(context.windowStage, context.windowStage.getMainWindowSync().getUIContext())
        interstitialAd.showAd(showOptions)
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在',undefined);
        return
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`,undefined);
      return
    }
    result.success(true);
  }

  private sendPayload(method: string, payload: InterstitialCallbackPayload): void {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload as ESObject)
  }

  private sendMessage(instanceId: string, method: string): void {
    this.sendPayload(method, this.createPayload(instanceId))
  }
}