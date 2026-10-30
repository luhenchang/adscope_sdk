import { MethodCall, MethodResult } from '@ohos/flutter_ohos';
import { ampsAd, AMPSRewardVideoAd, AMPSRewardVideoListener } from 'xyz.adscope.amps';
import { AdOptionsModule } from '../common/AdOptionsModule';
import { AMPSEventManager } from '../common/AMPSEventManager';
import {
  AD_INSTANCE_ID,
  AMPSRewardedVideoCallBackChannelMethod,
  AMPSAdSdkMethodNames,
} from '../common/common';

// 使用能力接口，避免编译时依赖旧版 SDK 尚未声明的 setExtraData。
interface RewardVideoExtraDataUpdater {
  setExtraData?: (extra?: string) => void
}

class RewardVideoCallbackPayload {
  adInstanceId: string = ''
  code?: number = undefined
  message?: string = undefined
  playDurationMs?: number = undefined
}

export class AMPSRewardVideoManager {
  private engine: AMPSEventManager
  private rewardVideoAds: Map<string, AMPSRewardVideoAd> = new Map<string, AMPSRewardVideoAd>()
  private rewardVideoAdOptions: Map<string, ampsAd.AdOptions> = new Map<string, ampsAd.AdOptions>()

  constructor(engine: AMPSEventManager) {
    this.engine = engine
  }

  release(): void {
    const ids: Array<string> = []
    this.rewardVideoAds.forEach((_ad: AMPSRewardVideoAd, id: string) => {
      ids.push(id)
    })
    ids.forEach((id: string) => {
      this.releaseRewardVideo(id)
    })
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    const args = this.argsAsMap(call.args as Object | undefined)
    const instanceId = this.extractInstanceId(args)
    switch (call.method) {
      case AMPSAdSdkMethodNames.rewardVideoCreate:
        this.handleCreate(call, result)
        break;
      case AMPSAdSdkMethodNames.rewardVideoLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleLoadAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.rewardVideoPreLoad:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handlePreLoadAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.rewardVideoShowAd:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.handleShowAd(requiredInstanceId, result)
        }
        break;
      case AMPSAdSdkMethodNames.rewardVideoGetECPM:
        result.success(instanceId ? (this.rewardVideoAds.get(instanceId)?.getECPM() ?? 0) : 0)
        break;
      case AMPSAdSdkMethodNames.rewardVideoGetSeatId:
        result.success(instanceId ? (this.rewardVideoAds.get(instanceId)?.getSeatID() ?? '') : '')
        break;
      case AMPSAdSdkMethodNames.rewardVideoIsReadyAd:
        result.success(instanceId ? (this.rewardVideoAds.get(instanceId)?.isReadyAd() ?? false) : false)
        break;
      case AMPSAdSdkMethodNames.rewardVideoDestroyAd:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          this.releaseRewardVideo(requiredInstanceId)
        }
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.rewardVideoAddPreLoadAdInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.rewardVideoGetMediaExtraInfo:
        result.success(null)
        break;
      case AMPSAdSdkMethodNames.rewardVideoSetExtraDataMap:
        {
          const requiredInstanceId = this.requireInstanceId(instanceId, result)
          if (!requiredInstanceId) {
            return
          }
          const adOption = this.rewardVideoAdOptions.get(requiredInstanceId)
          if (!adOption) {
            result.error('INVALID_INSTANCE', `Reward video instance not found: ${requiredInstanceId}`, undefined)
            return
          }
          const rewardVideo = this.rewardVideoAds.get(requiredInstanceId) as RewardVideoExtraDataUpdater | undefined
          if (!rewardVideo || typeof rewardVideo.setExtraData !== 'function') {
            console.warn('amps => [AMPSRewardVideo] 当前鸿蒙 SDK 不支持 setExtraData，跳过动态参数更新，请升级 SDK。')
            result.success(false)
            return
          }
          // 修改传给 SDK 的同一配置对象，不重新创建或加载广告。
          adOption.customParam = args ? AdOptionsModule.getAdOptionFromMap(args).customParam : undefined
          const ampsExtra = adOption.customParam?.get('adn_amps') as string | Map<string, string> | undefined
          if (typeof ampsExtra === 'string') {
            adOption.extra = ampsExtra
          } else if (ampsExtra instanceof Map) {
            adOption.extra = ampsExtra.get('extra')
          } else if (!adOption.customParam) {
            adOption.extra = undefined
          }
          // SDK 在创建时复制配置，需同步到内部及当前加载器的激励验证参数。
          rewardVideo.setExtraData(adOption.extra)
          result.success(null)
        }
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

  private createPayload(instanceId: string): RewardVideoCallbackPayload {
    const payload = new RewardVideoCallbackPayload()
    payload.adInstanceId = instanceId
    return payload
  }

  private createErrorPayload(instanceId: string, code: number, message: string): RewardVideoCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.code = code
    payload.message = message
    return payload
  }

  private createVideoSkipPayload(instanceId: string, playDurationMs?: number): RewardVideoCallbackPayload {
    const payload = this.createPayload(instanceId)
    payload.playDurationMs = playDurationMs
    return payload
  }

  private createCallBack(instanceId: string): AMPSRewardVideoListener {
    return {
      onLoadSuccess: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess)
      },
      onLoadFailure: (code: number, message: string): void => {
        this.sendPayload(
          AMPSRewardedVideoCallBackChannelMethod.onLoadFailure,
          this.createErrorPayload(instanceId, code, message)
        )
      },
      onAdDidShow: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdShow)
      },
      onAdClicked: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdClicked)
      },
      onAdClosed: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdClosed)
        this.releaseRewardVideo(instanceId)
      },
      onVideoPlayStart: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onVideoPlayStart)
      },
      onVideoPlayEnd: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd)
      },
      onVideoPlayError: (code: number, message: string): void => {
        this.sendPayload(
          AMPSRewardedVideoCallBackChannelMethod.onVideoPlayError,
          this.createErrorPayload(instanceId, code, message)
        )
      },
      onVideoSkipToEnd: (playDurationMs?: number): void => {
        this.sendPayload(
          AMPSRewardedVideoCallBackChannelMethod.onVideoSkipToEnd,
          this.createVideoSkipPayload(instanceId, playDurationMs)
        )
      },
      onAdReward: (): void => {
        this.sendMessage(instanceId, AMPSRewardedVideoCallBackChannelMethod.onAdReward)
      }
    }
  }

  private releaseRewardVideo(instanceId: string): void {
    this.rewardVideoAds.delete(instanceId)
    this.rewardVideoAdOptions.delete(instanceId)
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
      this.releaseRewardVideo(instanceId)
      this.rewardVideoAds.set(instanceId, new AMPSRewardVideoAd(adOption, this.createCallBack(instanceId)))
      this.rewardVideoAdOptions.set(instanceId, adOption)
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handlePreLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const rewardVideo = this.rewardVideoAds.get(instanceId)
      if (!rewardVideo) {
        result.error('LOAD_FAILED', `Reward video ad instance not found: ${instanceId}`, undefined)
        return
      }
      rewardVideo.load()
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handleLoadAd(instanceId: string, result: MethodResult): void {
    try {
      const rewardVideo = this.rewardVideoAds.get(instanceId)
      if (!rewardVideo) {
        result.error('LOAD_FAILED', `Reward video ad instance not found: ${instanceId}`, undefined)
        return
      }
      rewardVideo.load()
    } catch (error) {
      result.error('LOAD_EXCEPTION', `加载广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private handleShowAd(instanceId: string, result: MethodResult): void {
    try {
      const context = this.engine.getContext()
      const rewardVideo = this.rewardVideoAds.get(instanceId)
      if (rewardVideo && context) {
        rewardVideo.showAd(context.windowStage)
      } else {
        result.error('SHOW_FAILED', '广告未加载或WindowStage不存在', undefined)
        return
      }
    } catch (error) {
      result.error('SHOW_EXCEPTION', `显示广告异常: ${error instanceof Error ? error.message : error}`, undefined)
      return
    }
    result.success(true)
  }

  private sendPayload(method: string, payload: RewardVideoCallbackPayload): void {
    this.engine.sendMessageToFlutter(method, payload as ESObject)
  }

  private sendMessage(instanceId: string, method: string): void {
    this.sendPayload(method, this.createPayload(instanceId))
  }
}
