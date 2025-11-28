import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import {
  ampsAd, AMPSBuildInterstitialView, AMPSInterstitialAd
} from 'xyz.adscope.amps';
import { AMPSAdCallBackChannelMethod } from '../common/common';
import { AMPSInterstitialManager } from './AMPSInterstitialManager';
import { OhosPlatformInterstitialView } from './OhosPlatformInterstitialView';
import { print } from '@kit.BasicServicesKit';

@Component
struct AMPSInterstitialComponent {
  @Prop params: Params
  interAd?: AMPSInterstitialAd
  aboutToAppear(): void {
    this.interAd = AMPSInterstitialManager.getInstance().getInterstitialAd()
    // console.debug("h0987")
  }


  build() {
    Column() {
    //   if (this.interAd?.isSupportViewBuilder()) {
    //     AMPSBuildInterstitialView(this.interAd)
    //     // Text("nihao----")
    //   }else {
    //     Text("生出广告源不支持组件形式显示，请使用showAd")
    //   }
      Text("生出广告源不支持组件形式显示，请使用showAd")
    }

    // .alignItems(HorizontalAlign.Center)
    // .justifyContent(FlexAlign.Center)
    // .direction(Direction.Ltr)
    .width(200)
    .height(200)
    .backgroundColor(Color.Orange)

  }
}

export { AMPSInterstitialComponent };
