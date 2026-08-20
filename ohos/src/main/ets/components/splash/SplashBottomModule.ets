import { List } from '@kit.ArkTS';

// 定义子组件类型枚举，提高代码可读性和类型安全
enum ChildType {
  IMAGE = 'image',
  TEXT = 'text'
}

export enum ImageScaleType {
  CONTAIN = 'contain',
  COVER = 'cover',
  FILL = 'fill'
}

export function toImageFit(scaleType?: ImageScaleType): ImageFit {
  switch (scaleType) {
    case ImageScaleType.CONTAIN:
      return ImageFit.Contain;
    case ImageScaleType.COVER:
      return ImageFit.Cover;
    case ImageScaleType.FILL:
    default:
      return ImageFit.Fill;
  }
}

// 提取子组件通用属性，减少重复代码
class SplashBottomBaseChild {
  x?: number;
  y?: number;
}

// 继承通用父类，并补充自身特有属性
export class SplashBottomImageChild extends SplashBottomBaseChild {
  width?: number;
  height?: number;
  imagePath?: string;
  scaleType: ImageScaleType = ImageScaleType.FILL;
}

// 继承通用父类，并补充自身特有属性
export class SplashBottomTextChild extends SplashBottomBaseChild {
  fontSize?: number;
  color?: string;
  text?: string;
}

export class SplashBottomModule {
  // 使用类型更明确的数组
  imgChildrens?: SplashBottomImageChild[];
  textChildrens?: SplashBottomTextChild[];
  height: number = 0;
  backgroundColor: string = "#00000000";
  initialized: boolean = false;

  constructor(map: Map<string, Object>) {
    this.getBottomModuleFromMap(map);
  }

  private getBottomModuleFromMap(map: Map<string, Object>) {
    // 检查 map 是否存在且类型正确
    if (!map || map.get('type') !== 'parent') {
      console.warn('Invalid map provided. Expected type "parent".');
      return;
    }
    this.initialized = true;
    this.height = (map.get('height') as number) ?? 0;
    this.backgroundColor = (map.get('backgroundColor') as string) ?? "#00000000"
    const childsMap: List<Map<string, Object>> | undefined = map.get('children') as List<Map<string, Object>> | undefined;
    if (!childsMap) {
      return;
    }
    this.imgChildrens = []
    this.textChildrens = []
    try {
      childsMap.forEach((childMap: Map<string, Object>) => {
        // 使用 switch 语句代替 if-else，结构更清晰
        switch (childMap.get('type')) {
          case ChildType.IMAGE:
            this.imgChildrens?.push(this.createImageChild(childMap));
            break;
          case ChildType.TEXT:
            this.textChildrens?.push(this.createTextChild(childMap));
            break;
        }
      });
    } catch (error) {
    }
  }

  // 提取创建子组件的逻辑到单独的方法
  private createImageChild(map: Map<string, Object>): SplashBottomImageChild {
    const child = new SplashBottomImageChild();
    child.width = map.get('width') as number;
    child.height = map.get('height') as number;
    child.x = map.get('x') as number;
    child.y = map.get('y') as number;
    child.imagePath = map.get('imagePath') as string;
    child.scaleType = this.parseScaleType(map.get('scaleType'));
    return child;
  }

  private parseScaleType(value: Object | undefined): ImageScaleType {
    const typeName = value as string;
    if (typeName === ImageScaleType.CONTAIN) {
      return ImageScaleType.CONTAIN;
    }
    if (typeName === ImageScaleType.COVER) {
      return ImageScaleType.COVER;
    }
    return ImageScaleType.FILL;
  }

  private createTextChild(map: Map<string, Object>): SplashBottomTextChild {
    const child = new SplashBottomTextChild();
    child.fontSize = map.get('fontSize') as number;
    child.color = map.get('color') as string;
    child.x = map.get('x') as number;
    child.y = map.get('y') as number;
    child.text = map.get('text') as string;
    return child;
  }
}