import { globalSplashBottomBuilder, OhosPlatformSplashView } from './OhosPlatformSplashView';
import { AMPSBuildSplashView, AMPSSplashAd } from 'xyz.adscope.amps';
import { common } from '@kit.AbilityKit';

@Component
struct AMPSSplashComponent {
  platformView?: OhosPlatformSplashView = undefined
  splashAd?: AMPSSplashAd

  aboutToAppear(): void {
    const view = this.platformView
    if (!view) {
      return
    }
    const instanceId = view.instanceId.length > 0 ? view.instanceId : undefined
    this.splashAd = view.engine.splash.getSplashAd(instanceId)
  }

  build() {
    const view = this.platformView
    if (view) {
      OhosPlatformSplashView.activeBottom = view.splashBottomModule
    }
    if (this.splashAd?.isReadyAd() && this.splashAd.isSupportViewBuilder()) {
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
