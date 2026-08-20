import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSSplashComponent } from './AMPSSplashComponent';
import { SPLASH_BOTTOM, SPLASH_INSTANCE_ID } from '../common/common';
import { SplashBottomImageChild, SplashBottomModule, SplashBottomTextChild } from '../splash/SplashBottomModule';
import { SplashBottomImageComponent } from '../splash/SplashBottomImageComponent';

//底部自定义组件全局WrappedBuilder
export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(MyBuilder);
@Observed
export class OhosPlatformSplashView extends PlatformView {
  static splashInstanceId?: string
  static splashBottomModule?: SplashBottomModule
  constructor(args: ESObject) {
    super();
    OhosPlatformSplashView.splashInstanceId = args.get(SPLASH_INSTANCE_ID) as string | undefined
    const bottomMap = args.get(SPLASH_BOTTOM) as Map<string, Object> | undefined
    if (bottomMap) {
      OhosPlatformSplashView.splashBottomModule = new SplashBottomModule(bottomMap)
    } else {
      OhosPlatformSplashView.splashBottomModule = undefined
    }
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
    OhosPlatformSplashView.splashInstanceId = undefined
    OhosPlatformSplashView.splashBottomModule = undefined
  }
}


@Builder
export function MyBuilder() {
  if (OhosPlatformSplashView.splashBottomModule?.initialized) {
    Stack() {
      ForEach(OhosPlatformSplashView.splashBottomModule?.textChildrens ?? [], (item: SplashBottomTextChild) => {
        Text(item?.text)
          .fontColor(item?.color)
          .fontSize(item?.fontSize)
          .offset({
            x: item?.x,
            y: item?.y
          })
      })
      ForEach(OhosPlatformSplashView.splashBottomModule?.imgChildrens ?? [], (imgItem: SplashBottomImageChild) => {
        SplashBottomImageComponent({ imgItem: imgItem })
      })
    }
    .backgroundColor(OhosPlatformSplashView.splashBottomModule?.backgroundColor)
    .height(OhosPlatformSplashView.splashBottomModule?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}


@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSSplashComponent()
}
