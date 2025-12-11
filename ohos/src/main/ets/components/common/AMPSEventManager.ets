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

export class AMPSEventManager {
  private static sInstance: AMPSEventManager;
  private channel?: MethodChannel;
  private mContext?: common.UIAbilityContext

  private constructor() {}
  static getInstance() {
    if (AMPSEventManager.sInstance == null) {
      AMPSEventManager.sInstance = new AMPSEventManager();
    }
    return AMPSEventManager.sInstance;
  }

  setContext(mContext: common.UIAbilityContext) {
    this.mContext = mContext;
  }

  getContext() {
    return this.mContext;
  }

  init(binaryMessenger: BinaryMessenger) {
    if (!this.channel) {
      this.channel = new MethodChannel(binaryMessenger, "adscope_sdk")
      this.channel.setMethodCallHandler({
        onMethodCall(call: MethodCall, result: MethodResult) {
          if (InitMethodNames.includes(call.method)) {
            AMPSSDKInitManager.getInstance().handleMethodCall(call, result);
          } else if (SplashMethodNames.includes(call.method)) {
            AMPSSplashManager.getInstance().handleMethodCall(call, result);
          } else if (InterstitialMethodNames.includes(call.method)) {
            AMPSInterstitialManager.getInstance().handleMethodCall(call, result);
          } else if (NativeMethodNames.includes(call.method)) {
            AMPSNativeManager.getInstance().handleMethodCall(call, result);
          } else if (RewardVideoMethodNames.includes(call.method)) {
            AMPSRewardVideoManager.getInstance().handleMethodCall(call, result);
          } else if (BannerMethodNames.includes(call.method)) {
            AMPSBannerManager.getInstance().handleMethodCall(call, result);
          }else if (DrawMethodNames.includes(call.method)) {
            AMPSDrawAdManager.getInstance().handleMethodCall(call, result);
          }
        }
      });
    }
  }

  sendMessageToFlutter(method: string, args: ESObject) {
    this.channel?.invokeMethod(method, args)
  }

  release() {
    if (this.channel) {
      this.channel.setMethodCallHandler(null)
    }
    this.mContext = undefined
  }
}