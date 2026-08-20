import { image } from '@kit.ImageKit';
import { FlutterAssetLoader } from '../common/FlutterAssetLoader';
import { SplashBottomImageChild, toImageFit } from './SplashBottomModule';

@Component
export struct SplashBottomImageComponent {
  @Prop imgItem: SplashBottomImageChild;
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State displayWidth: number = 0;
  @State displayHeight: number = 0;

  aboutToAppear(): void {
    FlutterAssetLoader.loadImage(getContext(this), this.imgItem.imagePath).then((result) => {
      if (!result) {
        return;
      }
      this.pixelMap = result.pixelMap;
      this.displayWidth = FlutterAssetLoader.resolveDisplayWidth(this.imgItem.width, result.logicalWidth);
      this.displayHeight = FlutterAssetLoader.resolveDisplayHeight(this.imgItem.height, result.logicalHeight);
    });
  }

  aboutToDisappear(): void {
    if (this.pixelMap) {
      this.pixelMap.release();
      this.pixelMap = undefined;
    }
  }

  build() {
    if (this.pixelMap) {
      Image(this.pixelMap)
        .width(this.displayWidth)
        .height(this.displayHeight)
        .objectFit(toImageFit(this.imgItem.scaleType))
        .offset({
          x: this.imgItem.x,
          y: this.imgItem.y,
        })
    }
  }
}
