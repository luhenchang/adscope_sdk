import { Any, MethodCall, MethodResult } from "@ohos/flutter_ohos";
import { AMPSInitConfigConverter } from "../init/AMPSInitConfigConverter";
import { AMPSAdSdkMethodNames, AMPSInitChannelMethod } from "../common/common";
import { AMPSAdSdk, AMPSIInitCallback, AMPSInitConfig } from "xyz.adscope.amps";
import { AMPSEventManager } from "../common/AMPSEventManager";

export class AMPSSDKInitManager {
  private static instance: AMPSSDKInitManager;

  public static getInstance(): AMPSSDKInitManager {
    if (!AMPSSDKInitManager.instance) {
      AMPSSDKInitManager.instance = new AMPSSDKInitManager();
    }
    return AMPSSDKInitManager.instance;
  }

  handleMethodCall(call: MethodCall, result: MethodResult) {
    let method: string = call.method;
    let flutterParams: Map<string, Any> = call.args;
    switch (method) {
      case AMPSAdSdkMethodNames.init:
        let context = AMPSEventManager.getInstance().getContext()
        if (context) {
          const ampsConfig = new AMPSInitConfigConverter().convert(flutterParams, context);
          this.initAMPSSDK(ampsConfig)
          result.success(true);
        }
        break;
    }
  }


  initAMPSSDK(ampsInitConfig?: AMPSInitConfig) {
    let callback: AMPSIInitCallback = {
      initSuccess: (): void => {
        this.sendMessage(AMPSInitChannelMethod.initSuccess)
      },
      initializing: (): void => {
        this.sendMessage(AMPSInitChannelMethod.initializing)
      },
      alreadyInit: (): void => {
        this.sendMessage(AMPSInitChannelMethod.alreadyInit)
      },
      initFailed: (code: number, message: string): void => {
        this.sendMessage(AMPSInitChannelMethod.initFailed, { code, message })
      }
    }
    if (ampsInitConfig) {
      AMPSAdSdk.testMode = AMPSInitConfigConverter.testModel
      AMPSAdSdk.init(ampsInitConfig, callback)
    }
  }

  public sendMessage = (method: string, args?: Any) => {
    AMPSEventManager.getInstance().sendMessageToFlutter(method, args)
  }
}