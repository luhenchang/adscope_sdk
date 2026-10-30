import { Any, MethodCall, MethodResult } from "@ohos/flutter_ohos";
import { AMPSInitConfigConverter } from "../init/AMPSInitConfigConverter";
import { AMPSAdSdkMethodNames, AMPSInitChannelMethod } from "../common/common";
import { AMPSAdSdk, AMPSInitConfig } from "xyz.adscope.amps";
import { AMPSEventManager } from "../common/AMPSEventManager";
import { abilityAccessCtrl } from "@kit.AbilityKit";
import { AMPSInitCoordinator } from "./AMPSInitCoordinator";

export class AMPSSDKInitManager {
  private engine: AMPSEventManager

  constructor(engine: AMPSEventManager) {
    this.engine = engine
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    let method: string = call.method;
    let flutterParams: Map<string, Any> = call.args;
    switch (method) {
      case AMPSAdSdkMethodNames.init:
        let context = this.engine.getContext()
        if (context) {
          try {
            const ampsConfig = new AMPSInitConfigConverter().convert(flutterParams, context)
            this.initAMPSSDK(ampsConfig)
          } catch (error) {
            this.engine.sendMessageToFlutter(AMPSInitChannelMethod.initFailed, {
              code: -1,
              message: (error as Error).message
            } as ESObject)
          }
          result.success(true);
        } else {
          this.engine.sendMessageToFlutter(AMPSInitChannelMethod.initFailed, {
            code: -1,
            message: 'Ability context is not available.'
          } as ESObject)
          result.success(true);
        }
        break;
      case AMPSAdSdkMethodNames.permissionTracking:
        let context1 = this.engine.getContext()
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
        } else {
          result.error('CONTEXT_UNAVAILABLE', 'Ability context is not available.', undefined)
        }
        break;
      case AMPSAdSdkMethodNames.getSdkVersion:
        let version = AMPSAdSdk.sdkVersion()
        result.success(version)
        break
      case AMPSAdSdkMethodNames.getInitStatus:
        result.success(AMPSInitCoordinator.initStatus)
        break
      case AMPSAdSdkMethodNames.setPersonalRecommend:
        result.success(undefined)
        break
      default :
        result.success(undefined)
    }
  }

  initAMPSSDK(ampsInitConfig?: AMPSInitConfig) {
    if (!ampsInitConfig) {
      return
    }
    AMPSAdSdk.testMode = false
    AMPSInitCoordinator.request(this.engine, (callback) => {
      AMPSAdSdk.init(ampsInitConfig, callback)
    })
  }
}
