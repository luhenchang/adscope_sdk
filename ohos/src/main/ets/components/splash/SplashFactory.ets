import common from '@ohos.app.ability.common';
import MessageCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/MessageCodec';
import PlatformViewFactory from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformViewFactory';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import PlatformView from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { OhosPlatformSplashView } from '../splash/OhosPlatformSplashView';

export class SplashFactory extends PlatformViewFactory {
  message: BinaryMessenger;

  constructor(message: BinaryMessenger, createArgsCodes: MessageCodec<Object>) {
    super(createArgsCodes);
    this.message = message;
  }

  public create(context: common.Context, viewId: number, args: Object): PlatformView {
    return new OhosPlatformSplashView(context, viewId, args, this.message);
  }
}
