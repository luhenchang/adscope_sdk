import { image } from '@kit.ImageKit';
import { display } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

export class FlutterAssetImage {
  pixelMap: image.PixelMap;
  assetScale: number;
  logicalWidth: number;
  logicalHeight: number;

  constructor(pixelMap: image.PixelMap, assetScale: number, logicalWidth: number, logicalHeight: number) {
    this.pixelMap = pixelMap;
    this.assetScale = assetScale;
    this.logicalWidth = logicalWidth;
    this.logicalHeight = logicalHeight;
  }
}

interface AssetVariant {
  path: string;
  scale: number;
}

export class FlutterAssetLoader {
  static getDisplayDensity(): number {
    try {
      const defaultDisplay = display.getDefaultDisplaySync();
      return defaultDisplay.densityPixels;
    } catch (error) {
      console.warn(`FlutterAssetLoader: failed to get display density, fallback to 1. ${error}`);
      return 1;
    }
  }

  static buildVariantPaths(imagePath: string, density: number): AssetVariant[] {
    const assetPath = `flutter_assets/${imagePath}`;
    const lastSlash = assetPath.lastIndexOf('/');
    const dir = lastSlash >= 0 ? assetPath.substring(0, lastSlash) : '';
    const fileName = lastSlash >= 0 ? assetPath.substring(lastSlash + 1) : assetPath;

    let variants: AssetVariant[] = [];
    if (density >= 3) {
      variants = [
        { path: `${dir}/3.0x/${fileName}`, scale: 3 },
        { path: `${dir}/2.0x/${fileName}`, scale: 2 },
        { path: assetPath, scale: 1 },
      ];
    } else if (density >= 2) {
      variants = [
        { path: `${dir}/2.0x/${fileName}`, scale: 2 },
        { path: assetPath, scale: 1 },
      ];
    } else {
      variants = [{ path: assetPath, scale: 1 }];
    }
    return variants;
  }

  static async loadImage(context: common.Context, imagePath?: string): Promise<FlutterAssetImage | undefined> {
    if (!imagePath || imagePath.length === 0) {
      return undefined;
    }

    const resourceMgr = context.resourceManager;
    const density = FlutterAssetLoader.getDisplayDensity();
    const variants = FlutterAssetLoader.buildVariantPaths(imagePath, density);

    for (const variant of variants) {
      try {
        const fileData: Uint8Array = await resourceMgr.getRawFileContent(variant.path);
        const buffer = fileData.buffer.slice(fileData.byteOffset, fileData.byteOffset + fileData.byteLength);
        const imageSource = image.createImageSource(buffer);
        const pixelMap = await imageSource.createPixelMap({
          editable: false,
          desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
        });
        await imageSource.release();
        const imageInfo = await pixelMap.getImageInfo();
        const logicalWidth = imageInfo.size.width / variant.scale;
        const logicalHeight = imageInfo.size.height / variant.scale;
        return new FlutterAssetImage(pixelMap, variant.scale, logicalWidth, logicalHeight);
      } catch (_error) {
        // 尝试下一个分辨率目录
      }
    }
    console.warn(`FlutterAssetLoader: unable to load flutter asset ${imagePath}`);
    return undefined;
  }

  static resolveDisplayWidth(requestWidth: number | undefined, logicalWidth: number, fallback: number = 100): number {
    if ((requestWidth ?? 0) > 0) {
      return requestWidth as number;
    }
    return logicalWidth > 0 ? logicalWidth : fallback;
  }

  static resolveDisplayHeight(requestHeight: number | undefined, logicalHeight: number, fallback: number = 100): number {
    if ((requestHeight ?? 0) > 0) {
      return requestHeight as number;
    }
    return logicalHeight > 0 ? logicalHeight : fallback;
  }
}
