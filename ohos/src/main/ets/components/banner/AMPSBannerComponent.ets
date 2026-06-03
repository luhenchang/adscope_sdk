import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSBannerAdWrapper, AMPSBuildBannerExpressView } from 'xyz.adscope.amps';
import { AMPSBannerManager } from './AMPSBannerManager';

@Component
export struct AMPSBannerComponent {
  @Prop params: Params
  @Prop instanceId: string
  bannerAd?: AMPSBannerAdWrapper = undefined

  aboutToAppear(): void {
    this.bannerAd = AMPSBannerManager.getInstance().getBannerAdItem(this.instanceId)
  }

  build() {
    Column() {
      if (this.bannerAd)
        AMPSBuildBannerExpressView(this.bannerAd)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width("100%")
    .height("100%")
  }
}
