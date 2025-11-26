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

///自渲染主题
class UnifiedTitleWidget extends LayoutWidget {
  final double fontSize;
  final String color;
  final double x;
  final double y;
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedTitleWidget({
    required this.fontSize,
    required this.color,
    required this.x,
    required this.y,
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
  AMPSAdItemClickType clickType;
  AMPSAdItemClickIdType clickIdType;

  UnifiedDescWidget({
    required this.fontSize,
    required this.width,
    required this.color,
    required this.x,
    required this.y,
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

///下载六要素，android独有
class DownLoadWidget extends LayoutWidget {
  final double width;
  final double x;
  final double y;
  final double fontSize;
  final String fontColor;
  final String content;
  final AMPSUnifiedDownloadListener? downloadListener;
  DownLoadWidget({
    required this.width,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.fontColor,
    required this.content,
    this.downloadListener
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'downloadInfo',
      'width': width,
      'fontSize': fontSize,
      'x': x,
      'y': y,
      'fontColor': fontColor,
      'content': content
    };
  }
}