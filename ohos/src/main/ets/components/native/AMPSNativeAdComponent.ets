import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSBuildNativeView, AMPSNativeAdWrapper } from 'xyz.adscope.amps';
import { AMPSEventManager } from '../common/AMPSEventManager';
import { AMPSNativeCallBackChannelMethod } from '../common/common';
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
      Column() {

        AMPSBuildNativeView(this.wrapper)
      }.onAreaChange((oldValue, size) => {

        if (size.width && size.width > 10 && size.height && size.height > 10) {
          if (oldValue.height as number == (size.height as number)) {
            return
          }
          let map: Map<string, number> = new Map()
          map.set("width", size.width as number)
          map.set("height", size.height as number)
          AMPSEventManager.getInstance().sendMessageToFlutter(AMPSNativeCallBackChannelMethod.nativeSizeUpdate, map)
        }
      })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
  }
}
