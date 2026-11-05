import 'dart:async';
import 'dart:convert';

import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/common.dart';

/// 高商词的单商品路径：普通自渲染，不申请或创建商城页面。
class GMMallProductPage extends StatefulWidget {
  const GMMallProductPage({super.key});
  @override
  State<GMMallProductPage> createState() => _GMMallProductPageState();
}

class _GMMallProductPageState extends State<GMMallProductPage> {
  final _space = TextEditingController(text: mallProductSpaceId);
  final _query = TextEditingController(text: '手机');
  AMPSNativeAd? _ad;
  String? _id;
  Map<String, dynamic> _extras = {};
  AMPSUnifiedPattern _pattern = AMPSUnifiedPattern.adPatternTextImage;
  List<String> _images = [];
  String _status = '等待加载';
  bool _loading = false;
  int _generation = 0;
  int _epoch = 0;

  Future<void> _showProduct(String id, int generation) async {
    final ad = _ad;
    if (ad == null) return;
    try {
      final extras = await ad.getUnifiedExtras(id);
      final pattern = await ad.getUnifiedPattern(id);
      final images = await ad.getUnifiedImages(id);
      if (!mounted || generation != _generation) return;
      setState(() {
        _extras = extras;
        _pattern = pattern;
        _images = images;
        _id = id;
        _epoch++;
        _loading = false;
        _status = '单商品已加载；曝光、点击由原生自渲染视图处理';
      });
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _status = '读取商品失败：$e';
        });
      }
    }
  }

  Future<void> _load() async {
    if (_space.text.trim().isEmpty || _query.text.trim().isEmpty) {
      setState(() => _status = '请填写单商品自渲染广告位和高商词');
      return;
    }
    FocusScope.of(context).unfocus();
    final generation = ++_generation;
    final previous = _ad;
    _ad = null;
    setState(() {
      _id = null;
      _extras = {};
      _loading = true;
      _status = '加载中';
    });
    try {
      await previous?.destroy();
      if (!mounted || generation != _generation) return;
      _ad = AMPSNativeAd(
        nativeType: NativeType.unified,
        config: AdOptions(
            spaceId: _space.text.trim(),
            mallQuery: _query.text.trim(),
            adCount: 1,
            expressSize: [MediaQuery.sizeOf(context).width - 32, 300]),
        mCallBack: AMPSNativeAdListener(
          loadOk: (ids) {
            if (!mounted || generation != _generation) return;
            if (ids.isNotEmpty) {
              unawaited(_showProduct(ids.first, generation));
            } else {
              setState(() {
                _loading = false;
                _status = '未返回商品';
              });
            }
          },
          loadFail: (code, message) {
            if (mounted && generation == _generation) {
              setState(() {
                _loading = false;
                _id = null;
                _status = '[$code] $message';
              });
            }
          },
        ),
        mRenderCallBack: AMPSNativeRenderListener(
          onCarouselAdLoad: (id) {
            if (generation == _generation) {
              unawaited(_showProduct(id, generation));
            }
          },
        ),
      );
      await _ad!.load();
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() {
          _loading = false;
          _status = '加载失败：$e';
        });
      }
    }
  }

  Future<void> _destroy() async {
    ++_generation;
    final ad = _ad;
    _ad = null;
    setState(() {
      _id = null;
      _extras = {};
      _loading = false;
      _status = '已销毁';
    });
    await ad?.destroy();
  }

  @override
  void dispose() {
    ++_generation;
    final ad = _ad;
    if (ad != null) {
      unawaited(ad.destroy().catchError((Object e) {
        debugPrint('$e');
      }));
    }
    _space.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supported = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    final width = MediaQuery.sizeOf(context).width - 32;
    return Scaffold(
      appBar: AppBar(title: const Text('高商词单商品测试')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('App ID：$appId（沿用首页初始化）'),
        const Text('使用未勾选商城页的单商品自渲染广告位；搜索结果页请使用嵌入式商城测试。'),
        TextField(
            key: const Key('product-space'),
            controller: _space,
            decoration: const InputDecoration(labelText: '单商品自渲染广告位 ID')),
        TextField(
            key: const Key('product-query'),
            controller: _query,
            decoration: const InputDecoration(labelText: '高商词（必填）')),
        Wrap(spacing: 8, children: [
          ElevatedButton(
              onPressed: supported && !_loading ? _load : null,
              child: const Text('加载单商品')),
          ElevatedButton(
              onPressed: _ad == null ? null : _destroy,
              child: const Text('销毁商品')),
        ]),
        Text(_status),
        if (_ad != null && _id != null)
          UnifiedWidget(_ad,
              adId: _id!,
              key: ValueKey('$_id/$_epoch'),
              unifiedContent: NativeUnifiedWidget(
                  width: width,
                  height: 300,
                  backgroundColor: '#FFFFFF',
                  children: [
                    UnifiedTitleWidget(
                        fontSize: 16,
                        color: '#1D2129',
                        x: 8,
                        y: 4,
                        width: width - 16,
                        maxLines: 1),
                    if (_pattern == AMPSUnifiedPattern.adPatternVideo)
                      UnifiedVideoWidget(width: width, height: 200, x: 0, y: 30)
                    else if (_pattern == AMPSUnifiedPattern.adPattern3Images &&
                        _images.isNotEmpty)
                      UnifiedImagesWidget(children: [
                        for (var i = 0; i < _images.length && i < 3; i++)
                          UnifiedImageItemWidget(
                              url: _images[i],
                              width: width / 3 - 4,
                              height: 200,
                              x: i * width / 3,
                              y: 30)
                      ])
                    else
                      UnifiedMainImgWidget(
                          backgroundColor: '#FFFFFF',
                          width: width,
                          height: 200,
                          x: 0,
                          y: 30,
                          clickType: AMPSAdItemClickType.click),
                    UnifiedDescWidget(
                        fontSize: 13,
                        color: '#4E5969',
                        x: 8,
                        y: 235,
                        width: width - 16,
                        maxLines: 1),
                    UnifiedActionButtonWidget(
                        fontSize: 14,
                        fontColor: '#FFFFFF',
                        backgroundColor: '#3377FF',
                        x: width - 105,
                        y: 263,
                        width: 100,
                        height: 30,
                        clickType: AMPSAdItemClickType.click),
                    UnifiedAdSourceLogoWidget(
                        width: 45, height: 20, x: 8, y: 270),
                  ])),
        const Text('商品扩展字段（按实际渠道返回，允许为空）'),
        SelectableText(const JsonEncoder.withIndent('  ').convert(_extras)),
      ]),
    );
  }
}
