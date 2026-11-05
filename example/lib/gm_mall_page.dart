import 'dart:async';
import 'dart:convert';

import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'data/common.dart';

class GMMallPage extends StatefulWidget {
  const GMMallPage({super.key, this.searchMode = false});
  final bool searchMode;
  @override
  State<GMMallPage> createState() => _GMMallPageState();
}

class _GMMallPageState extends State<GMMallPage> {
  late final _space = TextEditingController(
      text: widget.searchMode ? mallSearchSpaceId : mallChannelSpaceId);
  late final _query =
      TextEditingController(text: widget.searchMode ? '手机' : '');
  final _gold = TextEditingController();
  final _duration = TextEditingController();
  final _logs = <String>[];
  AMPSMallAd? _ad;
  String? _adId;
  bool _loading = false;
  bool _readingInfo = false;
  bool _visible = true;
  int _generation = 0;
  String _rewardEventStatus = '尚未请求';
  String _scrollBoundary = '尚未收到边界事件';

  void _log(String value) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, value);
      if (_logs.length > 60) _logs.removeLast();
    });
  }

  Future<void> _load() async {
    if (_space.text.trim().isEmpty) {
      _log('请填写商城自渲染广告位 ID');
      return;
    }
    FocusScope.of(context).unfocus();
    final generation = ++_generation;
    final previous = _ad;
    final reward =
        AMPSGMMallRewardConfig(gold: _gold.text, duration: _duration.text);
    _ad = null;
    setState(() {
      _adId = null;
      _loading = true;
      _visible = true;
      _scrollBoundary = '尚未收到边界事件';
      _rewardEventStatus = reward.toUserData() == null
          ? '本次未配置浏览奖励任务'
          : '等待奖励事件（code=${AMPSMallEventCode.feedReward}）';
    });
    try {
      await previous?.destroy();
      if (!mounted || generation != _generation) return;
      final query = _query.text.trim();
      final ad = AMPSMallAd(
        config: AdOptions(
            spaceId: _space.text.trim(),
            mallReward: reward,
            customExtraMap: query.isEmpty
                ? null
                : {
                    'GM': {'userData': query}
                  }),
        onLoad: AMPSNativeAdListener(
          loadOk: (ids) {
            if (!mounted || generation != _generation) return;
            setState(() {
              _loading = false;
              _adId = ids.isEmpty ? null : ids.first;
            });
            _log(ids.isEmpty ? '未返回商城视图' : '广告已加载，准备挂载商城视图');
          },
          loadFail: (code, message) {
            if (!mounted || generation != _generation) return;
            setState(() {
              _loading = false;
              _adId = null;
            });
            _log('加载失败 [$code] $message');
          },
        ),
        onEvent: (adId, code, info) {
          if (!mounted || generation != _generation) return;
          _log('商城事件 $code：${jsonEncode(info)}');
          // Android AD_EVENT_FEED_REWARD / iOS SendFeedReward 当前均为 2。
          // 表示 SDK 通知浏览任务完成，不代表业务账户已入账。
          if (code == AMPSMallEventCode.feedReward) {
            setState(() => _rewardEventStatus =
                '已收到奖励事件（code=${AMPSMallEventCode.feedReward}）');
            _log('浏览奖励事件验证成功，adId=$adId；请由业务处理发奖');
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('已收到商城浏览奖励事件')));
          } else if (code == AMPSMallEventCode.reachBound) {
            final rawBound = info?['bound'];
            final bound = rawBound is num
                ? rawBound.toInt()
                : int.tryParse(rawBound?.toString() ?? '');
            final message = switch (bound) {
              AMPSMallScrollBound.top => '到达顶部',
              AMPSMallScrollBound.bottom => '到达底部',
              _ => '未知边界：$rawBound',
            };
            setState(() => _scrollBoundary = message);
            _log('商城滚动边界：$message');
          }
        },
      );
      _ad = ad;
      _log('加载商城，广告位=${_space.text.trim()}，关键词=$query');
      await ad.load();
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() => _loading = false);
      _log('加载失败：$error');
    }
  }

  Future<void> _info() async {
    final ad = _ad;
    final id = _adId;
    final generation = _generation;
    if (ad == null || id == null || _readingInfo) return;
    setState(() => _readingInfo = true);
    try {
      final info =
          await ad.getMallInfo(id).timeout(const Duration(seconds: 10));
      if (!mounted || generation != _generation) return;
      _log('商城信息：${jsonEncode(info)}');
      final extras = info['extras'];
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('商城信息 / 商品扩展字段'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (extras == null || (extras is Map && extras.isEmpty))
                  const Text('SDK 未返回商品扩展字段。商城内的商品列表由 SDK 页面展示。'),
                const Text('以下为 SDK 返回的商城状态和扩展字段：'),
                const SizedBox(height: 8),
                SelectableText(
                    const JsonEncoder.withIndent('  ').convert(info)),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'))
          ],
        ),
      );
    } catch (error) {
      if (!mounted || generation != _generation) return;
      _log('查询失败：$error');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('读取商城信息失败：$error')));
    } finally {
      if (mounted) setState(() => _readingInfo = false);
    }
  }

  Future<void> _destroy() async {
    ++_generation;
    final ad = _ad;
    _ad = null;
    setState(() {
      _adId = null;
      _loading = false;
      _rewardEventStatus = '实例已销毁';
    });
    try {
      await ad?.destroy();
      _log('商城已销毁');
    } catch (error) {
      _log('销毁失败：$error');
    }
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
    _gold.dispose();
    _duration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supported = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    return Scaffold(
      appBar: AppBar(title: Text(widget.searchMode ? '高商词多商品测试' : '商城频道测试')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('App ID：$appId（沿用首页初始化）'),
        const Text('使用商城自渲染广告位；关键词可空。非商城渠道会明确报错，不显示普通信息流兜底。'),
        if (!supported) const Text('嵌入式商城支持 Android 和 iOS。'),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _space.text = mallChannelSpaceId;
                        _query.clear();
                      }),
              child: const Text('填入商城频道')),
          OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => setState(() {
                        _space.text = mallSearchSpaceId;
                        _query.text = '手机';
                      }),
              child: const Text('填入高商词多广告')),
        ]),
        TextField(
            key: const Key('embedded-space-id'),
            controller: _space,
            decoration: const InputDecoration(labelText: '商城自渲染广告位 ID')),
        TextField(
            key: const Key('mall-query'),
            controller: _query,
            decoration: const InputDecoration(labelText: '搜索关键词 / 高商词（可选）')),
        ExpansionTile(title: const Text('频道奖励任务（可选）'), children: [
          TextField(
              key: const Key('channel-gold'),
              controller: _gold,
              decoration: const InputDecoration(labelText: '任务金币数')),
          TextField(
              key: const Key('channel-duration'),
              controller: _duration,
              decoration: const InputDecoration(labelText: '浏览时长（秒）')),
          const Text('频道奖励需开通相应能力；留空只请求频道或搜索结果页。'),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ElevatedButton(
              onPressed: !supported || _loading ? null : _load,
              child: const Text('加载商城')),
          ElevatedButton(
              onPressed: _adId == null
                  ? null
                  : () => setState(() => _visible = !_visible),
              child: Text(_visible ? '隐藏商城' : '显示商城')),
          ElevatedButton(
              onPressed: _adId == null || _readingInfo ? null : _info,
              child: Text(_readingInfo ? '读取中…' : '读取商城信息')),
          ElevatedButton(
              onPressed: _ad == null ? null : _destroy,
              child: const Text('销毁商城')),
        ]),
        const SizedBox(height: 12),
        Text('浏览奖励验证：$_rewardEventStatus'),
        Text('商城滚动边界：$_scrollBoundary'),
        const Text('传入金币和浏览时长后，完成任务应收到浏览奖励事件；该状态仅验证事件收到，不执行金币入账。'),
        SizedBox(
            height: MediaQuery.sizeOf(context).height * .55,
            child: _adId == null || _ad == null
                ? Center(child: Text(_loading ? '商城加载中' : '等待加载商城'))
                : AMPSMallView(ad: _ad!, adId: _adId!, visible: _visible)),
        const Divider(),
        const Text('商城事件 / 扩展字段（最新在前）'),
        SelectableText(_logs.join('\n')),
      ]),
    );
  }
}
