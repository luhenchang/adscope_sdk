import common from '@ohos.app.ability.common';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import PlatformViewFactory from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformViewFactory';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import PlatformView from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { OhosPlatformBannerView } from './OhosPlatformBannerView';
import { AMPSEventManager } from '../common/AMPSEventManager';

export class BannerFactory extends PlatformViewFactory {
  message: BinaryMessenger;
  private engine: AMPSEventManager

  constructor(message: BinaryMessenger, createArgsCodes: MessageCodec<Object>, engine: AMPSEventManager) {
    super(createArgsCodes);
    this.message = message;
    this.engine = engine
  }

  public create(context: common.Context, viewId: number, args: Object): PlatformView {
    return new OhosPlatformBannerView(args as ESObject, this.engine);
  }
}