import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// 定义常量
const String _kExtraTitle = 'title_content_key';
const String _kExtraPermission = 'permission_content_key';
const String _kExtraPrivacy = 'privacy_content_key';
const String _kExtraIntro = 'intro_content_key';
const Color _kColorSelected = Color(0xFF3D7BF9); // #3D7BF9
const Color _kColorUnselected = Color(0xFFC2C3C5); // #C2C3C5

/// 页面模型，用于传递参数
class AppInfoArguments {
  final String titleContent;
  final String permissionContent;
  final String privacyContent;
  final String introContent;

  AppInfoArguments({
    required this.titleContent,
    required this.permissionContent,
    required this.privacyContent,
    required this.introContent,
  });

  // 用于生成路由参数 Map
  Map<String, dynamic> toMap() {
    return {
      _kExtraTitle: titleContent,
      _kExtraPermission: permissionContent,
      _kExtraPrivacy: privacyContent,
      _kExtraIntro: introContent,
    };
  }

  // 用于从路由参数 Map 创建实例
  factory AppInfoArguments.fromMap(Map<String, dynamic> map) {
    return AppInfoArguments(
      titleContent: map[_kExtraTitle] ?? '',
      permissionContent: map[_kExtraPermission] ?? '',
      privacyContent: map[_kExtraPrivacy] ?? '',
      introContent: map[_kExtraIntro] ?? '',
    );
  }
}

// ----------------------------------------------------------------------
// 页面实现
// ----------------------------------------------------------------------
class UnionDownloadAppInfoPage extends StatefulWidget {
  const UnionDownloadAppInfoPage({super.key});

  @override
  State<UnionDownloadAppInfoPage> createState() =>
      _UnionDownloadAppInfoPageState();
}

class _UnionDownloadAppInfoPageState extends State<UnionDownloadAppInfoPage>
    with SingleTickerProviderStateMixin {
  // 对应 Android 的 titleContent, permissionContent 等
  // 在这里，我们将 _args 初始化为一个带默认值的实例，以避免在第一次 build 时崩溃
  // 如果页面参数是强制性的，更好的做法是在 didChangeDependencies 中抛出异常或 pop 页面
  late AppInfoArguments _args = AppInfoArguments(
      titleContent: '',
      permissionContent: '',
      privacyContent: '',
      introContent: '');

  late TabController _tabController;
  late WebViewController _webViewController;

  // 标志位：确保参数只被解析和初始化一次
  bool _isDataInitialized = false;

  // 0: 权限, 1: 隐私, 2: 介绍 (对应 TabController index)
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // 1. 在 initState 中只进行与 context 无关的初始化

    // 2. 初始化 WebView (initWebView) - 与 context 无关
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      );

    // 3. TabController 的初始化可以放在这里，因为它只需要 vsync
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  // **** 关键改动：在这里解析路由参数 ****
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 只有在数据未初始化时才执行
    if (!_isDataInitialized) {
      // 1. 安全地获取 arguments
      final Map<String, dynamic>? rawArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (rawArgs != null) {
        // 2. 转换数据
        _args = AppInfoArguments.fromMap(rawArgs);
        _isDataInitialized = true;

        // 3. 使用参数进行依赖于 context 的初始化逻辑
        // 4. 显示初始内容 (showPermissionContent)
        _loadContent(_args.permissionContent);
      } else {
        // 如果参数缺失，进行错误处理或提供默认值
        // 这里的 _args 已经有默认的空值，可以继续使用
        _isDataInitialized = true;
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // 现在安全地使用 _args.titleContent
        title: Text(_args.titleContent),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabButton(
                    index: 0, text: '权限', content: _args.permissionContent),
                _buildTabButton(
                    index: 1, text: '隐私', content: _args.privacyContent),
                _buildTabButton(
                    index: 2, text: '介绍', content: _args.introContent),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
    );
  }

  // 辅助函数：构建 Tab 按钮
  Widget _buildTabButton(
      {required int index, required String text, required String content}) {
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: () {
        if (_currentTabIndex != index) {
          _tabController.animateTo(index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getTabColor(index),
          ),
        ),
      ),
    );
  }

  Color _getTabColor(int index) {
    return _currentTabIndex == index ? _kColorSelected : _kColorUnselected;
  }

  void _loadContent(String content) {
    if (content.isEmpty) return;

    final displayContent = content;

    if (displayContent.startsWith("http")) {
      _webViewController.loadRequest(Uri.parse(displayContent));
    } else {
      _webViewController
          .loadHtmlString("<html><body>$displayContent</body></html>");
    }
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }
    setState(() {
      _currentTabIndex = _tabController.index;
    });

    switch (_currentTabIndex) {
      case 0:
        _loadContent(_args.permissionContent);
        break;
      case 1:
        _loadContent(_args.privacyContent);
        break;
      case 2:
        _loadContent(_args.introContent);
        break;
    }
  }
}
