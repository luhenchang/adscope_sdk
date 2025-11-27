import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSSplashComponent } from './AMPSSplashComponent';
import { SPLASH_BOTTOM } from '../common/common';
import { SplashBottomModule } from '../splash/SplashBottomModule';

//底部自定义组件全局WrappedBuilder
export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(MyBuilder);
@Observed
export class OhosPlatformSplashView extends PlatformView {
  static splashBottomModule?: SplashBottomModule
  constructor(args: ESObject) {
    super();
    OhosPlatformSplashView.splashBottomModule = new SplashBottomModule(args.get(SPLASH_BOTTOM))
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
    OhosPlatformSplashView.splashBottomModule = undefined
  }
}


@Builder
export function MyBuilder() {
  if (OhosPlatformSplashView.splashBottomModule?.initialized) {
    Stack() {
      Image($rawfile(`flutter_assets/${OhosPlatformSplashView.splashBottomModule?.imgChildren?.imagePath}`))
        .width(OhosPlatformSplashView.splashBottomModule?.imgChildren?.width)
        .height(OhosPlatformSplashView.splashBottomModule?.imgChildren?.height)
        .offset({
          x: OhosPlatformSplashView.splashBottomModule?.imgChildren?.x,
          y: OhosPlatformSplashView.splashBottomModule?.imgChildren?.y
        })
      Text(OhosPlatformSplashView.splashBottomModule?.textChildren?.text)
        .fontColor(OhosPlatformSplashView.splashBottomModule?.textChildren?.color)
        .offset({
          x: OhosPlatformSplashView.splashBottomModule?.textChildren?.x,
          y: OhosPlatformSplashView.splashBottomModule?.textChildren?.y
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
  AMPSSplashComponent(
    {
      params: params
    }
  )
}
