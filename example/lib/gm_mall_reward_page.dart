import 'dart:async';

import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/material.dart';

import 'data/common.dart';

/// 单按钮加载并展示商城激励，保留任务参数与回调日志。
class GMMallRewardPage extends StatefulWidget {
  const GMMallRewardPage({super.key});

  @override
  State<GMMallRewardPage> createState() => _GMMallRewardPageState();
}

class _GMMallRewardPageState extends State<GMMallRewardPage> {
  final _form = GlobalKey<FormState>();
  final _spaceId = TextEditingController(text: mallRewardSpaceId);
  final _gold = TextEditingController(text: '10');
  final _duration = TextEditingController(text: '2');
  final _logs = <String>[];
  AMPSRewardVideoAd? _ad;
  int _generation = 0;
  bool _requesting = false;
  bool _showStarted = false;
  bool _presenting = false;
  String _status = '等待请求';
  String _snapshot = '尚未发送请求';

  bool _isCurrent(int generation) => mounted && generation == _generation;

  void _log(String message) {
    if (!mounted) return;
    final time = DateTime.now().toIso8601String().substring(11, 23);
    setState(() {
      _logs.insert(0, '$time  $message');
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  void _event(int generation, String message,
      {bool? loaded, bool? presenting}) {
    if (!_isCurrent(generation)) return;
    setState(() {
      _status = message;
      if (loaded != null) {
        _requesting = false;
      }
      if (presenting != null) _presenting = presenting;
    });
    _log(message);
  }

  void _failure(int generation, int code, String message) {
    _event(generation, '失败 [$code] $message', loaded: false, presenting: false);
  }

  Future<void> _request() async {
    if (!_form.currentState!.validate() || _presenting || _requesting) return;
    FocusScope.of(context).unfocus();
    final generation = ++_generation;
    final previous = _ad;
    _ad = null;
    final reward = AMPSGMMallRewardConfig(
      gold: _gold.text,
      duration: _duration.text,
    );
    final options =
        AdOptions(spaceId: _spaceId.text.trim(), mallReward: reward);
    setState(() {
      _requesting = true;
      _showStarted = false;
      _status = '请求中';
      _snapshot = '广告位：${options.spaceId}\n'
          '${reward.toUserData() ?? '无商城字段，按普通激励请求'}';
    });
    _log(_status);
    try {
      await previous?.destroy();
      if (!_isCurrent(generation)) return;
      final ad = AMPSRewardVideoAd(
        config: options,
        adCallBack: RewardVideoCallBack(
          onLoadSuccess: () {
            if (!_isCurrent(generation) || _showStarted) return;
            _showStarted = true;
            _event(generation, '加载成功');
            unawaited(_readWinner(generation));
            unawaited(_show(generation));
          },
          onAdCached: () => _event(generation, '缓存完成'),
          onLoadFailure: (code, message) => _failure(generation, code, message),
          onAdShow: () => _event(generation, '广告已展示', presenting: true),
          onAdClicked: () => _event(generation, '广告点击'),
          onAdClosed: () =>
              _event(generation, '广告关闭', loaded: false, presenting: false),
          onAdReward: () => _event(generation, '收到激励奖励回调'),
          onVideoPlayStart: () => _event(generation, '视频开始'),
          onVideoPlayEnd: () => _event(generation, '视频播放结束'),
          onVideoSkipToEnd: (ms) => _event(generation, '视频跳过：${ms ?? '-'} ms'),
          onVideoPlayError: (code, message) =>
              _failure(generation, code, message),
          onServerRewardFailed: (code, message) =>
              _event(generation, '服务端奖励失败 [$code] $message'),
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (error) {
      _failure(generation, -1, error.toString());
    }
  }

  Future<void> _readWinner(int generation) async {
    final ad = _ad;
    if (ad == null) return;
    try {
      final seat = await ad.getSeatId();
      final ecpm = await ad.getECPM();
      if (_isCurrent(generation)) _log('胜出渠道 seatId=$seat，eCPM=$ecpm');
    } catch (error) {
      if (_isCurrent(generation)) _log('读取渠道信息失败：$error');
    }
  }

  Future<void> _show(int generation) async {
    final ad = _ad;
    if (ad == null || !_isCurrent(generation) || _presenting) return;
    setState(() {
      _presenting = true;
      _requesting = false;
    });
    try {
      final ready = await ad.isReadyAd();
      if (!_isCurrent(generation)) return;
      if (!ready) {
        _failure(generation, -1, '广告未就绪，请重试');
        return;
      }
      await ad.showAd();
    } catch (error) {
      _failure(generation, -1, error.toString());
    }
  }

  @override
  void dispose() {
    ++_generation;
    final ad = _ad;
    if (ad != null) {
      unawaited(ad.destroy().catchError((Object error) {
        debugPrint('商城测试页释放失败：$error');
      }));
    }
    _spaceId.dispose();
    _gold.dispose();
    _duration.dispose();
    super.dispose();
  }

  String? _optionalNumber(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return RegExp(r'^\d+$').hasMatch(text) ? null : '请输入非负整数，或留空';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_presenting,
      child: Scaffold(
        appBar: AppBar(title: const Text('穿山甲商城激励测试')),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('App ID：$appId（沿用首页初始化）'),
              const SizedBox(height: 8),
              const Text('请先在首页完成 SDK 初始化，并填写已开通商城任务的激励广告位。'
                  '参数修改只对下一次请求生效；点击按钮后自动加载并展示。'),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('mall-space-id'),
                controller: _spaceId,
                decoration: const InputDecoration(
                    labelText: '商城激励广告位 ID', border: OutlineInputBorder()),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? '请输入广告位 ID' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('mall-gold'),
                controller: _gold,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '奖励金币数（可选）', border: OutlineInputBorder()),
                validator: _optionalNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('mall-duration'),
                controller: _duration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '浏览时长 / 秒（可选）', border: OutlineInputBorder()),
                validator: _optionalNumber,
              ),
              const SizedBox(height: 16),
              Text('状态：$_status',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ElevatedButton(
                  onPressed: _requesting || _presenting ? null : _request,
                  child: const Text('加载并展示商城激励')),
              const SizedBox(height: 20),
              const Text('本次请求', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_snapshot),
              const SizedBox(height: 20),
              const Text('回调日志（最新在前）',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_logs.isEmpty ? '暂无回调' : _logs.join('\n')),
            ],
          ),
        ),
      ),
    );
  }
}
