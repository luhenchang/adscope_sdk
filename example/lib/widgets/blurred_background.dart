
import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
    return ImageFiltered(
      // 模糊参数：sigmaX（水平模糊度）、sigmaY（垂直模糊度），值越大越模糊
      imageFilter: ImageFilter.blur(sigmaX: 125.0, sigmaY: 125.0),
      // 子组件为需要模糊的图片
      child: Image.asset(
        // 这里替换为你的图片路径
        'assets/images/img.png',
        // 覆盖整个容器
        fit: BoxFit.cover,
      ),
    );
  }
}