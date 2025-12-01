
import { AMPSBuildInterstitialView, AMPSInterstitialAd } from 'xyz.adscope.amps';
import { AMPSInterstitialManager } from './AMPSInterstitialManager';
@Component
struct AMPSInterstitialComponent {

  interAd?: AMPSInterstitialAd
  aboutToAppear(): void {
    this.interAd = AMPSInterstitialManager.getInstance().getInterstitialAd()
  }


  build() {
    Column() {
      if (this.interAd?.isSupportViewBuilder()) {
        AMPSBuildInterstitialView(this.interAd)
      }else {
        Text("生出广告源不支持组件形式显示，请使用showAd")
      }
    }

    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width("100%")
    .height("100%")

  }
}

export { AMPSInterstitialComponent };
