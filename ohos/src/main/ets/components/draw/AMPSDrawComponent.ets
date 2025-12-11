
import { AMPSDrawAdWrapper, AMPSBuildDrawAdExpressView } from 'xyz.adscope.amps';
import { AMPSDrawAdManager } from './AMPSDrawAdManager';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { OhosPlatformDrawView } from './OhosPlatformDrawView';

@Component
export  struct AMPSDrawComponent {

  drawAd?: AMPSDrawAdWrapper = undefined
  params?: Params
  aboutToAppear(): void {
    let adId = OhosPlatformDrawView.adId
    if (adId) {
      this.drawAd = AMPSDrawAdManager.getInstance().getAdItem(adId)
    }
  }


  build() {
    Column() {
      if (this.drawAd)
        AMPSBuildDrawAdExpressView(this.drawAd)
    }

    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width("100%")
    .height("100%")

  }
}

