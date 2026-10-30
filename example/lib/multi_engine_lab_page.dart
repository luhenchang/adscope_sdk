import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/data/init_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const multiEngineLabChannel = MethodChannel('adscope_example_multi_engine');
const multiEngineLabRoute = '/engine-b';

const labNativeId = 'lab_native';
const labUnifiedId = 'lab_unified';
const labBannerId = 'lab_banner';
const labDrawId = 'lab_draw';
const labSplashId = 'lab_splash';
const labInterstitialId = 'lab_interstitial';
const labRewardId = 'lab_reward';

class MultiEngineLabApp extends StatelessWidget {
  final String engine;
  const MultiEngineLabApp({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MultiEngineLabPage(engine: engine),
    );
  }
}

class LabLine {
  final String time;
  final String text;
  final bool bad;
  LabLine(this.time, this.text, {this.bad = false});
}

class MultiEngineLabPage extends StatefulWidget {
  final String engine;
  const MultiEngineLabPage({super.key, required this.engine});

  @override
  State<MultiEngineLabPage> createState() => _MultiEngineLabPageState();
}

class _MultiEngineLabPageState extends State<MultiEngineLabPage> {
  InitStatus initStatus = InitStatus.normal;
  bool peerOpened = false;
  int ownCount = 0;
  final ownLogs = <LabLine>[];
  final peerLogs = <LabLine>[];

  AMPSNativeAd? nativeAd;
  String? nativeAdId;
  String nativeStatus = '未加载';

  AMPSNativeAd? unifiedAd;
  String? unifiedAdId;
  String unifiedStatus = '未加载';

  AMPSBannerAd? bannerAd;
  bool bannerReady = false;
  String bannerStatus = '未加载';

  AMPSDrawAd? drawAd;
  String? drawAdId;
  String drawStatus = '未加载';

  AMPSSplashAd? splashAd;
  bool splashReady = false;
  String splashStatus = '未加载';

  AMPSInterstitialAd? interstitialAd;
  bool interstitialReady = false;
  String interstitialStatus = '未加载';

  AMPSRewardVideoAd? rewardAd;
  bool rewardReady = false;
  String rewardStatus = '未加载';

  bool get isEngineA => widget.engine == 'A';

  @override
  void initState() {
    super.initState();
    multiEngineLabChannel.setMethodCallHandler((call) async {
      final args = call.arguments;
      if (args is! Map) return null;
      if (call.method == 'peer') {
        _addPeer('${args['message'] ?? ''}');
      } else if (call.method == 'peerState') {
        if (!mounted) return null;
        setState(() => peerOpened = args['opened'] == true);
      }
      return null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      note('页面就绪。请先初始化，再按下面的步骤操作。');
    });
  }

  @override
  void dispose() {
    nativeAd?.destroy();
    unifiedAd?.destroy();
    bannerAd?.destroy();
    drawAd?.destroy();
    splashAd?.destroy();
    interstitialAd?.destroy();
    rewardAd?.destroy();
    multiEngineLabChannel.setMethodCallHandler(null);
    super.dispose();
  }

  String _clock() {
    final time = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }

  void note(String text, {bool bad = false}) {
    if (!mounted) return;
    final line = '引擎${widget.engine} $text';
    setState(() {
      ownCount += 1;
      ownLogs.insert(0, LabLine(_clock(), line, bad: bad));
      if (ownLogs.length > 40) ownLogs.removeLast();
    });
    multiEngineLabChannel.invokeMethod('publish', {
      'engine': widget.engine,
      'message': line,
    }).catchError((_) {});
  }

  void _addPeer(String text) {
    if (!mounted || text.isEmpty) return;
    setState(() {
      peerLogs.insert(0, LabLine(_clock(), text));
      if (peerLogs.length > 40) peerLogs.removeLast();
    });
  }

  Future<void> _initSdk() async {
    setState(() => initStatus = InitStatus.initialing);
    note('请求初始化');
    final config = AMPSBuilder(appId)
        .setAdCustomController(AMPSCustomController(param: AMPSCustomControllerParam()))
        .build();
    AMPSAdSDK.init(config, AMPSIInitCallBack(
      initSuccess: () {
        if (!mounted) return;
        setState(() => initStatus = InitStatus.success);
        note('初始化结果：initSuccess');
      },
      alreadyInit: () {
        if (!mounted) return;
        setState(() => initStatus = InitStatus.alreadyInit);
        note('初始化结果：alreadyInit（SDK 已经初始化过）');
      },
      initializing: () => note('初始化结果：initializing'),
      initFailed: (code, message) {
        if (!mounted) return;
        setState(() => initStatus = InitStatus.failed);
        note('初始化失败 $code $message', bad: true);
      },
    ));
  }

  Future<void> _openEngineB() async {
    try {
      final opened = await multiEngineLabChannel.invokeMethod('openEngineB');
      if (!mounted) return;
      if (opened == true) {
        setState(() => peerOpened = true);
        note('已请求打开引擎 B');
      } else {
        note('引擎 B 已经打开', bad: true);
      }
    } catch (error) {
      note('打不开引擎 B：$error', bad: true);
    }
  }

  Future<void> _closeEngineB() async {
    note('请求关闭引擎 B');
    try {
      await multiEngineLabChannel.invokeMethod('closeEngineB');
      if (isEngineA && mounted) setState(() => peerOpened = false);
    } catch (error) {
      note('关闭引擎 B 失败：$error', bad: true);
    }
  }

  AdOptions _feedOptions(String spaceId, double width, double height) {
    return AdOptions(spaceId: spaceId, adCount: 1, expressSize: [width, height]);
  }

  Future<void> loadNative() async {
    final width = MediaQuery.sizeOf(context).width - 32;
    await nativeAd?.destroy();
    if (!mounted) return;
    nativeAd = null;
    nativeAdId = null;
    final ad = AMPSNativeAd(
      instanceId: labNativeId,
      config: _feedOptions(nativeSpaceId, width, 128),
      mCallBack: AMPSNativeAdListener(
        loadOk: (ids) => note('信息流 loadOk，实例 $labNativeId，adIds=$ids'),
        loadFail: (code, message) => note('信息流 loadFail $code $message', bad: true),
      ),
      mRenderCallBack: AMPSNativeRenderListener(
        renderSuccess: (adId) {
          if (!mounted) return;
          setState(() {
            nativeAdId = adId;
            nativeStatus = '已渲染';
          });
          note('信息流 renderOk $adId');
        },
        renderFailed: (adId, code, message) {
          note('信息流 renderFail $code $message', bad: true);
        },
      ),
    );
    setState(() {
      nativeAd = ad;
      nativeStatus = '加载中';
    });
    note('信息流开始加载，两个引擎都使用实例 ID $labNativeId');
    ad.load();
  }

  Future<void> loadUnified() async {
    final width = MediaQuery.sizeOf(context).width - 32;
    await unifiedAd?.destroy();
    if (!mounted) return;
    unifiedAd = null;
    unifiedAdId = null;
    final ad = AMPSNativeAd(
      instanceId: labUnifiedId,
      nativeType: NativeType.unified,
      config: _feedOptions(unifiedSpaceId, width, 180),
      mCallBack: AMPSNativeAdListener(
        loadOk: (ids) => note('自渲染 loadOk，实例 $labUnifiedId，adIds=$ids'),
        loadFail: (code, message) => note('自渲染 loadFail $code $message', bad: true),
      ),
      mRenderCallBack: AMPSNativeRenderListener(
        renderSuccess: (adId) {
          if (!mounted) return;
          setState(() {
            unifiedAdId = adId;
            unifiedStatus = '已渲染';
          });
          note('自渲染 renderOk $adId');
        },
        renderFailed: (adId, code, message) => note('自渲染 renderFail $code $message', bad: true),
      ),
    );
    setState(() {
      unifiedAd = ad;
      unifiedStatus = '加载中';
    });
    note('自渲染开始加载，实例 ID $labUnifiedId');
    ad.load();
  }

  Future<void> loadBanner() async {
    final width = MediaQuery.sizeOf(context).width - 32;
    await bannerAd?.destroy();
    if (!mounted) return;
    final ad = AMPSBannerAd(
      instanceId: labBannerId,
      config: _feedOptions(bannerSpaceId, width, 120),
      mCallBack: BannerCallBack(
        onLoadSuccess: () {
          if (!mounted) return;
          setState(() {
            bannerReady = true;
            bannerStatus = '已加载';
          });
          note('横幅 loadOk，实例 $labBannerId');
        },
        onLoadFailure: (code, message) => note('横幅 loadFail $code $message', bad: true),
        onAdShow: () => note('横幅 onAdShow'),
        onAdClicked: () => note('横幅 onAdClicked'),
        onAdClosed: () {
          if (!mounted) return;
          setState(() => bannerReady = false);
          note('横幅 onAdClosed');
        },
      ),
    );
    setState(() {
      bannerAd = ad;
      bannerReady = false;
      bannerStatus = '加载中';
    });
    note('横幅开始加载，实例 ID $labBannerId');
    ad.load();
  }

  Future<void> loadDraw() async {
    final width = MediaQuery.sizeOf(context).width - 32;
    drawAd?.destroy();
    if (!mounted) return;
    drawAd = null;
    drawAdId = null;
    final ad = AMPSDrawAd(
      instanceId: labDrawId,
      config: _feedOptions(drawSpaceId, width, 400),
      mCallBack: AMPSDrawAdListener(
        loadOk: (ids) => note('Draw loadOk，实例 $labDrawId，adIds=$ids'),
        loadFail: (code, message) => note('Draw loadFail $code $message', bad: true),
      ),
      mRenderCallBack: AMPSDrawRenderListener(
        renderSuccess: (adId) {
          if (!mounted) return;
          setState(() {
            drawAdId = adId;
            drawStatus = '已渲染';
          });
          note('Draw renderOk $adId');
        },
        renderFailed: (adId, code, message) => note('Draw renderFail $code $message', bad: true),
      ),
    );
    setState(() {
      drawAd = ad;
      drawStatus = '加载中';
    });
    note('Draw 开始加载，实例 ID $labDrawId');
    ad.load();
  }

  Future<void> loadSplash() async {
    final size = MediaQuery.sizeOf(context);
    await splashAd?.destroy();
    if (!mounted) return;
    final ad = AMPSSplashAd(
      instanceId: labSplashId,
      config: AdOptions(
        spaceId: splashSpaceId,
        splashAdBottomBuilderHeight: 100,
        expressSize: [size.width, size.height],
      ),
      mCallBack: AdCallBack(
        onLoadSuccess: () {
          if (!mounted) return;
          setState(() {
            splashReady = true;
            splashStatus = '可展示';
          });
          note('开屏 loadOk，实例 $labSplashId');
        },
        onLoadFailure: (code, message) => note('开屏 loadFail $code $message', bad: true),
        onAdShow: () => note('开屏 onAdShow'),
        onAdClosed: () => note('开屏 onAdClosed'),
        onAdClicked: () => note('开屏 onAdClicked'),
      ),
    );
    setState(() {
      splashAd = ad;
      splashReady = false;
      splashStatus = '加载中';
    });
    note('开屏开始加载，实例 ID $labSplashId');
    ad.load();
  }

  Future<void> loadInterstitial() async {
    await interstitialAd?.destroy();
    final ad = AMPSInterstitialAd(
      instanceId: labInterstitialId,
      config: AdOptions(spaceId: interstitialSpaceId),
      mCallBack: AdCallBack(
        onLoadSuccess: () {
          if (!mounted) return;
          setState(() {
            interstitialReady = true;
            interstitialStatus = '可展示';
          });
          note('插屏 loadOk，实例 $labInterstitialId');
        },
        onLoadFailure: (code, message) => note('插屏 loadFail $code $message', bad: true),
        onAdShow: () => note('插屏 onAdShow'),
        onAdClosed: () => note('插屏 onAdClosed'),
      ),
    );
    setState(() {
      interstitialAd = ad;
      interstitialReady = false;
      interstitialStatus = '加载中';
    });
    note('插屏开始加载，实例 ID $labInterstitialId');
    ad.load();
  }

  Future<void> loadReward() async {
    await rewardAd?.destroy();
    final ad = AMPSRewardVideoAd(
      instanceId: labRewardId,
      config: AdOptions(spaceId: rewardVideoSpaceId),
      adCallBack: RewardVideoCallBack(
        onLoadSuccess: () {
          if (!mounted) return;
          setState(() {
            rewardReady = true;
            rewardStatus = '可展示';
          });
          note('激励 loadOk，实例 $labRewardId');
        },
        onLoadFailure: (code, message) => note('激励 loadFail $code $message', bad: true),
        onAdShow: () => note('激励 onAdShow'),
        onAdClosed: () => note('激励 onAdClosed'),
        onAdReward: () => note('激励 onAdReward'),
      ),
    );
    setState(() {
      rewardAd = ad;
      rewardReady = false;
      rewardStatus = '加载中';
    });
    note('激励开始加载，实例 ID $labRewardId');
    ad.load();
  }

  Future<void> destroyNative() async {
    await nativeAd?.destroy();
    if (!mounted) return;
    setState(() {
      nativeAd = null;
      nativeAdId = null;
      nativeStatus = '已销毁';
    });
    note('只销毁了本引擎的信息流 $labNativeId');
  }

  Future<void> destroyUnified() async {
    await unifiedAd?.destroy();
    if (!mounted) return;
    setState(() {
      unifiedAd = null;
      unifiedAdId = null;
      unifiedStatus = '已销毁';
    });
    note('只销毁了本引擎的自渲染 $labUnifiedId');
  }

  Future<void> destroyBanner() async {
    await bannerAd?.destroy();
    if (!mounted) return;
    setState(() {
      bannerAd = null;
      bannerReady = false;
      bannerStatus = '已销毁';
    });
    note('只销毁了本引擎的横幅 $labBannerId');
  }

  Future<void> destroyDraw() async {
    drawAd?.destroy();
    if (!mounted) return;
    setState(() {
      drawAd = null;
      drawAdId = null;
      drawStatus = '已销毁';
    });
    note('只销毁了本引擎的 Draw $labDrawId');
  }

  @override
  Widget build(BuildContext context) {
    final accent = isEngineA ? const Color(0xFF1565C0) : const Color(0xFFEF6C00);
    final width = MediaQuery.sizeOf(context).width - 32;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        title: Text('多引擎验证 · 引擎 ${widget.engine}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _steps(),
          const SizedBox(height: 12),
          _dashboard(accent),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: () { _initSdk(); }, child: const Text('1. 初始化本引擎')),
              if (isEngineA)
                FilledButton(onPressed: () { _openEngineB(); }, child: const Text('2. 打开引擎 B')),
              FilledButton(onPressed: () { _closeEngineB(); }, child: Text(isEngineA ? '7. 关闭引擎 B' : '关闭本引擎')),
            ],
          ),
          const SizedBox(height: 16),
          _card(
            title: '3. 信息流',
            id: labNativeId,
            status: nativeStatus,
            onLoad: loadNative,
            onDestroy: destroyNative,
            child: nativeAdId == null
                ? null
                : SizedBox(
                    width: width,
                    height: 220,
                    child: NativeWidget(nativeAd, adId: nativeAdId!, key: ValueKey(nativeAdId)),
                  ),
          ),
          _card(
            title: '4. 自渲染',
            id: labUnifiedId,
            status: unifiedStatus,
            onLoad: loadUnified,
            onDestroy: destroyUnified,
            child: unifiedAdId == null
                ? null
                : SizedBox(
                    width: width,
                    height: 180,
                    child: UnifiedWidget(
                      unifiedAd,
                      adId: unifiedAdId!,
                      key: ValueKey(unifiedAdId),
                      unifiedContent: NativeUnifiedWidget(
                        width: width,
                        height: 180,
                        backgroundColor: '#E3F2FD',
                        children: [
                          UnifiedMainImgWidget(
                            width: width,
                            height: 110,
                            x: 0,
                            y: 0,
                            backgroundColor: '#FFFFFF',
                          ),
                          UnifiedTitleWidget(fontSize: 16, color: '#222222', x: 12, y: 120, width: width - 24),
                          UnifiedActionButtonWidget(
                            fontSize: 14,
                            fontColor: '#FFFFFF',
                            x: 12,
                            y: 146,
                            width: 88,
                            height: 28,
                            backgroundColor: '#1565C0',
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          _card(
            title: '5. 横幅',
            id: labBannerId,
            status: bannerStatus,
            onLoad: loadBanner,
            onDestroy: destroyBanner,
            child: !bannerReady
                ? null
                : SizedBox(width: width, height: 120, child: BannerWidget(bannerAd, key: ValueKey(labBannerId))),
          ),
          _card(
            title: '6. Draw',
            id: labDrawId,
            status: drawStatus,
            onLoad: loadDraw,
            onDestroy: destroyDraw,
            child: drawAdId == null
                ? null
                : SizedBox(
                    width: width,
                    height: 420,
                    child: DrawWidget(drawAd, adId: drawAdId!, key: ValueKey(drawAdId)),
                  ),
          ),
          _overlayCard(
            title: '开屏',
            id: labSplashId,
            status: splashStatus,
            ready: splashReady,
            onLoad: loadSplash,
            onShow: () {
              splashAd?.showAd();
              note('开屏 showAd');
            },
          ),
          _overlayCard(
            title: '插屏',
            id: labInterstitialId,
            status: interstitialStatus,
            ready: interstitialReady,
            onLoad: loadInterstitial,
            onShow: () {
              interstitialAd?.showAd();
              note('插屏 showAd');
            },
          ),
          _overlayCard(
            title: '激励视频',
            id: labRewardId,
            status: rewardStatus,
            ready: rewardReady,
            onLoad: loadReward,
            onShow: () {
              rewardAd?.showAd();
              note('激励 showAd');
            },
          ),
          const SizedBox(height: 8),
          Text('本引擎回调（只应在你操作的这一边增加）', style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _logBox(ownLogs, empty: '还没有本引擎回调'),
          const SizedBox(height: 12),
          const Text('对端动态（宿主转发过来，用来对照，不是广告通道串线）', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          _logBox(peerLogs, empty: '另一台引擎还没有动作'),
        ],
      ),
    );
  }

  Widget _steps() {
    const lines = [
      '1. 引擎 A 点初始化。从主页进来时，主页可能已经初始化过，这里会显示已初始化。',
      '2. 点「打开引擎 B」。B 是另一个 FlutterEngine，再点一次初始化。',
      '3. 两边加载同一个广告，实例 ID 相同。看广告出现在哪一边。',
      '4. 本引擎回调只增加自己点的那次。另一边条数不变，只在「对端动态」里看到这条记录。',
      '5. 同样试自渲染、横幅、Draw、开屏、插屏、激励。',
      '6. 点「销毁」。只清掉这一边，切回另一边，广告还在。',
      '7. 关闭引擎 B，回到 A，再用同一个信息流 ID 加载。',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: const TextStyle(height: 1.35)),
            ),
        ],
      ),
    );
  }

  Widget _dashboard(Color accent) {
    final initText = {
      InitStatus.normal: '未初始化',
      InitStatus.initialing: '初始化中',
      InitStatus.success: 'initSuccess',
      InitStatus.alreadyInit: 'alreadyInit',
      InitStatus.failed: '失败',
    }[initStatus]!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip('初始化', initText, accent),
        _chip('引擎 B', peerOpened || !isEngineA ? '已打开' : '未打开', accent),
        _chip('本引擎记录', '$ownCount', accent),
        _chip('对端动态', '${peerLogs.length}', accent),
      ],
    );
  }

  Widget _chip(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('$label：$value'),
    );
  }

  Widget _card({
    required String title,
    required String id,
    required String status,
    required Future<void> Function() onLoad,
    required Future<void> Function() onDestroy,
    Widget? child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('实例 ID $id · $status'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(onPressed: () { onLoad(); }, child: const Text('加载')),
                OutlinedButton(onPressed: () { onDestroy(); }, child: const Text('销毁本引擎')),
              ],
            ),
            if (child != null) ...[const SizedBox(height: 8), child],
          ],
        ),
      ),
    );
  }

  Widget _overlayCard({
    required String title,
    required String id,
    required String status,
    required bool ready,
    required Future<void> Function() onLoad,
    required void Function() onShow,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text('实例 ID $id · $status'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(onPressed: () { onLoad(); }, child: const Text('加载')),
                OutlinedButton(onPressed: ready ? onShow : null, child: const Text('展示')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _logBox(List<LabLine> lines, {required String empty}) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72, maxHeight: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D7DE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: lines.isEmpty
          ? Text(empty, style: const TextStyle(color: Colors.black54))
          : ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                return Text(
                  '${line.time}  ${line.text}',
                  style: TextStyle(color: line.bad ? Colors.red.shade700 : Colors.black87, height: 1.3),
                );
              },
            ),
    );
  }
}
