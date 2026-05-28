import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/reward_video_page.dart';
import 'package:adscope_sdk_example/splash_widget_page.dart';
import 'package:adscope_sdk_example/union_download_app_info_page.dart';
import 'package:flutter/material.dart';
import 'banner_widget_page.dart';
import 'data/common.dart';
import 'data/init_data.dart';
import 'draw_page.dart';
import 'interstitial_page.dart';
import 'interstitial_show_page.dart';
import 'native_page.dart';
import 'native_unified_page.dart';
import 'splash_show_page.dart' show SplashShowPage;
import 'widgets/blurred_background.dart';
import 'widgets/button_widget.dart';

void main() {
  // 插件初始化前建议调用
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'SplashPage',
      // 使用变量管理路由，避免硬编码字符串
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      'SplashPage': (context) => const SplashPage(title: '主控面板'),
      'SplashShowPage':(context)=>const SplashShowPage(title: '开屏show页面'),
      'SplashWidgetPage':(context)=>const SplashWidgetPage(title: '开屏页面'),
      'InterstitialShowPage':(context)=> const InterstitialShowPage(title: '插屏show页面'),
      'InterstitialPage':(context)=> const InterstitialPage(title: '插屏组件页面'),
      'NativePage':(context)=> const NativePage(title: '原生页面'),
      'NativeUnifiedPage':(context)=> const NativeUnifiedPage(title: '原生自渲染页面'),
      'RewardVideoPage':(context)=> const RewardVideoPage(title: '激励视频页面'),
      'BannerPage':(context)=> const BannerWidgetPage(title: 'Banner页面'),
      'DrawPage':(context)=> const DrawPage(title: 'Draw页面'),
      'UnionDownloadAppInfoPage': (context) => const UnionDownloadAppInfoPage()
    };
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.title});
  final String title;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  InitStatus _initStatus = InitStatus.normal;
  AMPSSplashAd? _splashAd;
  bool _couldBack = true;

  // 1. 将重复的按钮配置数据化，方便维护
  final List<Map<String, String>> _menuConfig = [
    {'text': '开屏show案例页面', 'route': 'SplashShowPage'},
    {'text': '开屏组件案例页面', 'route': 'SplashWidgetPage'},
    {'text': '插屏show案例页面', 'route': 'InterstitialShowPage'},
    {'text': '插屏组件案例页面', 'route': 'InterstitialPage'},
    {'text': '点击跳转原生页面', 'route': 'NativePage'},
    {'text': '点击跳转自渲染页面', 'route': 'NativeUnifiedPage'},
    {'text': '点击跳转激励视频页面', 'route': 'RewardVideoPage'},
    {'text': '点击跳转Banner页面', 'route': 'BannerPage'},
    {'text': '点击跳转Draw页面', 'route': 'DrawPage'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initSDK();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 初始化 SDK 逻辑抽取
  void _initSDK() {
    final sdkConfig = AMPSBuilder(appId)
        .setAdCustomController(AMPSCustomController(param: AMPSCustomControllerParam()))
        .build();

    final callBack = AMPSIInitCallBack(
      initSuccess: () => _updateStatus(InitStatus.success, loadAd: true),
      alreadyInit: () => _updateStatus(InitStatus.alreadyInit, loadAd: true),
      initializing: () => debugPrint("adk is initializing"),
      initFailed: (code, msg) {
        debugPrint("adk initFailed: $code, $msg");
        _updateStatus(InitStatus.failed);
      },
    );

    AMPSAdSDK.init(sdkConfig, callBack);
  }

  /// 统一管理状态更新，增加 mounted 检查防止异步崩溃
  void _updateStatus(InitStatus status, {bool loadAd = false}) {
    // 确保在树渲染完成后再执行
    if (!mounted) return;
    setState(() => _initStatus = status);
    if (loadAd) _prepareSplashAd();

  }

  void _prepareSplashAd() {
    var size = MediaQuery.of(context).size;
    final adOptions = AdOptions(spaceId: splashSpaceId, splashAdBottomBuilderHeight: 100,expressSize: [size.width,size.height]);
    _splashAd = AMPSSplashAd(
      config: adOptions,
      mCallBack: AdCallBack(
        onRenderOk: () => _splashAd?.showAd(),
        onAdShow: () => _setBackPolicy(false),
        onAdClosed: () => _setBackPolicy(true),
        onAdClicked: () => _setBackPolicy(true),
        onLoadFailure: (code, msg) => debugPrint("Ad Load Failed: $msg"),
      ),
    );
    _splashAd?.load();
  }

  void _setBackPolicy(bool canBack) {
    if (mounted) setState(() => _couldBack = canBack);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _couldBack,
      child: Scaffold(
        body: Stack(
          children: [
            const BlurredBackground(),
            SafeArea( // 3. 增加 SafeArea 适配异形屏
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildStatusButton(),
                  Expanded(
                    // 4. 使用 ListView 替代 Column，解决屏幕高度不足时的溢出问题
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      itemCount: _menuConfig.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        return ButtonWidget(
                          buttonText: _menuConfig[index]['text']!,
                          callBack: () => Navigator.pushNamed(context, _menuConfig[index]['route']!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton() {
    return ButtonWidget(
      buttonText: _getInitStatusText(_initStatus),
      backgroundColor: _getInitStatusColor(_initStatus),
      callBack: (){
        if(_initStatus == InitStatus.failed) {
          _initSDK();
        }
      },
    );
  }

  // 使用映射或简单的 Switch 保持代码整洁
  String _getInitStatusText(InitStatus status) {
    return {
      InitStatus.normal: '点击初始化SDK',
      InitStatus.initialing: '初始化中',
      InitStatus.alreadyInit: '已初始化',
      InitStatus.success: '初始化成功',
      InitStatus.failed: '初始化失败(重试)',
    }[status] ?? '未知状态';
  }

  Color _getInitStatusColor(InitStatus status) {
    if (status == InitStatus.failed) return Colors.red;
    if (status == InitStatus.success || status == InitStatus.alreadyInit) return Colors.green;
    return Colors.blue;
  }
}