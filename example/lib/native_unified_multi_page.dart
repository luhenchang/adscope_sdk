import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:flutter/material.dart';

import 'union_download_app_info_page.dart';

/// 同一广告位发起 8 次独立请求（每次 adCount=1），并插入 Feed 列表不同位置。
class NativeUnifiedMultiPage extends StatefulWidget {
  const NativeUnifiedMultiPage({super.key, required this.title});

  final String title;

  @override
  State<NativeUnifiedMultiPage> createState() => _NativeUnifiedMultiPageState();
}

enum _ListEntryType { feed, adSlot }

class _ListEntry {
  _ListEntry.feed(this.feedIndex, this.feedText)
      : type = _ListEntryType.feed,
        adId = null,
        slotIndex = null;

  _ListEntry.adSlot(this.slotIndex)
      : type = _ListEntryType.adSlot,
        feedIndex = null,
        feedText = null,
        adId = null;

  final _ListEntryType type;
  final int? feedIndex;
  final String? feedText;
  final String? adId;
  final int? slotIndex;
}

class _AdSlotData {
  _AdSlotData({
    required this.adId,
    required this.pattern,
    required this.images,
    required this.layoutChildren,
    this.downloadInfo,
    this.carouselEpoch = 0,
  });

  final String adId;
  final AMPSUnifiedPattern pattern;
  final List<String> images;
  final List<LayoutWidget> layoutChildren;
  final UnifiedAdDownloadAppInfo? downloadInfo;
  final int carouselEpoch;
}

class _NativeUnifiedMultiPageState extends State<NativeUnifiedMultiPage> {
  static const int _adCount = 8;

  /// 在第 N 条 Feed 之后插入广告（共 8 个槽位，间隔不同）
  static const List<int> _adInsertAfterFeedIndex = [1, 4, 7, 10, 13, 16, 19, 22];

  final Map<int, AMPSNativeAd> _nativeAdsBySlot = {};
  final Map<String, int> _adIdToSlot = {};
  final Map<int, AmpsNativeInteractiveListener> _interactiveListenersBySlot = {};
  final List<String> _feedList = [];
  late final List<ValueNotifier<_AdSlotData?>> _slotNotifiers;
  final ValueNotifier<int> _visibleAdCount = ValueNotifier(0);

  final double expressWidth = 350;
  final double expressHeight = 180;

  @override
  void initState() {
    super.initState();
    _slotNotifiers = List.generate(_adCount, (_) => ValueNotifier<_AdSlotData?>(null));
    for (var i = 0; i < 30; i++) {
      _feedList.add('item name =$i');
    }
  }

  @override
  void dispose() {
    for (final ad in _nativeAdsBySlot.values) {
      ad.destroy();
    }
    for (final notifier in _slotNotifiers) {
      notifier.dispose();
    }
    _visibleAdCount.dispose();
    super.dispose();
  }

  void _refreshVisibleCount() {
    var count = 0;
    for (final notifier in _slotNotifiers) {
      if (notifier.value != null) count++;
    }
    _visibleAdCount.value = count;
  }

  AMPSNativeAdListener _adListenerFor(int slot) {
    return AMPSNativeAdListener(
      loadOk: (adIds) {
        debugPrint('[slot$slot] loadOk adIds=$adIds instanceId=${_nativeAdsBySlot[slot]?.instanceId}');
      },
      loadFail: (code, message) {
        debugPrint('[slot$slot] loadFail=$code, $message');
      },
    );
  }

  AMPSNativeRenderListener _renderListenerFor(int slot) {
    return AMPSNativeRenderListener(
      renderSuccess: (adId) => _applySlotMaterial(slot, adId),
      renderFailed: (adId, code, message) {
        debugPrint('[slot$slot] renderFailed adId=$adId code=$code msg=$message');
      },
      onCarouselAdLoad: (adId) => _applySlotMaterial(slot, adId, isCarousel: true),
    );
  }

  Future<void> _applySlotMaterial(
    int slot,
    String adId, {
    bool isCarousel = false,
  }) async {
    debugPrint('[slot$slot] ${isCarousel ? 'carouselAdLoad' : 'renderSuccess'} adId=$adId');
    final ad = _nativeAdsBySlot[slot];
    final pattern = await ad?.getUnifiedPattern(adId) ?? AMPSUnifiedPattern.adPatternUnknown;
    final images = await ad?.getUnifiedImages(adId) ?? const <String>[];
    final downloadInfo = await ad?.getDownLoadInfo(adId);
    if (!mounted) return;
    _adIdToSlot[adId] = slot;
    final prev = _slotNotifiers[slot].value;
    _slotNotifiers[slot].value = _AdSlotData(
      adId: adId,
      pattern: pattern,
      images: images,
      layoutChildren: _buildLayoutChildren(pattern.value, imageUrls: images),
      downloadInfo: downloadInfo,
      carouselEpoch: isCarousel ? (prev?.carouselEpoch ?? 0) + 1 : 0,
    );
    if (!isCarousel) {
      _refreshVisibleCount();
    }
  }

  AmpsNativeInteractiveListener _interactiveListenerFor(int slot) {
    return _interactiveListenersBySlot.putIfAbsent(slot, () {
      return AmpsNativeInteractiveListener(
        onAdShow: (adId) => debugPrint('[slot$slot] onAdShow=$adId'),
        onAdExposure: (adId) => debugPrint('[slot$slot] onAdExposure=$adId'),
        onAdClicked: (adId) => debugPrint('[slot$slot] onAdClicked=$adId'),
        toCloseAd: (adId) {
          debugPrint('[slot$slot] onClose=$adId');
          _handleAdClosed(adId);
        },
      );
    });
  }

  void _handleAdClosed(String? adId) {
    if (adId == null) return;
    final slot = _adIdToSlot[adId];
    if (slot == null) return;
    _slotNotifiers[slot].value = null;
    _adIdToSlot.remove(adId);
    _refreshVisibleCount();
  }

  void _loadEightAds() {
    _destroyAd();
    for (var slot = 0; slot < _adCount; slot++) {
      final options = AdOptions(
        spaceId: unifiedSpaceId,
        adCount: 1,
        expressSize: [expressWidth, expressHeight],
      );
      final ad = AMPSNativeAd(
        config: options,
        nativeType: NativeType.unified,
        mCallBack: _adListenerFor(slot),
        mRenderCallBack: _renderListenerFor(slot),
      );
      _nativeAdsBySlot[slot] = ad;
      debugPrint('[slot$slot] load 1 ad instanceId=${ad.instanceId}');
      ad.load();
    }
  }

  void _destroyAd() {
    for (final ad in _nativeAdsBySlot.values) {
      ad.destroy();
    }
    _nativeAdsBySlot.clear();
    _adIdToSlot.clear();
    _interactiveListenersBySlot.clear();
    for (final notifier in _slotNotifiers) {
      notifier.value = null;
    }
    _refreshVisibleCount();
  }

  List<_ListEntry> _buildDisplayEntries() {
    final entries = <_ListEntry>[];
    var slotCursor = 0;
    for (var feedIndex = 0; feedIndex < _feedList.length; feedIndex++) {
      entries.add(_ListEntry.feed(feedIndex, _feedList[feedIndex]));
      if (slotCursor < _adInsertAfterFeedIndex.length &&
          _adInsertAfterFeedIndex[slotCursor] == feedIndex) {
        // 固定占位：无论是否已加载/已关闭，槽位始终在列表中
        entries.add(_ListEntry.adSlot(slotCursor));
        slotCursor++;
      }
    }
    return entries;
  }

  Widget _buildAdSlot(int slotIndex) {
    return _AdSlotKeepAliveItem(
      slotIndex: slotIndex,
      notifier: _slotNotifiers[slotIndex],
      builder: (data) => _buildAdItem(data, slotIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildDisplayEntries();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _loadEightAds,
                  child: Text('8次请求(每次1条)'),
                ),
                ElevatedButton(
                  onPressed: _destroyAd,
                  child: const Text('销毁广告'),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: _visibleAdCount,
                  builder: (context, count, _) => Text(
                    '已渲染: $count/$_adCount',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                if (entry.type == _ListEntryType.adSlot) {
                  return KeyedSubtree(
                    key: ValueKey('ad_slot_${entry.slotIndex}'),
                    child: _buildAdSlot(entry.slotIndex!),
                  );
                }
                return KeyedSubtree(
                  key: ValueKey('feed_${entry.feedIndex}'),
                  child: _buildFeedItem(entry.feedText!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(String text) {
    return Column(
      children: [
        const Divider(height: 5, color: Colors.white),
        Container(
          height: 60,
          width: expressWidth,
          color: Colors.blueAccent,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 12),
          child: Text('List $text'),
        ),
      ],
    );
  }

  Widget _buildAdItem(_AdSlotData data, int slotIndex) {
    final nativeAd = _nativeAdsBySlot[slotIndex];
    final adId = data.adId;
    final downloadInfo = data.downloadInfo;
    return KeyedSubtree(
      key: ValueKey('ad_content_${slotIndex}_${adId}_${data.carouselEpoch}'),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 5, color: Colors.orange),
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Text(
            '广告槽位[$slotIndex] · 第${slotIndex + 1}次请求 · 插入Feed#${_adInsertAfterFeedIndex[slotIndex]}后 · adId=$adId',
            style: const TextStyle(fontSize: 12, color: Colors.deepOrange),
          ),
        ),
        SizedBox.fromSize(
          size: Size(expressWidth, expressHeight),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              UnifiedWidget(
                nativeAd,
                mInteractiveCallBack: _interactiveListenerFor(slotIndex),
                key: ValueKey('unified_${slotIndex}_${adId}_${data.carouselEpoch}'),
                adId: adId,
                unifiedContent: NativeUnifiedWidget(
                  width: expressWidth,
                  height: expressHeight,
                  backgroundColor: '#80F7FF',
                  children: data.layoutChildren,
                ),
              ),
              Positioned(
                top: 8,
                right: 26,
                child: InkWell(
                  onTap: () => _handleAdClosed(adId),
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/close.png', width: 18, height: 18),
                ),
              ),
              if (downloadInfo != null && _downLoadAppInfoIsOk(downloadInfo))
                Positioned(
                  left: 28,
                  top: 100,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        'UnionDownloadAppInfoPage',
                        arguments: AppInfoArguments(
                          titleContent: downloadInfo.appName ?? '',
                          permissionContent: downloadInfo.appPermission ?? '',
                          privacyContent: downloadInfo.appPrivacy ?? '',
                          introContent: downloadInfo.appIntro ?? '',
                        ).toMap(),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      '应用名称：${downloadInfo.appName} | 开发者：${downloadInfo.appDeveloper}',
                      style: const TextStyle(
                        color: Colors.blue,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 5, color: Colors.orange),
      ],
      ),
    );
  }

  List<UnifiedImageItemWidget> _buildCustomImageItems(List<String> imageUrls) {
    const layouts = <({double x, double y, double width, double height})>[
      (x: 0, y: 28, width: 110, height: 120),
      (x: 120, y: 28, width: 110, height: 120),
      (x: 240, y: 28, width: 110, height: 120),
    ];
    final items = <UnifiedImageItemWidget>[];
    for (var i = 0; i < imageUrls.length && i < layouts.length; i++) {
      final slot = layouts[i];
      items.add(
        UnifiedImageItemWidget(
          url: imageUrls[i],
          x: slot.x,
          y: slot.y,
          width: slot.width,
          height: slot.height,
          backgroundColor: '#FFFFFF',
        ),
      );
    }
    return items;
  }

  List<LayoutWidget> _buildLayoutChildren(
    int type, {
    List<String> imageUrls = const [],
  }) {
    switch (type) {
      case 0:
        return [
          UnifiedTitleWidget(fontSize: 18, color: '#1D2129', x: 2, y: 3),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
            clickType: AMPSAdItemClickType.click,
          ),
          UnifiedDescWidget(
            fontSize: 14,
            width: expressWidth - 8,
            color: '#4E5969',
            ellipsize: Ellipsize.end,
            maxLines: 1,
            x: 37,
            y: expressHeight - 30,
          ),
          UnifiedAppIconWidget(width: 25, height: 25, x: 10, y: expressHeight - 30),
          UnifiedAdSourceLogoWidget(
            width: 50,
            height: 25,
            x: expressWidth - 50,
            y: expressHeight - 30,
          ),
          UnifiedActionButtonWidget(
            fontSize: 12,
            width: 50,
            height: 20,
            fontColor: '#FFFFFF',
            backgroundColor: '#2F80ED',
            x: expressWidth - 60,
            y: expressHeight - 60,
          ),
        ];
      case 2:
        return [
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
            clickType: AMPSAdItemClickType.click,
          ),
          UnifiedTitleWidget(fontSize: 18, color: '#1D2129', x: 2, y: 3),
          UnifiedVideoWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 30,
          ),
          UnifiedAppIconWidget(width: 25, height: 25, x: 10, y: expressHeight - 30),
          UnifiedActionButtonWidget(
            fontSize: 12,
            width: 50,
            height: 20,
            fontColor: '#FFFFFF',
            backgroundColor: '#2F80ED',
            x: expressWidth - 60,
            y: expressHeight - 32,
          ),
        ];
      case 1:
        return [
          UnifiedTitleWidget(fontSize: 18, color: '#1D2129', x: 2, y: 3),
          UnifiedImagesWidget(children: _buildCustomImageItems(imageUrls)),
          ShakeWidget(width: 100, height: 100, x: 100, y: 50),
          UnifiedDescWidget(
            fontSize: 14,
            width: 180,
            color: '#4E5969',
            ellipsize: Ellipsize.end,
            maxLines: 1,
            x: 2,
            y: expressHeight - 30,
          ),
        ];
      case 3:
        return [
          UnifiedTitleWidget(fontSize: 18, color: '#1D2129', x: 2, y: 3),
          UnifiedMainImgWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 28,
            backgroundColor: '#FFFFFF',
          ),
          UnifiedVideoWidget(
            width: expressWidth,
            height: expressHeight - 60,
            x: 0,
            y: 30,
          ),
          UnifiedDescWidget(
            fontSize: 14,
            width: 180,
            color: '#4E5969',
            ellipsize: Ellipsize.end,
            maxLines: 1,
            x: 2,
            y: expressHeight - 30,
          ),
          UnifiedActionButtonWidget(
            fontSize: 12,
            width: 50,
            height: 20,
            fontColor: '#FFFFFF',
            backgroundColor: '#2F80ED',
            x: expressWidth - 60,
            y: expressHeight - 32,
          ),
          UnifiedAppIconWidget(width: 25, height: 25, x: 10, y: expressHeight - 30),
          ShakeWidget(width: 100, height: 100, x: 100, y: 50),
        ];
      default:
        return [];
    }
  }

  bool _downLoadAppInfoIsOk(UnifiedAdDownloadAppInfo? downLoadAppInfo) {
    if (downLoadAppInfo == null) return false;
    return downLoadAppInfo.appName != null &&
        downLoadAppInfo.appPermission != null &&
        downLoadAppInfo.appDeveloper != null &&
        downLoadAppInfo.appVersion != null &&
        downLoadAppInfo.appPrivacy != null &&
        downLoadAppInfo.appIntro != null &&
        downLoadAppInfo.appPackageName != null;
  }
}

/// ListView 滑出屏幕时保持 PlatformView 存活，避免滑回来白屏。
class _AdSlotKeepAliveItem extends StatefulWidget {
  const _AdSlotKeepAliveItem({
    required this.slotIndex,
    required this.notifier,
    required this.builder,
  });

  final int slotIndex;
  final ValueNotifier<_AdSlotData?> notifier;
  final Widget Function(_AdSlotData data) builder;

  @override
  State<_AdSlotKeepAliveItem> createState() => _AdSlotKeepAliveItemState();
}

class _AdSlotKeepAliveItemState extends State<_AdSlotKeepAliveItem>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.notifier.value != null;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onSlotDataChanged);
  }

  @override
  void didUpdateWidget(covariant _AdSlotKeepAliveItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier.removeListener(_onSlotDataChanged);
      widget.notifier.addListener(_onSlotDataChanged);
    }
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onSlotDataChanged);
    super.dispose();
  }

  void _onSlotDataChanged() {
    updateKeepAlive();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<_AdSlotData?>(
      valueListenable: widget.notifier,
      builder: (context, data, _) {
        if (data == null) {
          return SizedBox(key: ValueKey('ad_slot_pending_${widget.slotIndex}'), height: 0);
        }
        return widget.builder(data);
      },
    );
  }
}
