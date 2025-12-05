import '../data/amps_native_interactive_listener.dart';
import 'widget_layout.dart';
///自渲染组件自定义内容
class NativeUnifiedWidget extends LayoutWidget {
  final double height;
  final String backgroundColor;
  final List<LayoutWidget> children;

  NativeUnifiedWidget({
    required this.height,
    required this.backgroundColor,
    required this.children,
  });

  @override
  Map<String, dynamic> toMap({double? width}) {
    return {
      'type': 'parent',
      'height': height,
      'width': width,
      'backgroundColor': backgroundColor,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }
}
///自渲染主图组件
class UnifiedMainImgWidget extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  final String backgroundColor;
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedMainImgWidget({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.backgroundColor,
    this.clickType = AMPSAdItemClickType.none,
    this.clickIdType = AMPSAdItemClickIdType.click
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'mainImage',
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'backgroundColor': backgroundColor,
      'clickType': clickType.value,
      'clickIdType': clickIdType.value
    };
  }
}
///自渲染点击类型
enum AMPSAdItemClickType {
  none(-1),
  click(0), // 默认跳转事件
  complain(2000), // 展示投诉弹窗
  close(2001), // 关闭广告
  logo(2002); // logo事件，穿山甲支持

  final int value;

  const AMPSAdItemClickType(this.value);
}
///自渲染点击Id类型
enum AMPSAdItemClickIdType {
  click(0),
  create(1);
  final int value;
  const AMPSAdItemClickIdType(this.value);
}

///问题结尾样式
enum Ellipsize {
  /// 1. 无省略（默认行为，文本会自动换行或溢出显示）
  /// 对应 Android 中 ellipsize="none"
  none(0),

  /// 2. 文本末尾显示省略号（...）
  /// 对应 Android 中 ellipsize="end"（最常用，单行/多行均支持）
  end(1),

  /// 3. 文本开头显示省略号（...）
  /// 对应 Android 中 ellipsize="start"（仅单行有效）
  start(2),

  /// 4. 文本中间显示省略号（...）
  /// 对应 Android 中 ellipsize="middle"（仅单行有效）
  middle(3),

  /// 5. 文本滚动显示（跑马灯效果）
  /// 对应 Android 中 ellipsize="marquee"（需配合 focusable 等属性启用）
  marquee(4);
  final int value;
  const Ellipsize(this.value);
}

///自渲染主题
class UnifiedTitleWidget extends LayoutWidget {
  final double fontSize;
  final String color;
  final double x;
  final double y;
  int maxLines;
  Ellipsize ellipsize;
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedTitleWidget({
    required this.fontSize,
    required this.color,
    required this.x,
    required this.y,
    this.maxLines = 0,
    this.ellipsize = Ellipsize.none,
    this.clickType = AMPSAdItemClickType.none,
    this.clickIdType = AMPSAdItemClickIdType.click,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'mainTitle',
      'fontSize': fontSize,
      'color': color,
      'x': x,
      'y': y,
      'maxLines': maxLines,
      'ellipsize': ellipsize.value,
      'clickType': clickType.value,
      'clickIdType': clickIdType.value
    };
  }
}

///自渲染描述
class UnifiedDescWidget extends LayoutWidget {
  final double fontSize;
  final String color;
  final double width;
  final double x;
  final double y;
  int maxLines;
  Ellipsize ellipsize;
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedDescWidget({
    required this.fontSize,
    required this.width,
    required this.color,
    required this.x,
    required this.y,
    this.maxLines = 0,
    this.ellipsize = Ellipsize.none,
    this.clickType = AMPSAdItemClickType.none,
    this.clickIdType = AMPSAdItemClickIdType.click,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'descText',
      'fontSize': fontSize,
      'color': color,
      'width': width,
      'x': x,
      'y': y,
      'maxLines': maxLines,
      'ellipsize': ellipsize.value,
      'clickType': clickType.value,
      'clickIdType': clickIdType.value
    };
  }
}

enum ButtonType { capsule, circle, normal, roundedRectangle }

///actionText
class UnifiedActionButtonWidget extends LayoutWidget {
  final double fontSize;
  final String fontColor;
  final double x;
  final double y;
  double? width;
  double? height;
  String? backgroundColor;
  ButtonType buttonType;
  AMPSAdItemClickType clickType; //可选参数
  AMPSAdItemClickIdType clickIdType;


  UnifiedActionButtonWidget({
    required this.fontSize,
    required this.fontColor,
    required this.x,
    required this.y,
    this.height,
    this.width,
    this.backgroundColor,
    this.buttonType = ButtonType.capsule,
    this.clickType = AMPSAdItemClickType.none,
    this.clickIdType = AMPSAdItemClickIdType.click,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'actionButton',
      'fontSize': fontSize,
      'fontColor': fontColor,
      'backgroundColor': backgroundColor,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'clickType': clickType.value,
      'buttonType': buttonType.name,
      'clickIdType': clickIdType.value
    };
  }
}

///自渲染icon
class UnifiedAppIconWidget extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedAppIconWidget({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.clickType = AMPSAdItemClickType.none,
    this.clickIdType = AMPSAdItemClickIdType.click
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'appIcon',
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'clickType': clickType.value,
      'clickIdType': clickIdType.value
    };
  }
}
class UnifiedAdSourceLogoWidget extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedAdSourceLogoWidget({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    this.clickType = AMPSAdItemClickType.none,
    this.clickIdType = AMPSAdItemClickIdType.click
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'adSourceLogo',
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'clickType': clickType.value,
      'clickIdType': clickIdType.value
    };
  }
}
///自渲染视频
class UnifiedVideoWidget extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;

  UnifiedVideoWidget(
      {required this.width,
      required this.height,
      required this.x,
      required this.y});

  @override
  Map<String, dynamic> toMap() {
    return {'type': 'video', 'width': width, 'height': height, 'x': x, 'y': y};
  }
}

///关闭按钮
class UnifiedCloseWidget extends LayoutWidget {
  final String imagePath;
  final double width;
  final double height;
  final double x;
  final double y;
  UnifiedCloseWidget({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.x,
    required this.y
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'closeIcon',
      'imagePath': imagePath,
      'width': width,
      'height': height,
      'x': x,
      'y': y
    };
  }
}

///摇一摇组件，android有
class ShakeWidget extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  ShakeWidget({
    required this.width,
    required this.height,
    required this.x,
    required this.y
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'shake',
      'width': width,
      'height': height,
      'x': x,
      'y': y
    };
  }

}

///滑动组件，android有
class SlideWidget extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  final int repeatCount;
  SlideWidget({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.repeatCount
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'slide',
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'repeatCount': repeatCount
    };
  }
}