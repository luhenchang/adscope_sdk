import 'widget_layout.dart';
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

  ImageComponent({
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.imagePath,
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