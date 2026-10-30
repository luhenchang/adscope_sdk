import { BinaryMessenger, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import {
  BannerMethodNames,
  DrawMethodNames,
  InitMethodNames, InterstitialMethodNames, NativeMethodNames,
  RewardVideoMethodNames,
  SplashMethodNames } from '../common/common';
import { AMPSSDKInitManager } from '../init/AMPSSDKInitManager';
import { common } from '@kit.AbilityKit';
import { AMPSSplashManager } from '../splash/AMPSSplashManager';
import { AMPSInterstitialManager } from '../interstitial/AMPSInterstitialManager';
import { AMPSNativeManager } from '../native/AMPSNativeManager';
import { AMPSRewardVideoManager } from '../rewardVideo/AMPSRewardVideoManager';
import { AMPSBannerManager } from '../banner/AMPSBannerManager';
import { AMPSDrawAdManager } from '../draw/AMPSDrawAdManager';
import { AMPSInitCoordinator } from '../init/AMPSInitCoordinator';

/** One Flutter engine owns this channel, context, and ad stores. */
export class AMPSEventManager {
  private channel?: MethodChannel
  private context?: common.UIAbilityContext
  isReleased: boolean = false

  readonly initManager: AMPSSDKInitManager
  readonly splash: AMPSSplashManager
  readonly interstitial: AMPSInterstitialManager
  readonly native: AMPSNativeManager
  readonly reward: AMPSRewardVideoManager
  readonly banner: AMPSBannerManager
  readonly draw: AMPSDrawAdManager

  constructor() {
    this.initManager = new AMPSSDKInitManager(this)
    this.splash = new AMPSSplashManager(this)
    this.interstitial = new AMPSInterstitialManager(this)
    this.native = new AMPSNativeManager(this)
    this.reward = new AMPSRewardVideoManager(this)
    this.banner = new AMPSBannerManager(this)
    this.draw = new AMPSDrawAdManager(this)
  }

  setContext(context?: common.UIAbilityContext) {
    this.context = context
  }

  getContext(): common.UIAbilityContext | undefined {
    return this.context
  }

  init(binaryMessenger: BinaryMessenger) {
    if (this.isReleased || this.channel) {
      return
    }
    this.channel = new MethodChannel(binaryMessenger, "adscope_sdk")
    const owner = this
    this.channel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        if (owner.isReleased) {
          result.error('ENGINE_DETACHED', 'Flutter engine is detached', undefined)
          return
        }
        if (InitMethodNames.includes(call.method)) {
          owner.initManager.handleMethodCall(call, result)
        } else if (SplashMethodNames.includes(call.method)) {
          owner.splash.handleMethodCall(call, result)
        } else if (InterstitialMethodNames.includes(call.method)) {
          owner.interstitial.handleMethodCall(call, result)
        } else if (NativeMethodNames.includes(call.method)) {
          owner.native.handleMethodCall(call, result)
        } else if (RewardVideoMethodNames.includes(call.method)) {
          owner.reward.handleMethodCall(call, result)
        } else if (BannerMethodNames.includes(call.method)) {
          owner.banner.handleMethodCall(call, result)
        } else if (DrawMethodNames.includes(call.method)) {
          owner.draw.handleMethodCall(call, result)
        } else {
          result.notImplemented()
        }
      }
    })
  }

  sendMessageToFlutter(method: string, args?: ESObject) {
    if (this.isReleased) {
      return
    }
    this.channel?.invokeMethod(method, args)
  }

  release() {
    this.isReleased = true
    AMPSInitCoordinator.detach(this)
    this.channel?.setMethodCallHandler(null)
    this.channel = undefined
    this.context = undefined
    this.splash.release()
    this.interstitial.release()
    this.native.release()
    this.reward.release()
    this.banner.release()
    this.draw.release()
  }
}
