import { List } from '@kit.ArkTS';
import { Any } from '@ohos/flutter_ohos';

// 定义所有子组件类型枚举，提高代码可读性
enum ChildType {
  MAIN_IMAGE = 'mainImage',
  TITLE = 'mainTitle',
  DESC = 'descText',
  ACTION_BUTTON = 'actionButton',
  APP_ICON = 'appIcon',
  VIDEO = 'video',
  CLOSE_ICON = 'closeIcon',
}

// 定义点击类型枚举，与Flutter端保持一致
export enum AdClickType {
  NONE = -1,
  CLICK = 0,
  COMPLAIN = 2000,
  CLOSE = 2001,
  LOGO = 2002,
}

export enum AdClickIdType {
  CLICK = 0,
  CREATE = 1
}

// 定义按钮类型枚举
export enum ButtonType {
  CAPSULE = 'capsule',
  CIRCLE = 'circle',
  NORMAL = 'normal',
  ROUNDED_RECTANGLE = 'roundedRectangle',
}

// 提取子组件通用属性，减少重复代码
export class NativeUnifiedBaseChild {
  x?: number;
  y?: number;
  clickType?: AdClickType; // 新增 clickType 属性
  clickIdType?: AdClickIdType;// 主要是对三方渠道支持
}

// 1. 主图组件
class UnifiedMainImgChild extends NativeUnifiedBaseChild {
  width?: number;
  height?: number;
  backgroundColor?: string;
}

// 2. 标题组件
class UnifiedTitleChild extends NativeUnifiedBaseChild {
  fontSize?: number;
  color?: string;
}

// 3. 描述组件
class UnifiedDescChild extends NativeUnifiedBaseChild {
  fontSize?: number;
  color?: string;
  width?: number;
}

// 4. 动作按钮
class UnifiedActionButtonChild extends NativeUnifiedBaseChild {
  fontSize?: number;
  fontColor?: string;
  width?: number;
  height?: number;
  backgroundColor?: string;
  buttonType?: ButtonType;
}

// 5. 应用图标
class UnifiedAppIconChild extends NativeUnifiedBaseChild {
  width?: number;
  height?: number;
}

// 6. 视频
class UnifiedVideoChild extends NativeUnifiedBaseChild {
  width?: number;
  height?: number;
}

// 7. 关闭按钮
class UnifiedCloseChild extends NativeUnifiedBaseChild {
  imagePath?: string;
  width?: number;
  height?: number;
}


// 主解析类，负责解析整个视图树
export class NativeUnifiedModule {
  mainImgChildren?: UnifiedMainImgChild;
  titleChildren?: UnifiedTitleChild;
  descChildren?: UnifiedDescChild;
  actionButtonChildren?: UnifiedActionButtonChild;
  appIconChildren?: UnifiedAppIconChild;
  videoChildren?: UnifiedVideoChild;
  closeIconChildren?: UnifiedCloseChild;

  height?: number;
  width?: number;
  backgroundColor?: string;
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
    this.height = map.get('height') ?? 0;
    this.width = map.get('width') ?? 0;
    this.backgroundColor = map.get('backgroundColor');
    const childsMap: List<Map<string, Any>> | undefined = map.get('children');
    if (!childsMap) {
      return;
    }

    childsMap.forEach((childMap: Map<string, Any>) => {
      // 使用 switch 语句，根据组件类型创建对应的子组件
      switch (childMap.get('type')) {
        case ChildType.MAIN_IMAGE:
          this.mainImgChildren = this.createMainImageChild(childMap);
          break;
        case ChildType.TITLE:
          this.titleChildren = this.createTitleChild(childMap);
          break;
        case ChildType.DESC:
          this.descChildren = this.createDescChild(childMap);
          break;
        case ChildType.ACTION_BUTTON:
          this.actionButtonChildren = this.createActionButtonChild(childMap);
          break;
        case ChildType.APP_ICON:
          this.appIconChildren = this.createAppIconChild(childMap);
          break;
        case ChildType.VIDEO:
          this.videoChildren = this.createVideoChild(childMap);
          break;
        case ChildType.CLOSE_ICON:
          this.closeIconChildren = this.createCloseChild(childMap);
          break;
      }
    });
  }

  // 提取创建子组件的逻辑到单独的方法
  private createMainImageChild(map: Map<string, Any>): UnifiedMainImgChild {
    const child = new UnifiedMainImgChild();
    child.width = map.get('width');
    child.height = map.get('height');
    child.x = map.get('x');
    child.y = map.get('y');
    child.backgroundColor = map.get('backgroundColor');
    child.clickType = map.get('clickType');
    child.clickIdType = map.get('clickIdType')
    return child;
  }

  private createTitleChild(map: Map<string, Any>): UnifiedTitleChild {
    const child = new UnifiedTitleChild();
    child.fontSize = map.get('fontSize');
    child.color = map.get('color');
    child.x = map.get('x');
    child.y = map.get('y');
    child.clickType = map.get('clickType');
    child.clickIdType = map.get('clickIdType')
    return child;
  }

  private createDescChild(map: Map<string, Any>): UnifiedDescChild {
    const child = new UnifiedDescChild();
    child.fontSize = map.get('fontSize');
    child.color = map.get('color');
    child.width = map.get('width');
    child.x = map.get('x');
    child.y = map.get('y');
    child.clickType = map.get('clickType');
    child.clickIdType = map.get('clickIdType')
    return child;
  }

  private createActionButtonChild(map: Map<string, Any>): UnifiedActionButtonChild {
    const child = new UnifiedActionButtonChild();
    child.fontSize = map.get('fontSize');
    child.fontColor = map.get('fontColor');
    child.backgroundColor = map.get('backgroundColor');
    child.x = map.get('x');
    child.y = map.get('y');
    child.width = map.get('width');
    child.height = map.get('height');
    child.clickType = map.get('clickType');
    child.buttonType = map.get('buttonType');
    child.clickIdType = map.get('clickIdType')
    return child;
  }

  private createAppIconChild(map: Map<string, Any>): UnifiedAppIconChild {
    const child = new UnifiedAppIconChild();
    child.width = map.get('width');
    child.height = map.get('height');
    child.x = map.get('x');
    child.y = map.get('y');
    child.clickType = map.get('clickType');
    child.clickIdType = map.get('clickIdType')
    return child;
  }

  private createVideoChild(map: Map<string, Any>): UnifiedVideoChild {
    const child = new UnifiedVideoChild();
    child.width = map.get('width');
    child.height = map.get('height');
    child.x = map.get('x');
    child.y = map.get('y');
    return child;
  }

  private createCloseChild(map: Map<string, Any>): UnifiedCloseChild {
    const child = new UnifiedCloseChild();
    child.imagePath = map.get('imagePath');
    child.width = map.get('width');
    child.height = map.get('height');
    child.x = map.get('x');
    child.y = map.get('y');
    return child;
  }
}