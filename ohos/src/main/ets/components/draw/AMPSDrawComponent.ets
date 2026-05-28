import { AMPSDrawAdWrapper, AMPSBuildDrawAdExpressView } from 'xyz.adscope.amps';
import { AMPSDrawAdManager } from './AMPSDrawAdManager';
import { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { OhosPlatformDrawView } from './OhosPlatformDrawView';
import { AMPSEventManager } from '../common/AMPSEventManager';
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
    this.drawAd = AMPSDrawAdManager.getInstance().getAdItem(this.adId)
  }

  private sendSizeUpdate(width: number, height: number): void {
    const payload = new DrawSizeUpdatePayload()
    payload.adInstanceId = this.instanceId
    payload.adId = this.adId
    payload.width = width
    payload.height = height
    AMPSEventManager.getInstance().sendMessageToFlutter(
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
