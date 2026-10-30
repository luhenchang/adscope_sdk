import { AMPSDrawAdWrapper, AMPSBuildDrawAdExpressView } from 'xyz.adscope.amps';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { OhosPlatformDrawView } from './OhosPlatformDrawView';
import { AmpsDrawCallbackChannelMethod } from '../common/common';

class DrawSizeUpdatePayload {
  adInstanceId: string = ''
  adId: string = ''
  width: number = 0
  height: number = 0
}

@Component
export struct AMPSDrawComponent {
  @Prop params: Params
  @Prop adId: string
  @Prop instanceId: string
  drawAd?: AMPSDrawAdWrapper = undefined

  aboutToAppear(): void {
    const view = this.params.platformView as OhosPlatformDrawView
    this.drawAd = view.engine.draw.getAdItem(this.adId)
  }

  private sendSizeUpdate(width: number, height: number): void {
    const view = this.params.platformView as OhosPlatformDrawView
    const payload = new DrawSizeUpdatePayload()
    payload.adInstanceId = this.instanceId
    payload.adId = this.adId
    payload.width = width
    payload.height = height
    view.engine.sendMessageToFlutter(
      AmpsDrawCallbackChannelMethod.drawSizeUpdate,
      payload as ESObject
    )
  }

  build() {
    Column() {
      if (this.drawAd)
        AMPSBuildDrawAdExpressView(this.drawAd)
    }
    .onAreaChange((oldValue, size) => {
      if (size.width && size.width > 10 && size.height && size.height > 10) {
        if (Math.floor(oldValue.height as number) < Math.floor(size.height as number)) {
          this.sendSizeUpdate(size.width as number, size.height as number)
        }
      }
    })
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width("100%")
    .height("100%")
  }
}
