import { globalSplashBottomBuilder, OhosPlatformSplashView } from './OhosPlatformSplashView';
import { AMPSBuildSplashView, AMPSSplashAd } from 'xyz.adscope.amps';
import { common } from '@kit.AbilityKit';
import { AMPSSplashManager } from './AMPSSplashManager';

@Component
struct AMPSSplashComponent {

  splashAd?: AMPSSplashAd

  aboutToAppear(): void {
    this.splashAd = AMPSSplashManager.getInstance().getSplashAd(OhosPlatformSplashView.splashInstanceId)
  }

  build() {
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
