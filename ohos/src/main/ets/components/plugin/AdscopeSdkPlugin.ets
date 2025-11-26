import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodChannel,
} from '@ohos/flutter_ohos';
import { AMPSConstants, AMPSInitConfig } from 'xyz.adscope.amps';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AMPSPlatformViewManager } from '../common/AMPSPlatformViewManager';
import { AMPSSDKInitManager } from '../init/AMPSSDKInitManager';

/** AdscopeSdkPlugin **/
export default class AdscopeSdkPlugin implements FlutterPlugin, AbilityAware {
  private channel: MethodChannel | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "AdscopeSdkPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    AMPSEventManager.getInstance().init(binding.getBinaryMessenger());
    AMPSPlatformViewManager.getInstance().init(binding);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    AMPSEventManager.getInstance().release();
  }
  onAttachedToAbility(binding: AbilityPluginBinding): void {
    AMPSEventManager.getInstance().setContext(binding.getAbility().context)

    setTimeout(()=>{
      let config: AMPSInitConfig = new AMPSInitConfig.Builder("55819", binding.getAbility().context)
        .setIsMediation(true)//设置开启聚合功能
        .setAdapterNames([
          AMPSConstants.AdapterName.ASNP,
          AMPSConstants.AdapterName.KS,
          AMPSConstants.AdapterName.GDT,
          AMPSConstants.AdapterName.HW,
          AMPSConstants.AdapterName.CSJ,
          AMPSConstants.AdapterName.GroMore,
          AMPSConstants.AdapterName.SigMob,
          AMPSConstants.AdapterName.JD
        ])//配置前置初始化广告平台
        .build()
      AMPSSDKInitManager.getInstance().initAMPSSDK(config)
    },2000)
  }

  onDetachedFromAbility(): void {

  }
}