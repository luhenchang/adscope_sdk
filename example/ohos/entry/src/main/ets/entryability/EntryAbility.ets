
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { abilityAccessCtrl, common } from '@kit.AbilityKit';

export default class EntryAbility extends FlutterAbility {
  private requestOAIDTrackingConsentPermissions(context: common.Context): void {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']).then((data) => {
        if (data.authResults[0] == 0) {
          console.log("用户允许获取OAID-" + data.authResults[0])
        } else {
          console.log("用户不允许获取OAID")
        }
      }).catch(() => {
      console.log("许获取OAID出错")
    })
  }
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    this.requestOAIDTrackingConsentPermissions(this.context)
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }
}
