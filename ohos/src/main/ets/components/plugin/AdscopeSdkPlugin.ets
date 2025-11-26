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
  }

  onDetachedFromAbility(): void {

  }
}