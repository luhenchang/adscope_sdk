import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';

/// 开屏底部多分辨率图片加载验证页。
/// 图片 `assets/images/splash_scale_test.png` 在 1x/2x/3x 下颜色不同：
/// - 1x 红色 "1x"
/// - 2x 绿色 "2x"
/// - 3x 蓝色 "3x"
class SplashScaleTestPage extends StatefulWidget {
  const SplashScaleTestPage({super.key, required this.title});

  final String title;

  @override
  State<SplashScaleTestPage> createState() => _SplashScaleTestPageState();
}

class _SplashScaleTestPageState extends State<SplashScaleTestPage> {
  AMPSSplashAd? _splashAd;
  bool _couldBack = true;
  bool _isLoading = false;

  static const _testImagePath = 'assets/images/splash_scale_test.png';

  String _resolutionHint(double devicePixelRatio) {
    if (devicePixelRatio >= 3) {
      return '当前 DPR>=3，原生端应优先加载 3.0x（蓝色 3x）';
    }
    if (devicePixelRatio >= 2) {
      return '当前 DPR>=2，原生端应优先加载 2.0x（绿色 2x）';
    }
    return '当前 DPR<2，原生端应加载基础图（红色 1x）';
  }

  SplashBottomWidget _buildBottomWidget({required bool autoSize}) {
    return SplashBottomWidget(
      height: 120,
      backgroundColor: '#FFFFFFFF',
      children: [
        ImageComponent(
          width: autoSize ? 0 : 60,
          height: autoSize ? 0 : 60,
          x: 20,
          y: 20,
          imagePath: _testImagePath,
          scaleType: ImageScaleType.contain,
        ),
        TextComponent(
          fontSize: 14,
          color: '#333333',
          x: 90,
          y: 24,
          text: autoSize ? '自适应原始尺寸' : '固定 60x60',
        ),
        TextComponent(
          fontSize: 12,
          color: '#666666',
          x: 90,
          y: 50,
          text: '看图片颜色判断加载倍率',
        ),
      ],
    );
  }

  void _loadAndShow({required bool autoSize}) {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _splashAd?.destroy();
    final size = MediaQuery.of(context).size;
    const bottomHeight = 120.0;
    late final AMPSSplashAd splashAd;
    splashAd = AMPSSplashAd(
      config: AdOptions(
        spaceId: splashSpaceId,
        timeoutInterval: timeOut,
        expressSize: [size.width, size.height - bottomHeight],
        splashAdBottomBuilderHeight: bottomHeight.toInt(),
        splashBottomWidget: _buildBottomWidget(autoSize: autoSize),
      ),
      mCallBack: AdCallBack(
        onRenderOk: () {
          _isLoading = false;
          splashAd.showAd();
        },
        onLoadFailure: (code, msg) {
          _isLoading = false;
          debugPrint('[ScaleTest] load failure=$code;$msg');
        },
        onAdShow: () => setState(() => _couldBack = false),
        onAdClosed: () => setState(() => _couldBack = true),
        onAdClicked: () => setState(() => _couldBack = true),
      ),
    );
    _splashAd = splashAd;
    splashAd.load();
  }

  @override
  void dispose() {
    _splashAd?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return PopScope(
      canPop: _couldBack,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          alignment: Alignment.center,
          children: [
            const BlurredBackground(),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '设备 DPR: ${dpr.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _resolutionHint(dpr),
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1x=红 / 2x=绿 / 3x=蓝。若颜色与预期不符，说明多倍图加载路径有问题。',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Flutter 侧预览，便于与原生底部区域对比
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      children: [
                        Image.asset(
                          _testImagePath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        const Positioned(
                          left: 90,
                          top: 24,
                          child: Text('Flutter 预览（自动选图）', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ButtonWidget(
                    buttonText: '开屏 + 固定 60x60 底部图',
                    callBack: () => _loadAndShow(autoSize: false),
                  ),
                  const SizedBox(height: 12),
                  ButtonWidget(
                    buttonText: '开屏 + 宽高为0自适应底部图',
                    callBack: () => _loadAndShow(autoSize: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
