import { globalSplashBottomBuilder, OhosPlatformSplashView } from './OhosPlatformSplashView';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { ampsAd, AMPSBuildSplashView, AMPSSplashAd } from 'xyz.adscope.amps';
import { common } from '@kit.AbilityKit';
import { AMPSAdCallBackChannelMethod } from '../common/common';
@Component
struct AMPSSplashComponent {
  @State hasSplash: boolean = false
  @Prop params: Params
  @Prop adOption: ampsAd.AdOptions
  customView: OhosPlatformSplashView = this.params.platformView as OhosPlatformSplashView
  @State bkColor: Color = Color.Red
  splashAd?: AMPSSplashAd
  callback: ampsAd.CallBack = {
    onLoadSuccess: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess, undefined)
    },
    onLoadFailure: (code: number, message: string): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, { code, message })
    },
    onRenderOk: (): void => {
      this.hasSplash = true
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onRenderOk, undefined)
    },
    onAdShow: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdShow, undefined)
    },
    onAdExposure: (): void => {
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdExposure, undefined)
    },
    onAdClicked: (): void => {
      this.hasSplash = false
      this.customView.sendMessage(AMPSAdCallBackChannelMethod.onAdClicked, undefined)
    },
    onAdClosed: (): void => {
      this.hasSplash = false
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
    this.splashAd = new AMPSSplashAd(this.adOption, this.callback, this.getUIContext())
    OhosPlatformSplashView.mSplashAd = this.splashAd;
    this.splashAd?.load()
  }

  build() {
    if (this.hasSplash && this.splashAd) {
      Column() {
        AMPSBuildSplashView(
          this.splashAd, {
          windowStage: (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage,
          bottomWrappedBuilder: globalSplashBottomBuilder
        })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .direction(Direction.Ltr)
      .width('100%')
      .height('100%')
    }
  }
}

export { AMPSSplashComponent };
