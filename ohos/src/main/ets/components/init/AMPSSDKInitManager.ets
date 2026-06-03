import { Any, MethodCall, MethodResult } from "@ohos/flutter_ohos";
import { AMPSInitConfigConverter } from "../init/AMPSInitConfigConverter";
import { AMPSAdSdkMethodNames, AMPSInitChannelMethod } from "../common/common";
import { AMPSAdSdk, AMPSIInitCallback, AMPSInitConfig } from "xyz.adscope.amps";
import { AMPSEventManager } from "../common/AMPSEventManager";
import { abilityAccessCtrl } from "@kit.AbilityKit";

export class AMPSSDKInitManager {
  private static instance: AMPSSDKInitManager;

  public static getInstance(): AMPSSDKInitManager {
    if (!AMPSSDKInitManager.instance) {
      AMPSSDKInitManager.instance = new AMPSSDKInitManager();
    }
    return AMPSSDKInitManager.instance;
  }
  static initStatus: number = 0

  handleMethodCall(call: MethodCall, result: MethodResult) {
    let method: string = call.method;
    let flutterParams: Map<string, Any> = call.args;
    switch (method) {
      case AMPSAdSdkMethodNames.init:
        let context = AMPSEventManager.getInstance().getContext()
        if (context) {
          try {
            const ampsConfig = new AMPSInitConfigConverter().convert(flutterParams, context)
            this.initAMPSSDK(ampsConfig)
          } catch (error) {
            this.sendMessage(AMPSInitChannelMethod.initFailed, { code: -1, message: (error as Error).message })
          }
          result.success(true);
        }
        break;
      case AMPSAdSdkMethodNames.permissionTracking:
        let context1 = AMPSEventManager.getInstance().getContext()
        if (context1) {
          try {
            const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
             atManager.requestPermissionsFromUser(context1, ['ohos.permission.APP_TRACKING_CONSENT'])
               .then((res)=>{
                 result.success(res.authResults[0]);
               }).catch((error:Error)=>{
               result.error(error.name, `权限请求异常: ${error instanceof Error ? error.message : error}`, undefined);
             })
          } catch (error) {
            result.error(error.code, `权限请求异常: ${error instanceof Error ? error.message : error}`, undefined);
          }
        }
        break;
      case AMPSAdSdkMethodNames.getSdkVersion:
        let version = AMPSAdSdk.sdkVersion()
        result.success(version)
        break
      case AMPSAdSdkMethodNames.getInitStatus:
        let status = AMPSSDKInitManager.initStatus
        result.success(status)
        break
      case AMPSAdSdkMethodNames.setPersonalRecommend:
        // let recommend = call.args as boolean
        result.success(undefined)
        break
      default :
        result.success(undefined)
    }
  }


  initAMPSSDK(ampsInitConfig?: AMPSInitConfig) {
    let callback: AMPSIInitCallback = {
      initSuccess: (): void => {
        AMPSSDKInitManager.initStatus = 2
        AMPSSDKInitManager.getInstance().sendMessage(AMPSInitChannelMethod.initSuccess)
      },
      initializing: (): void => {
        AMPSSDKInitManager.initStatus = 1
        AMPSSDKInitManager.getInstance().sendMessage(AMPSInitChannelMethod.initializing)
      },
      alreadyInit: (): void => {
        AMPSSDKInitManager.initStatus = 4
        AMPSSDKInitManager.getInstance().sendMessage(AMPSInitChannelMethod.alreadyInit)
      },
      initFailed: (code: number, message: string): void => {
        AMPSSDKInitManager.initStatus = 3
        AMPSSDKInitManager.getInstance().sendMessage(AMPSInitChannelMethod.initFailed, { code, message })
      }
    }
    if (ampsInitConfig) {
      AMPSAdSdk.testMode = false
      AMPSSDKInitManager.initStatus = 1
      AMPSAdSdk.init(ampsInitConfig, callback)
    }
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}