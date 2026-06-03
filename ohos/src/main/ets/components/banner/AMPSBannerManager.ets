import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSBannerAd, AMPSBannerAdListener, AMPSBannerAdWrapper } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AD_INSTANCE_ID, AMPSBannerCallBackChannelMethod, AMPSAdSdkMethodNames } from '../common/common';
import { window } from '@kit.ArkUI';

class BannerCallbackPayload {
  adInstanceId: string = ''
  code?: number = undefined
  message?: string = undefined
}

export class AMPSBannerManager {
  private static instance?: AMPSBannerManager
  private bannerAds: Map<string, AMPSBannerAd> = new Map<string, AMPSBannerAd>()
  private bannerAdItems: Map<string, AMPSBannerAdWrapper> = new Map<string, AMPSBannerAdWrapper>()
  private mWindowStage?: window.WindowStage

  private constructor() {
  }

  static getInstance() {
    if (!AMPSBannerManager.instance) {
      AMPSBannerManager.instance = new AMPSBannerManager()
    }
    return AMPSBannerManager.instance!
  }

  getBannerAdItem(instanceId: string): AMPSBannerAdWrapper | undefined {
    return this.bannerAdItems.get(instanceId)
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const args = this.argsAsMap(call.args as Object | undefined)
    const instanceId = this.extractInstanceId(args)
    switch (call.method) {
      case AMPSAdSdkMethodNames.bannerCreate:
        this.handleCreate(call, result)
        break;
      case AMPSAdSdkMethodNames.bannerLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleLoadAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.bannerPreLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handlePreLoadAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.bannerSetSlideTime:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.setSlideIntervalTime(requiredInstanceId, args, result)
        }
        break
      case AMPSAdSdkMethodNames.bannerGetECPM:
        result.success(instanceId ? (this.bannerAdItems.get(instanceId)?.getECPM() ?? 0) : 0)
        break;
      case AMPSAdSdkMethodNames.bannerGetSeatId:
        result.success(instanceId ? (this.bannerAds.get(instanceId)?.getSeatID() ?? '') : '')
        break;
      case AMPSAdSdkMethodNames.bannerDestroyAd:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.releaseBanner(requiredInstanceId)
        }
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.bannerIsReadyAd:
        result.success(instanceId ? (this.bannerAds.get(instanceId)?.isReadyAd() ?? false) : false)
        break;
      case AMPSAdSdkMethodNames.bannerAddPreLoadAdInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.bannerGetMediaExtraInfo:
        result.success(null)
        break;
      default:
        result.success(undefined);
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

  private createPayload(instanceId: string): BannerCallbackPayload {
    const payload = new BannerCallbackPayload()
    payload.adInstanceId = instanceId
    return payload
  }

  private createErrorPayload(instanceId: string, code: number, message: string): BannerCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.code = code
    payload.message = message
    return payload
  }

  private releaseBanner(instanceId: string): void {
    this.bannerAdItems.get(instanceId)?.destroy()
    this.bannerAdItems.delete(instanceId)
    this.bannerAds.delete(instanceId)
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
      this.releaseBanner(instanceId)
      this.bannerAds.set(instanceId, new AMPSBannerAd(mWindow.getUIContext(), adOption, this.createCallBack(instanceId)))
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const bannerAd = this.bannerAds.get(instanceId)
      if (!bannerAd) {
        result.error('LOAD_FAILED', `Banner ad instance not found: ${instanceId}`, undefined)
        return
      }
      bannerAd.load()
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handlePreLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const bannerAd = this.bannerAds.get(instanceId)
      if (!bannerAd) {
        result.error('LOAD_FAILED', `Banner ad instance not found: ${instanceId}`, undefined)
        return
      }
      bannerAd.load()
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private setSlideIntervalTime(instanceId: string, args: Map<string, Object> | undefined, result: MethodResult): void {
    try {
      const time = args?.get('slideTime') as number | undefined
      if (time === undefined) {
        result.error('INVALID_ARGS', 'slideTime is required', undefined)
        return
      }
      const bannerAdItem = this.bannerAdItems.get(instanceId)
      if (!bannerAdItem) {
        result.error('SHOW_FAILED', `Banner ad instance not found: ${instanceId}`, undefined)
        return
      }
      bannerAdItem.setSlideIntervalTime(time)
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private createCallBack(instanceId: string): AMPSBannerAdListener {
    return {
      loadOk: (ads: AMPSBannerAdWrapper[]) => {
        if (ads.length === 0) {
          this.sendPayload(
            AMPSBannerCallBackChannelMethod.onLoadFailure,
            this.createErrorPayload(instanceId, -1, 'banner wrapper is empty')
          )
          return
        }
        const bannerAdItem = ads[0]
        this.bannerAdItems.set(instanceId, bannerAdItem)
        bannerAdItem.renderCallBack = {
          renderSuccess: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onLoadSuccess)
          },
          renderFailed: (adWrapper: AMPSBannerAdWrapper, code: number, message: string) => {
            this.sendPayload(
              AMPSBannerCallBackChannelMethod.onLoadFailure,
              this.createErrorPayload(instanceId, code, message)
            )
          }
        }
        bannerAdItem.interactCallBack = {
          onAdShow: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdShow)
          },
          onAdExposure: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdShow)
          },
          onAdClicked: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdClicked)
          },
          toCloseAd: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onAdClosed)
            this.releaseBanner(instanceId)
          }
        }
        bannerAdItem.videoPlayCallBack = {
          onVideoReady: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoReady)
          },
          onVideoPlayStart: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoPlayStart)
          },
          onVideoPause: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoPause)
          },
          onVideoResume: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoResume)
          },
          onVideoPlayComplete: () => {
            this.sendMessage(instanceId, AMPSBannerCallBackChannelMethod.onVideoPlayEnd)
          },
          onVideoPlayError: (code: number, message: string) => {
            this.sendPayload(
              AMPSBannerCallBackChannelMethod.onVideoPlayError,
              this.createErrorPayload(instanceId, code, message)
            )
          }
        }
        bannerAdItem.renderAd()
      },
      loadFail: (code: number, message: string) => {
        this.sendPayload(
          AMPSBannerCallBackChannelMethod.onLoadFailure,
          this.createErrorPayload(instanceId, code, message)
        )
      }
    }
  }

  private sendPayload(method: string, payload: BannerCallbackPayload): void {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, payload as ESObject)
  }

  private sendMessage(instanceId: string, method: string): void {
    this.sendPayload(method, this.createPayload(instanceId))
  }
}