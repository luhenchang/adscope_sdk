import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { AMPSSplashComponent } from './AMPSSplashComponent';
import { SPLASH_BOTTOM, SPLASH_INSTANCE_ID } from '../common/common';
import { SplashBottomImageChild, SplashBottomModule, SplashBottomTextChild } from '../splash/SplashBottomModule';
import { SplashBottomImageComponent } from '../splash/SplashBottomImageComponent';
import { AMPSEventManager } from '../common/AMPSEventManager';

// 底部自定义组件只能使用无参 WrappedBuilder，绘制前由当前开屏视图写入。
export let globalSplashBottomBuilder: WrappedBuilder<[]> | undefined  = wrapBuilder(MyBuilder);

@Observed
export class OhosPlatformSplashView extends PlatformView {
  static activeBottom?: SplashBottomModule
  engine: AMPSEventManager
  instanceId: string = ''
  splashBottomModule?: SplashBottomModule

  constructor(args: ESObject, engine: AMPSEventManager) {
    super();
    this.engine = engine
    this.instanceId = (args.get(SPLASH_INSTANCE_ID) as string | undefined) ?? ''
    const bottomMap = args.get(SPLASH_BOTTOM) as Map<string, Object> | undefined
    if (bottomMap) {
      this.splashBottomModule = new SplashBottomModule(bottomMap)
    }
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(AMPSSplashWrappedBuilder);
  }

  dispose(): void {
    if (OhosPlatformSplashView.activeBottom === this.splashBottomModule) {
      OhosPlatformSplashView.activeBottom = undefined
    }
  }
}

@Builder
export function MyBuilder() {
  if (OhosPlatformSplashView.activeBottom?.initialized) {
    Stack() {
      ForEach(OhosPlatformSplashView.activeBottom?.textChildrens ?? [], (item: SplashBottomTextChild) => {
        Text(item?.text)
          .fontColor(item?.color)
          .fontSize(item?.fontSize)
          .offset({
            x: item?.x,
            y: item?.y
          })
      })
      ForEach(OhosPlatformSplashView.activeBottom?.imgChildrens ?? [], (imgItem: SplashBottomImageChild) => {
        SplashBottomImageComponent({ imgItem: imgItem })
      })
    }
    .backgroundColor(OhosPlatformSplashView.activeBottom?.backgroundColor)
    .height(OhosPlatformSplashView.activeBottom?.height)
    .width('100%')
    .alignContent(Alignment.TopStart)
  }
}

@Builder
export function AMPSSplashWrappedBuilder(params: Params) {
  AMPSSplashComponent({ platformView: params.platformView as OhosPlatformSplashView })
}
