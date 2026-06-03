import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import {
  ampsAd,
  AMPSDrawAd,
  AMPSDrawAdListener,
  AMPSDrawAdWrapper,
  AMPSNativeInteractiveListener,
  AMPSDrawRenderListener
} from 'xyz.adscope.amps';
import {
  AD_ID,
  AD_INSTANCE_ID,
  AMPSAdSdkMethodNames,
  AmpsDrawCallbackChannelMethod
} from '../common/common';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { window } from '@kit.ArkUI';
import { AMPSEventManager } from '../common/AMPSEventManager';

class DrawCallbackPayload {
  adInstanceId: string = ''
  adId?: string = undefined
  adIds?: Array<string> = undefined
  code?: number = undefined
  message?: string = undefined
  current?: number = undefined
  duration?: number = undefined
}

export class AMPSDrawAdManager {
  private static instance: AMPSDrawAdManager;
  private static adIdCounter: number = 0
  private mWindowStage?: window.WindowStage;
  private drawAds: Map<string, AMPSDrawAd> = new Map<string, AMPSDrawAd>()
  private drawItems: Map<string, AMPSDrawAdWrapper> = new Map<string, AMPSDrawAdWrapper>()
  private adIdsByInstance: Map<string, Array<string>> = new Map<string, Array<string>>()

  public static getInstance(): AMPSDrawAdManager {
    if (!AMPSDrawAdManager.instance) {
      AMPSDrawAdManager.instance = new AMPSDrawAdManager();
    }
    return AMPSDrawAdManager.instance;
  }

  getAdItem(adId: string): AMPSDrawAdWrapper | undefined {
    return this.drawItems.get(adId)
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const args = this.argsAsMap(call.args as Object | undefined)
    const instanceId = this.extractInstanceId(args)
    switch (call.method) {
      case AMPSAdSdkMethodNames.drawCreate:
        this.handleCreate(call, result)
        break
      case AMPSAdSdkMethodNames.drawLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleLoadAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.drawGetEcpm:
        result.success(this.getAdWrapper(args)?.getECPM() ?? 0)
        break;
      case AMPSAdSdkMethodNames.drawGetSeatId:
        result.success(instanceId ? (this.drawAds.get(instanceId)?.getSeatID() ?? '') : '')
        break;
      case AMPSAdSdkMethodNames.drawIsReadyAd:
        result.success(instanceId ? (this.drawAds.get(instanceId)?.isReadyAd() ?? false) : false)
        break;
      case AMPSAdSdkMethodNames.drawPauseAd:
        result.success(null);
        break;
      case AMPSAdSdkMethodNames.drawResumeAd:
        result.success(null);
        break;
      case AMPSAdSdkMethodNames.drawGetMediaExtraInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.drawDestroyAd:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.releaseDrawAd(requiredInstanceId)
        }
        result.success(null);
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

  private getAdWrapper(args: Map<string, Object> | undefined): AMPSDrawAdWrapper | undefined {
    const targetAdId = args?.get(AD_ID) as string | undefined
    if (!targetAdId) {
      return undefined
    }
    return this.drawItems.get(targetAdId)
  }

  private generateAdId(instanceId: string): string {
    AMPSDrawAdManager.adIdCounter += 1
    return `${instanceId}_${AMPSDrawAdManager.adIdCounter}_${Date.now()}`
  }

  private createPayload(instanceId: string): DrawCallbackPayload {
    const payload = new DrawCallbackPayload()
    payload.adInstanceId = instanceId
    return payload
  }

  private createAdPayload(instanceId: string, adId: string): DrawCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.adId = adId
    return payload
  }

  private createAdIdsPayload(instanceId: string, adIds: Array<string>): DrawCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.adIds = adIds
    return payload
  }

  private createErrorPayload(instanceId: string, code: number, message: string): DrawCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.code = code
    payload.message = message
    return payload
  }

  private createAdErrorPayload(instanceId: string, adId: string, code?: number, message?: string): DrawCallbackPayload {
    const payload = this.createAdPayload(instanceId, adId)
    payload.code = code
    payload.message = message
    return payload
  }

  private createProgressPayload(instanceId: string, adId: string, current: number, duration: number): DrawCallbackPayload {
    const payload = this.createAdPayload(instanceId, adId)
    payload.current = current
    payload.duration = duration
    return payload
  }

  private clearWrapperByAdId(adId: string): void {
    this.drawItems.get(adId)?.destroy()
    this.drawItems.delete(adId)
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

  private releaseDrawAd(instanceId: string): void {
    this.clearInstanceWrappers(instanceId)
    this.drawAds.delete(instanceId)
  }

  private createInteractiveCallback(instanceId: string, adId: string): AMPSNativeInteractiveListener {
    return {
      onAdShow: (): void => {
        this.sendPayload(AmpsDrawCallbackChannelMethod.onAdShow, this.createAdPayload(instanceId, adId))
      },
      onAdExposure: (): void => {
        this.sendPayload(AmpsDrawCallbackChannelMethod.onAdShow, this.createAdPayload(instanceId, adId))
      },
      onAdClicked: (): void => {
        this.sendPayload(AmpsDrawCallbackChannelMethod.onAdClicked, this.createAdPayload(instanceId, adId))
      },
      toCloseAd: (): void => {
        this.clearWrapperByAdId(adId)
        this.removeInstanceAdId(instanceId, adId)
        this.sendPayload(AmpsDrawCallbackChannelMethod.onAdClosed, this.createAdPayload(instanceId, adId))
      }
    }
  }

  private createRenderCallback(instanceId: string, adId: string): AMPSDrawRenderListener {
    return {
      renderSuccess: (adWrapper: AMPSDrawAdWrapper): void => {
        this.drawItems.set(adId, adWrapper)
        adWrapper.interactCallBack = this.createInteractiveCallback(instanceId, adId)
        adWrapper.videoPlayCallBack = {
          onVideoReady: () => {
            this.sendPayload(AmpsDrawCallbackChannelMethod.onVideoLoad, this.createAdPayload(instanceId, adId))
          },
          onVideoPlayStart: () => {
            this.sendPayload(AmpsDrawCallbackChannelMethod.onVideoPlayStart, this.createAdPayload(instanceId, adId))
          },
          onVideoPause: () => {
            this.sendPayload(AmpsDrawCallbackChannelMethod.onVideoPlayPause, this.createAdPayload(instanceId, adId))
          },
          onVideoResume: () => {
            this.sendPayload(AmpsDrawCallbackChannelMethod.onVideoAdContinuePlay, this.createAdPayload(instanceId, adId))
          },
          onVideoPlayComplete: () => {
            this.sendPayload(AmpsDrawCallbackChannelMethod.onVideoAdComplete, this.createAdPayload(instanceId, adId))
          },
          onVideoPlayError: (code: number, message: string) => {
            this.sendPayload(
              AmpsDrawCallbackChannelMethod.onVideoError,
              this.createAdErrorPayload(instanceId, adId, code, message)
            )
          }
        }
        this.sendPayload(AmpsDrawCallbackChannelMethod.onRenderSuccess, this.createAdPayload(instanceId, adId))
      },
      renderFailed: (adWrapper: AMPSDrawAdWrapper): void => {
        this.sendPayload(AmpsDrawCallbackChannelMethod.onRenderFail, this.createAdPayload(instanceId, adId))
      }
    }
  }

  private createLoadCallback(instanceId: string): AMPSDrawAdListener {
    return {
      loadOk: (adItems: AMPSDrawAdWrapper[]): void => {
        this.clearInstanceWrappers(instanceId)
        const adIdList: Array<string> = []
        adItems.forEach((item: AMPSDrawAdWrapper) => {
          const adId = this.generateAdId(instanceId)
          adIdList.push(adId)
          this.drawItems.set(adId, item)
          item.renderCallBack = this.createRenderCallback(instanceId, adId)
          item.renderAd()
        })
        this.adIdsByInstance.set(instanceId, adIdList)
        this.sendPayload(AmpsDrawCallbackChannelMethod.onLoadSuccess, this.createAdIdsPayload(instanceId, adIdList))
      },
      loadFail: (code: number, message: string): void => {
        this.sendPayload(AmpsDrawCallbackChannelMethod.onLoadFailure, this.createErrorPayload(instanceId, code, message))
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
      this.releaseDrawAd(instanceId)
      this.drawAds.set(instanceId, new AMPSDrawAd(mWindow.getUIContext(), adOption, this.createLoadCallback(instanceId)))
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const drawAd = this.drawAds.get(instanceId)
      if (!drawAd) {
        result.error('LOAD_FAILED', `Draw ad instance not found: ${instanceId}`, undefined)
        return
      }
      drawAd.load()
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private sendPayload(method: string, payload: DrawCallbackPayload): void {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload as ESObject)
  }
}