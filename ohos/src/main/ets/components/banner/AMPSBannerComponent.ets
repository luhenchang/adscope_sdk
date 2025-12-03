
import { AMPSBannerAdWrapper, AMPSBuildBannerExpressView } from 'xyz.adscope.amps';
import { AMPSBannerManager } from './AMPSBannerManager';
@Component
export  struct AMPSBannerComponent {

  bannerAd?: AMPSBannerAdWrapper
  aboutToAppear(): void {
    this.bannerAd = AMPSBannerManager.getInstance().getBannerAdItem()
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

