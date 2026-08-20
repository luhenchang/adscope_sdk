import 'widget_layout.dart';

/// 图片缩放类型，与 Android ImageView.ScaleType 对应
enum ImageScaleType {
  /// 完整显示、等比、居中、允许留白 → FIT_CENTER
  contain,
  /// 等比铺满，超出裁剪 → CENTER_CROP
  cover,
  /// 拉伸变形填满 → FIT_XY
  fill,
}

///开屏底部自定义组件
class SplashBottomWidget extends LayoutWidget {
  final double height;
  final String backgroundColor;
  final List<LayoutWidget> children;

  SplashBottomWidget({
    required this.height,
    required this.backgroundColor,
    required this.children,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'parent',
      'height': height,
      'backgroundColor': backgroundColor,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }
}
///图标
class ImageComponent extends LayoutWidget {
  final double width;
  final double height;
  final double x;
  final double y;
  final String imagePath;
  final ImageScaleType scaleType;

  ImageComponent({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.imagePath,
    this.scaleType = ImageScaleType.fill,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'image',
      'width': width,
      'height': height,
      'x': x,
      'y': y,
      'imagePath': imagePath,
      'scaleType': scaleType.name,
    };
  }
}
///文字
class TextComponent extends LayoutWidget {
  final double fontSize;
  final String color;
  final double x;
  final double y;
  final String text;

  TextComponent({
    required this.fontSize,
    required this.color,
    required this.x,
    required this.y,
    required this.text,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'text',
      'fontSize': fontSize,
      'color': color,
      'x': x,
      'y': y,
      'text': text,
    };
  }
}