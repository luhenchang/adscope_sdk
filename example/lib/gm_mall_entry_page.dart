import 'dart:async';

import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/material.dart';

import 'data/common.dart';

/// 金刚位由业务绘制，复用普通插屏/激励视频打开商城。
class GMMallEntryPage extends StatefulWidget {
  const GMMallEntryPage({super.key});
  @override
  State<GMMallEntryPage> createState() => _GMMallEntryPageState();
}

class _GMMallEntryPageState extends State<GMMallEntryPage> {
  final _space = TextEditingController(text: mallEntrySpaceId);
  final _logs = <String>[];
  bool _reward = false,
      _busy = false,
      _presenting = false,
      _showStarted = false;
  int _generation = 0;
  AMPSInterstitialAd? _interstitial;
  AMPSRewardVideoAd? _rewardAd;
  bool _current(int generation) => mounted && generation == _generation;
  void _log(String value) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, value);
      if (_logs.length > 50) _logs.removeLast();
    });
  }

  void _finish(int generation, String value) {
    if (!_current(generation)) return;
    setState(() {
      _busy = false;
      _presenting = false;
    });
    _log(value);
  }

  Future<void> _release() async {
    final interstitial = _interstitial;
    final reward = _rewardAd;
    _interstitial = null;
    _rewardAd = null;
    await interstitial?.destroy();
    await reward?.destroy();
  }

  Future<void> _show(int generation) async {
    if (!_current(generation) || _showStarted || !_busy) return;
    _showStarted = true;
    try {
      if (_reward) {
        await _rewardAd?.showAd();
      } else {
        await _interstitial?.showAd();
      }
    } catch (error) {
      _finish(generation, '展示失败：$error');
    }
  }

  Future<void> _open(String entry) async {
    if (_busy) return;
    if (_space.text.trim().isEmpty) {
      _log('请填写对应类型的商城广告位');
      return;
    }
    FocusScope.of(context).unfocus();
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _showStarted = false;
    });
    _log('点击入口「$entry」，${_reward ? '激励视频' : '插屏'}加载中');
    try {
      await _release();
      if (!_current(generation)) return;
      final config = AdOptions(spaceId: _space.text.trim());
      if (_reward) {
        _rewardAd = AMPSRewardVideoAd(
            config: config,
            adCallBack: RewardVideoCallBack(
              onLoadSuccess: () => unawaited(_show(generation)),
              onLoadFailure: (code, message) =>
                  _finish(generation, '失败 [$code] $message'),
              onAdShow: () {
                if (_current(generation)) {
                  setState(() => _presenting = true);
                  _log('商城已打开');
                }
              },
              onAdClosed: () => _finish(generation, '商城已关闭'),
              onAdReward: () {
                if (_current(generation)) _log('收到普通激励回调');
              },
            ));
        await _rewardAd!.load();
      } else {
        _interstitial = AMPSInterstitialAd(
            config: config,
            mCallBack: AdCallBack(
              onRenderOk: () => unawaited(_show(generation)),
              onLoadFailure: (code, message) =>
                  _finish(generation, '失败 [$code] $message'),
              onRenderFailure: () => _finish(generation, '渲染失败'),
              onAdShowError: (code, message) =>
                  _finish(generation, '展示失败 [$code] $message'),
              onAdShow: () {
                if (_current(generation)) {
                  setState(() => _presenting = true);
                  _log('商城已打开');
                }
              },
              onAdClosed: () => _finish(generation, '商城已关闭'),
            ));
        await _interstitial!.load();
      }
    } catch (error) {
      _finish(generation, '打开失败：$error');
    }
  }

  @override
  void dispose() {
    ++_generation;
    unawaited(_release().catchError((Object e) {
      debugPrint('$e');
    }));
    _space.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const entries = [
      ('逛商城', Icons.storefront),
      ('精选好物', Icons.shopping_bag_outlined),
      ('热门商品', Icons.local_fire_department_outlined),
      ('购物福利', Icons.card_giftcard),
      ('每日推荐', Icons.recommend_outlined)
    ];
    return PopScope(
        canPop: !_presenting,
        child: Scaffold(
          appBar: AppBar(title: const Text('商城金刚位入口测试')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Text('App ID：$appId（沿用首页初始化）'),
            const Text('金刚位入口由业务开发。以下入口共用当前测试广告位，点击后自动加载并打开；不附加商城激励任务参数。'),
            Wrap(spacing: 12, children: [
              ChoiceChip(
                  label: const Text('插屏'),
                  selected: !_reward,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() {
                            _reward = false;
                            _space.text = mallEntrySpaceId;
                          })),
              ChoiceChip(
                  label: const Text('激励视频'),
                  selected: _reward,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() {
                            _reward = true;
                            _space.text = mallRewardSpaceId;
                          })),
            ]),
            TextField(
                controller: _space,
                decoration: const InputDecoration(labelText: '商城广告位 ID')),
            const SizedBox(height: 24),
            Wrap(
                spacing: 12,
                runSpacing: 12,
                children: entries
                    .map((entry) => SizedBox(
                        width: 100,
                        child: ElevatedButton(
                            onPressed: _busy ? null : () => _open(entry.$1),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Column(children: [
                                  Icon(entry.$2),
                                  const SizedBox(height: 8),
                                  Text(entry.$1)
                                ])))))
                    .toList()),
            if (_busy)
              const Padding(
                  padding: EdgeInsets.all(16), child: Text('商城加载或展示中…')),
            const Divider(),
            SelectableText(_logs.isEmpty ? '等待点击入口' : _logs.join('\n')),
          ]),
        ));
  }
}
