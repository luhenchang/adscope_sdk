import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSNativeAd,
  AMPSNativeAdListener,
  AMPSNativeAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSNativeRenderListener
} from 'xyz.adscope.amps';
import {
  AD_ID,
  AD_INSTANCE_ID,
  AMPSAdSdkMethodNames,
  AMPSNativeCallBackChannelMethod
} from '../common/common';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AdWrapperManager } from '../native/AdWrapperManager';
import { AMPSEventManager } from '../common/AMPSEventManager';

class NativeCallbackPayload {
  adInstanceId: string = ''
  adId?: string = undefined
  adIds?: Array<string> = undefined
  code?: number = undefined
  message?: string = undefined
  extra?: string = undefined
}

export class AMPSNativeManager {
  private static instance: AMPSNativeManager;
  private static adIdCounter: number = 0
  private mWindowStage?: window.WindowStage;
  private nativeAds: Map<string, AMPSNativeAd> = new Map<string, AMPSNativeAd>()
  private adIdsByInstance: Map<string, Array<string>> = new Map<string, Array<string>>()

  public static getInstance(): AMPSNativeManager {
    if (!AMPSNativeManager.instance) {
      AMPSNativeManager.instance = new AMPSNativeManager();
    }
    return AMPSNativeManager.instance;
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const args = this.argsAsMap(call.args as Object | undefined)
    const instanceId = this.extractInstanceId(args)
    switch (call.method) {
      case AMPSAdSdkMethodNames.nativeCreate:
        this.handleCreate(call, result)
        break
      case AMPSAdSdkMethodNames.nativeLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleLoadAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.nativeGetECPM:
        result.success(this.getAdWrapper(args)?.getECPM() ?? 0)
        break;
      case AMPSAdSdkMethodNames.nativePattern:
      case AMPSAdSdkMethodNames.nativeUnifiedMaterialType:
        result.success(this.getUnifiedPattern(this.getAdWrapper(args)))
        break;
      case AMPSAdSdkMethodNames.nativeIsReadyAd:
        result.success(instanceId ? (this.nativeAds.get(instanceId)?.isReadyAd() ?? false) : false)
        break;
      case AMPSAdSdkMethodNames.nativeIsNativeExpress:
        result.success(this.getAdWrapper(args)?.isNativeExpress() ?? false)
        break;
      case AMPSAdSdkMethodNames.nativeGetVideoDuration:
        result.success(this.getAdWrapper(args)?.getVideoDuration() ?? 0)
        break;
      case AMPSAdSdkMethodNames.nativeUnifiedGetDownLoad:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.nativeGetMediaExtraInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.nativeDestroy:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.releaseNativeAd(requiredInstanceId)
        }
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.nativeResume:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.nativePause:
        result.success(null)
        break;
      default:
        result.success(null);
    }
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

  private getAdWrapper(args: Map<string, Object> | undefined): AMPSNativeAdWrapper | undefined {
    const targetAdId = args?.get(AD_ID) as string | undefined
    if (!targetAdId) {
      return undefined
    }
    return AdWrapperManager.getInstance().getAd(targetAdId)
  }

  private generateAdId(instanceId: string): string {
    AMPSNativeManager.adIdCounter += 1
    return `${instanceId}_${AMPSNativeManager.adIdCounter}_${Date.now()}`
  }

  private createPayload(instanceId: string): NativeCallbackPayload {
    const payload = new NativeCallbackPayload()
    payload.adInstanceId = instanceId
    return payload
  }

  private createAdPayload(instanceId: string, adId: string): NativeCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.adId = adId
    return payload
  }

  private createAdIdsPayload(instanceId: string, adIds: Array<string>): NativeCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.adIds = adIds
    return payload
  }

  private createErrorPayload(instanceId: string, code: number, message: string): NativeCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.code = code
    payload.message = message
    return payload
  }

  private createAdErrorPayload(instanceId: string, adId: string, code?: number, message?: string, extra?: string): NativeCallbackPayload {
    const payload = this.createAdPayload(instanceId, adId)
    payload.code = code
    payload.message = message
    payload.extra = extra
    return payload
  }

  private clearWrapperByAdId(adId: string): void {
    AdWrapperManager.getInstance().getAd(adId)?.destroy()
    AdWrapperManager.getInstance().removeAd(adId)
  }

  private clearInstanceWrappers(instanceId: string): void {
    const adIds = this.adIdsByInstance.get(instanceId)
    if (!adIds) {
      return
    }
    adIds.forEach((adId: string) => {
      this.clearWrapperByAdId(adId)
    })
    this.adIdsByInstance.delete(instanceId)
  }

  private removeInstanceAdId(instanceId: string, adId: string): void {
    const adIds = this.adIdsByInstance.get(instanceId)
    if (!adIds) {
      return
    }
    const nextAdIds = adIds.filter((item: string) => item !== adId)
    if (nextAdIds.length === 0) {
      this.adIdsByInstance.delete(instanceId)
    } else {
      this.adIdsByInstance.set(instanceId, nextAdIds)
    }
  }

  private releaseNativeAd(instanceId: string): void {
    this.clearInstanceWrappers(instanceId)
    this.nativeAds.delete(instanceId)
  }

  private getUnifiedPattern(wrapper?: AMPSNativeAdWrapper): number {
    if (!wrapper) {
      return 3
    }
    if (wrapper.getVideoUrl()) {
      return 2
    }
    return 0
  }

  private createInteractiveCallback(instanceId: string, adId: string): AMPSNativeInteractiveListener {
    return {
      onAdShow: (): void => {
        this.sendPayload(AMPSNativeCallBackChannelMethod.onAdShow, this.createAdPayload(instanceId, adId))
      },
      onAdExposure: (): void => {
        this.sendPayload(AMPSNativeCallBackChannelMethod.onAdExposure, this.createAdPayload(instanceId, adId))
      },
      onAdClicked: (): void => {
        this.sendPayload(AMPSNativeCallBackChannelMethod.onAdClicked, this.createAdPayload(instanceId, adId))
      },
      toCloseAd: (): void => {
        this.clearWrapperByAdId(adId)
        this.removeInstanceAdId(instanceId, adId)
        this.sendPayload(AMPSNativeCallBackChannelMethod.onAdClosed, this.createAdPayload(instanceId, adId))
      }
    }
  }

  private createRenderCallback(instanceId: string, adId: string): AMPSNativeRenderListener {
    return {
      renderSuccess: (adWrapper: AMPSNativeAdWrapper): void => {
        AdWrapperManager.getInstance().addAd(adId, adWrapper)
        adWrapper.interactCallBack = this.createInteractiveCallback(instanceId, adId)
        adWrapper.videoPlayCallBack = {
          onVideoReady: () => {
            this.sendPayload(AMPSNativeCallBackChannelMethod.onVideoReady, this.createAdPayload(instanceId, adId))
          },
          onVideoPlayStart: () => {
            this.sendPayload(AMPSNativeCallBackChannelMethod.onVideoPlayStart, this.createAdPayload(instanceId, adId))
          },
          onVideoPlayComplete: () => {
            this.sendPayload(AMPSNativeCallBackChannelMethod.onVideoPlayComplete, this.createAdPayload(instanceId, adId))
          },
          onVideoPause: () => {
            this.sendPayload(AMPSNativeCallBackChannelMethod.onVideoPause, this.createAdPayload(instanceId, adId))
          },
          onVideoResume: () => {
            this.sendPayload(AMPSNativeCallBackChannelMethod.onVideoResume, this.createAdPayload(instanceId, adId))
          },
          onVideoPlayError: (code: number, extra: string) => {
            this.sendPayload(
              AMPSNativeCallBackChannelMethod.onVideoPlayError,
              this.createAdErrorPayload(instanceId, adId, code, undefined, extra)
            )
          }
        }
        this.sendPayload(AMPSNativeCallBackChannelMethod.renderSuccess, this.createAdPayload(instanceId, adId))
      },
      renderFailed: (): void => {
        this.sendPayload(AMPSNativeCallBackChannelMethod.renderFailed, this.createAdPayload(instanceId, adId))
      }
    }
  }

  private createLoadCallback(instanceId: string): AMPSNativeAdListener {
    return {
      loadOk: (adItems: AMPSNativeAdWrapper[]): void => {
        this.clearInstanceWrappers(instanceId)
        const adIdList: Array<string> = []
        adItems.forEach((item: AMPSNativeAdWrapper) => {
          const adId = this.generateAdId(instanceId)
          adIdList.push(adId)
          AdWrapperManager.getInstance().addAd(adId, item)
          item.renderCallBack = this.createRenderCallback(instanceId, adId)
          item.renderAd()
        })
        this.adIdsByInstance.set(instanceId, adIdList)
        this.sendPayload(AMPSNativeCallBackChannelMethod.loadOk, this.createAdIdsPayload(instanceId, adIdList))
      },
      loadFail: (code: number, message: string): void => {
        this.sendPayload(AMPSNativeCallBackChannelMethod.loadFail, this.createErrorPayload(instanceId, code, message))
      }
    }
  }

  private handleCreate(call: MethodCall, result: MethodResult): void {
    try {
      const args = this.argsAsMap(call.args as Object | undefined)
      const instanceId = this.extractInstanceId(args)
      if (!args || !instanceId) {
        result.error('INVALID_ARGS', 'adInstanceId is required', undefined)
        return
      }
      const adOption: ampsAd.AdOptions = AdOptionsModule.getAdOptionFromMap(args)
      const context = AMPSEventManager.getInstance().getContext()
      this.mWindowStage = context?.windowStage
      if (!this.mWindowStage) {
        result.error('LOAD_FAILED', 'WindowStage未初始化', undefined)
        return
      }
      const mWindow = this.mWindowStage.getMainWindowSync()
      this.releaseNativeAd(instanceId)
      this.nativeAds.set(instanceId, new AMPSNativeAd(mWindow.getUIContext(), adOption, this.createLoadCallback(instanceId)))
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const nativeAd = this.nativeAds.get(instanceId)
      if (!nativeAd) {
        result.error('LOAD_FAILED', `Native ad instance not found: ${instanceId}`, undefined)
        return
      }
      nativeAd.load()
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private sendPayload(method: string, payload: NativeCallbackPayload): void {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload as ESObject)
  }
}

