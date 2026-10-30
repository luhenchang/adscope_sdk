import { AMPSBuildInterstitialView, AMPSInterstitialAd } from 'xyz.adscope.amps';
import { OhosPlatformInterstitialView } from './OhosPlatformInterstitialView';

@Component
struct AMPSInterstitialComponent {
  platformView?: OhosPlatformInterstitialView = undefined
  interAd?: AMPSInterstitialAd

  aboutToAppear(): void {
    const view = this.platformView
    if (!view) {
      return
    }
    const instanceId = view.instanceId.length > 0 ? view.instanceId : undefined
    this.interAd = view.engine.interstitial.getInterstitialAd(instanceId)
  }

  build() {
    Column() {
      if (this.interAd?.isSupportViewBuilder()) {
        AMPSBuildInterstitialView(this.interAd)
      } else {
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
