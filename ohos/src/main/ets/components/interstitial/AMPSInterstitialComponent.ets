import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import {
  ampsAd, AMPSBuildInterstitialView, AMPSInterstitialAd
} from 'xyz.adscope.amps';
import { AMPSAdCallBackChannelMethod } from '../common/common';
import { OhosPlatformInterstitialView } from './OhosPlatformInterstitialView';

@Component
struct AMPSInterstitialComponent {
  @State showAd: boolean = false
  @Prop params: Params
  @Prop adOption: ampsAd.AdOptions
  @State customView: OhosPlatformInterstitialView = this.params.platformView as OhosPlatformInterstitialView
  interAd?: AMPSInterstitialAd
  callback: ampsAd.CallBack = {
    onLoadSuccess: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess, undefined)
    },
    onLoadFailure: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, { code, message })
    },
    onRenderOk: (): void => {
      this.showAd = true
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk, undefined)
    },
    onAdShow: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdShow, undefined)
    },
    onAdExposure: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure, undefined)
    },
    onAdClicked: (): void => {
      this.showAd = false
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked, undefined)
    },
    onAdClosed: (): void => {
      this.showAd = false
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdClosed, undefined)
    },
    onRenderFailure: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onRenderFailure, undefined)
    },
    onAdShowError: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdShowError, { code, message })
    },
    onVideoPlayStart: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayStart, undefined)
    },
    onVideoPlayEnd: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd, undefined)
    },
    onVideoPlayError: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onVideoPlayEnd, { code, message })
    },
    onVideoSkipToEnd: (playDurationMs?: number): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onVideoSkipToEnd, { playDurationMs })
    },
    onAdReward: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdReward, undefined)
    }
  }

  aboutToAppear(): void {
    this.interAd = new AMPSInterstitialAd(this.adOption, this.callback)
    OhosPlatformInterstitialView.interstitialAd = this.interAd;
    this.interAd?.load()
  }


  build() {
    if (this.showAd && this.interAd) {
      Column() {
        AMPSBuildInterstitialView(this.interAd)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .direction(Direction.Ltr)
      .width('100%')
      .height('100%')
    }
  }
}

export { AMPSInterstitialComponent };
