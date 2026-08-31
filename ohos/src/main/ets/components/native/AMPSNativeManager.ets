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
import { OhosPlatformUnifiedView } from '../native/OhosPlatformUnifiedView';

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
      case AMPSAdSdkMethodNames.nativeGetSeatId:
        result.success(instanceId ? (this.nativeAds.get(instanceId)?.getSeatID() ?? '') : '')
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
      case AMPSAdSdkMethodNames.nativeImages:
        result.success(this.getUnifiedImageUrls(this.getAdWrapper(args)))
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

  private getUnifiedImageUrls(wrapper?: AMPSNativeAdWrapper): Array<string> {
    if (!wrapper) {
      return []
    }
    const urls: Array<string> = []
    const imgList = wrapper.getImgList()
    if (imgList) {
      for (let i = 0; i < imgList.length; i++) {
        const imageUrl = imgList[i]?.imageUrl
        if (imageUrl) {
          urls.push(imageUrl)
        }
      }
    }
    if (urls.length === 0) {
      const main = wrapper.getMainImageUrl()
      if (main) {
        urls.push(main)
      }
    }
    return urls
  }

  private resolveCarouselAdId(instanceId: string, previousAdId: string, wrapper: AMPSNativeAdWrapper): string | undefined {
    if (previousAdId && AdWrapperManager.getInstance().getAd(previousAdId)) {
      return previousAdId
    }
    const adIds = this.adIdsByInstance.get(instanceId)
    if (!adIds || adIds.length === 0) {
      return undefined
    }
    if (previousAdId) {
      for (let i = 0; i < adIds.length; i++) {
        const flutterAdId = adIds[i]
        const oldWrapper = AdWrapperManager.getInstance().getAd(flutterAdId)
        if (oldWrapper && oldWrapper.adId === previousAdId) {
          return flutterAdId
        }
      }
    }
    if (adIds.length === 1) {
      return adIds[0]
    }
    return undefined
  }

  private createVideoPlayCallback(instanceId: string, adId: string): ESObject {
    return {
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
  }

  private bindWrapperCallbacks(
    instanceId: string,
    adId: string,
    wrapper: AMPSNativeAdWrapper,
    notifyRenderSuccess: boolean
  ): void {
    wrapper.renderCallBack = this.createRenderCallback(instanceId, adId, notifyRenderSuccess)
    wrapper.interactCallBack = this.createInteractiveCallback(instanceId, adId)
    wrapper.videoPlayCallBack = this.createVideoPlayCallback(instanceId, adId)
  }

  /**
   * SDK 轮播下一条素材：同一 Flutter adId 槽位替换 wrapper，
   * 旧 wrapper 由 SDK 延后 destroy，这里只换映射、重绑监听并通知 Dart 刷新布局。
   */
  private handleCarouselRefresh(instanceId: string, previousAdId: string, wrapper: AMPSNativeAdWrapper): void {
    if (!wrapper) {
      return
    }
    const flutterAdId = this.resolveCarouselAdId(instanceId, previousAdId, wrapper)
    if (!flutterAdId) {
      return
    }
    const oldWrapper = AdWrapperManager.getInstance().getAd(flutterAdId)
    if (oldWrapper === wrapper) {
      return
    }
    AdWrapperManager.getInstance().addAd(flutterAdId, wrapper)
    this.bindWrapperCallbacks(instanceId, flutterAdId, wrapper, false)
    OhosPlatformUnifiedView.refresh(flutterAdId)
    this.sendPayload(
      AMPSNativeCallBackChannelMethod.onCarouselAdLoad,
      this.createAdPayload(instanceId, flutterAdId)
    )
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

  private createRenderCallback(instanceId: string, adId: string, notifyRenderSuccess: boolean = true): AMPSNativeRenderListener {
    return {
      renderSuccess: (adWrapper: AMPSNativeAdWrapper): void => {
        AdWrapperManager.getInstance().addAd(adId, adWrapper)
        adWrapper.interactCallBack = this.createInteractiveCallback(instanceId, adId)
        adWrapper.videoPlayCallBack = this.createVideoPlayCallback(instanceId, adId)
        if (notifyRenderSuccess) {
          this.sendPayload(AMPSNativeCallBackChannelMethod.renderSuccess, this.createAdPayload(instanceId, adId))
        }
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
          this.bindWrapperCallbacks(instanceId, adId, item, true)
          item.renderAd()
        })
        this.adIdsByInstance.set(instanceId, adIdList)
        this.sendPayload(AMPSNativeCallBackChannelMethod.loadOk, this.createAdIdsPayload(instanceId, adIdList))
      },
      loadFail: (code: number, message: string): void => {
        this.sendPayload(AMPSNativeCallBackChannelMethod.loadFail, this.createErrorPayload(instanceId, code, message))
      },
      carouselRefresh: (previousAdId: string, wrapper: AMPSNativeAdWrapper): void => {
        this.handleCarouselRefresh(instanceId, previousAdId, wrapper)
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

