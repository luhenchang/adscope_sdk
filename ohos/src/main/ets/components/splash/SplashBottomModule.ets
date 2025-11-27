import { List } from '@kit.ArkTS';
import { Any } from '@ohos/flutter_ohos';

// 定义子组件类型枚举，提高代码可读性和类型安全
enum ChildType {
  IMAGE = 'image',
  TEXT = 'text'
}

// 提取子组件通用属性，减少重复代码
class SplashBottomBaseChild {
  x?: number;
  y?: number;
}

// 继承通用父类，并补充自身特有属性
class SplashBottomImageChild extends SplashBottomBaseChild {
  width?: number;
  height?: number;
  imagePath?: string;
}

// 继承通用父类，并补充自身特有属性
class SplashBottomTextChild extends SplashBottomBaseChild {
  fontSize?: number;
  color?: string;
  text?: string;
}

export class SplashBottomModule {
  // 使用类型更明确的数组
  imgChildren?: SplashBottomImageChild;
  textChildren?: SplashBottomTextChild;
  height: number = 0;
  backgroundColor: string = "#00000000";
  initialized: boolean = false;

  constructor(map: Map<string, Any>) {
    this.getBottomModuleFromMap(map);
  }

  private getBottomModuleFromMap(map: Map<string, Any>) {
    // 检查 map 是否存在且类型正确
    if (!map || map.get('type') !== 'parent') {
      console.warn('Invalid map provided. Expected type "parent".');
      return;
    }
    this.initialized = true;
    this.height = map.get('height') ?? 0; // 使用空值合并运算符提供默认值
    this.backgroundColor = map.get('backgroundColor')
    const childsMap: List<Map<string, Any>> | undefined = map.get('children');
    if (!childsMap) {
      return;
    }

    childsMap.forEach((childMap: Map<string, Any>) => {
      // 使用 switch 语句代替 if-else，结构更清晰
      switch (childMap.get('type')) {
        case ChildType.IMAGE:
          this.imgChildren = this.createImageChild(childMap);
          break;
        case ChildType.TEXT:
          this.textChildren = this.createTextChild(childMap)
          break;
      }
    });
  }

  // 提取创建子组件的逻辑到单独的方法
  private createImageChild(map: Map<string, Any>): SplashBottomImageChild {
    const child = new SplashBottomImageChild();
    child.width = map.get('width');
    child.height = map.get('height');
    child.x = map.get('x');
    child.y = map.get('y');
    child.imagePath = map.get('imagePath');
    return child;
  }

  private createTextChild(map: Map<string, Any>): SplashBottomTextChild {
    const child = new SplashBottomTextChild();
    child.fontSize = map.get('fontSize');
    child.color = map.get('color');
    child.x = map.get('x');
    child.y = map.get('y');
    child.text = map.get('text');
    return child;
  }
}