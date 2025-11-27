import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSBuildNativeView, AMPSNativeAdWrapper } from 'xyz.adscope.amps';
import { AdWrapperManager } from '../native/AdWrapperManager';
import { OhosPlatformNativeView } from './OhosPlatformNativeView';

@Component
export struct AMPSNativeAdComponent {
  @Prop params: Params
  @Prop adId: string
  @State customView: OhosPlatformNativeView = this.params.platformView as OhosPlatformNativeView
  @State wrapper: AMPSNativeAdWrapper | undefined = undefined
  @State closeAd: boolean = false
  aboutToAppear(): void {
    this.wrapper = AdWrapperManager.getInstance().getAd(this.adId)
  }

  build() {
    if (this.wrapper && !this.closeAd)
      Column() {
        AMPSBuildNativeView(this.wrapper)
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .direction(Direction.Ltr)
      .width('100%')
      .height('100%')
  }
}
