import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
} from '@ohos/flutter_ohos';
import { common } from '@kit.AbilityKit';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AMPSPlatformViewManager } from '../common/AMPSPlatformViewManager';

/** Each registration owns its channel, ability context, ads, and platform view factories. */
export default class AdscopeSdkPlugin implements FlutterPlugin, AbilityAware {
  private engine?: AMPSEventManager
  private abilityContext?: common.UIAbilityContext

  constructor() {
  }

  getUniqueClassName(): string {
    return "AdscopeSdkPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.engine?.release()
    const owner = new AMPSEventManager()
    this.engine = owner
    if (this.abilityContext) {
      owner.setContext(this.abilityContext)
    }
    owner.init(binding.getBinaryMessenger())
    new AMPSPlatformViewManager(owner).init(binding)
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.engine?.release()
    this.engine = undefined
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.abilityContext = binding.getAbility().context
    this.engine?.setContext(this.abilityContext)
  }

  onDetachedFromAbility(): void {
    this.abilityContext = undefined
    this.engine?.setContext(undefined)
  }
}
