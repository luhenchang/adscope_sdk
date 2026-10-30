import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSBuildNativeView, AMPSNativeAdWrapper } from 'xyz.adscope.amps';
import { AMPSNativeCallBackChannelMethod } from '../common/common';
import { OhosPlatformNativeView } from './OhosPlatformNativeView';

class NativeSizeUpdatePayload {
  adInstanceId: string = ''
  adId: string = ''
  width: number = 0
  height: number = 0
}

@Component
export struct AMPSNativeAdComponent {
  @Prop params: Params
  @Prop adId: string
  @Prop instanceId: string
  @State wrapper: AMPSNativeAdWrapper | undefined = undefined
  @State closeAd: boolean = false

  aboutToAppear(): void {
    const view = this.params.platformView as OhosPlatformNativeView
    this.wrapper = view.engine.native.getWrapper(this.adId)
  }

  private sendSizeUpdate(width: number, height: number): void {
    const view = this.params.platformView as OhosPlatformNativeView
    const payload = new NativeSizeUpdatePayload()
    payload.adInstanceId = this.instanceId
    payload.adId = this.adId
    payload.width = width
    payload.height = height
    view.engine.sendMessageToFlutter(
      AMPSNativeCallBackChannelMethod.nativeSizeUpdate,
      payload as ESObject
    )
  }

  build() {
    if (this.wrapper && !this.closeAd)
      Column() {
        Column() {
          AMPSBuildNativeView(this.wrapper)
        }.onAreaChange((oldValue, size) => {
          if (size.width && size.width > 10 && size.height && size.height > 10) {
            if (Math.floor(oldValue.height as number) < Math.floor(size.height as number)) {
              this.sendSizeUpdate(size.width as number, size.height as number)
            }
          }
        })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .direction(Direction.Ltr)
      .height("100%")
      .width("100%")
  }
}
