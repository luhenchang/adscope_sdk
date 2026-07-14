import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'exception_inventory.dart';
import 'exception_test_cases.dart';
import 'exception_test_models.dart';

/// 异常防护测试中心：预置全量异常用例，一键运行并实时查看 Flutter 端收到的错误日志。
class ExceptionTestPage extends StatefulWidget {
  const ExceptionTestPage({super.key});

  @override
  State<ExceptionTestPage> createState() => _ExceptionTestPageState();
}

class _ExceptionTestPageState extends State<ExceptionTestPage> {
  late final List<ExceptionTestGroup> _groups;
  final List<ExceptionLogEntry> _logs = [];
  final ScrollController _logScroll = ScrollController();
  final Set<String> _expandedGroups = {};

  bool _runningAll = false;
  bool _stopRequested = false;
  bool _logExpanded = false;

  @override
  void initState() {
    super.initState();
    _groups = ExceptionTestRegistry.build();
    if (_groups.isNotEmpty) {
      _expandedGroups.add(_groups.first.title);
    }
  }

  @override
  void dispose() {
    _stopRequested = true;
    _logScroll.dispose();
    super.dispose();
  }

  // ---------------- 运行逻辑 ----------------

  List<ExceptionTestCase> get _allCases =>
      _groups.expand((g) => g.cases).toList();

  int _countBy(ExceptionTestStatus status) =>
      _allCases.where((c) => c.status == status).length;

  void _log(ExceptionLogLevel level, String text) {
    if (!mounted) return;
    setState(() {
      _logs.add(ExceptionLogEntry(DateTime.now(), level, text));
      if (_logs.length > 500) _logs.removeRange(0, _logs.length - 500);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScroll.hasClients) {
        _logScroll.jumpTo(_logScroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _runCase(ExceptionTestCase c) async {
    if (c.status == ExceptionTestStatus.running) return;
    setState(() {
      c.status = ExceptionTestStatus.running;
      c.resultDetail = null;
    });
    _log(ExceptionLogLevel.info, '▶ [${c.id}] ${c.name}');
    ExceptionTestOutcome outcome;
    try {
      outcome = await c.run((m) => _log(ExceptionLogLevel.info, '  · [${c.id}] $m'));
    } catch (e) {
      outcome = ExceptionTestOutcome.failed('用例执行抛出未捕获异常: $e');
    }
    if (!mounted) return;
    setState(() {
      c.status = outcome.status;
      c.resultDetail = outcome.detail;
    });
    switch (outcome.status) {
      case ExceptionTestStatus.passed:
        _log(ExceptionLogLevel.success, '✔ [${c.id}] 通过：${outcome.detail}');
        break;
      case ExceptionTestStatus.warning:
        _log(ExceptionLogLevel.warn, '⚠ [${c.id}] 警告：${outcome.detail}');
        break;
      default:
        _log(ExceptionLogLevel.error, '✘ [${c.id}] 失败：${outcome.detail}');
        break;
    }
  }

  Future<void> _runCases(List<ExceptionTestCase> cases, String label) async {
    if (_runningAll) return;
    setState(() {
      _runningAll = true;
      _stopRequested = false;
    });
    _log(ExceptionLogLevel.info, '════ 开始运行：$label（${cases.length} 条）════');
    for (final c in cases) {
      if (_stopRequested || !mounted) break;
      await _runCase(c);
    }
    if (mounted) {
      _log(ExceptionLogLevel.info,
          '════ 运行结束：通过 ${_countBy(ExceptionTestStatus.passed)} · '
          '警告 ${_countBy(ExceptionTestStatus.warning)} · '
          '失败 ${_countBy(ExceptionTestStatus.failed)} ════');
      setState(() => _runningAll = false);
    }
  }

  void _resetAll() {
    setState(() {
      for (final c in _allCases) {
        c.status = ExceptionTestStatus.pending;
        c.resultDetail = null;
      }
      _logs.clear();
    });
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              itemCount: _groups.length,
              itemBuilder: (context, index) => _buildGroupCard(_groups[index]),
            ),
          ),
          _buildLogConsole(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final passed = _countBy(ExceptionTestStatus.passed);
    final warning = _countBy(ExceptionTestStatus.warning);
    final failed = _countBy(ExceptionTestStatus.failed);
    final total = _allCases.length;
    final done = passed + warning + failed;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A1C71), Color(0xFF7A3CB8), Color(0xFF2575FC)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('异常防护测试中心',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('全链路异常注入 · 验证 Flutter 端错误日志必达',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '查看异常清单',
                    icon: const Icon(Icons.menu_book_rounded,
                        color: Colors.white),
                    onPressed: _showInventorySheet,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    _statChip('总用例', '$total', Colors.white),
                    _statChip('通过', '$passed', const Color(0xFF7CFFB2)),
                    _statChip('警告', '$warning', const Color(0xFFFFD97C)),
                    _statChip('失败', '$failed', const Color(0xFFFF8A8A)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF3A1C71),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(21)),
                            elevation: 0,
                          ),
                          onPressed: _runningAll
                              ? () => setState(() => _stopRequested = true)
                              : () => _runCases(_allCases, '全部用例'),
                          icon: _runningAll
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF3A1C71)))
                              : const Icon(Icons.play_arrow_rounded),
                          label: Text(_runningAll
                              ? '运行中 $done/$total（点击停止）'
                              : '一键运行全部用例'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 42,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(21)),
                        ),
                        onPressed: _runningAll ? null : _resetAll,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('重置'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_runningAll) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 5,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF7CFFB2)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 5),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------- 分组卡片 ----------------

  Widget _buildGroupCard(ExceptionTestGroup group) {
    final expanded = _expandedGroups.contains(group.title);
    final done = group.cases
        .where((c) =>
            c.status != ExceptionTestStatus.pending &&
            c.status != ExceptionTestStatus.running)
        .length;
    final hasFailed =
        group.cases.any((c) => c.status == ExceptionTestStatus.failed);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() {
              expanded
                  ? _expandedGroups.remove(group.title)
                  : _expandedGroups.add(group.title);
            }),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: hasFailed
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFEDE7F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(group.icon,
                        color: hasFailed
                            ? const Color(0xFFE53935)
                            : const Color(0xFF5E35B1),
                        size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.title,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 3),
                        Text(group.subtitle,
                            style: const TextStyle(
                                fontSize: 11.5, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$done/${group.cases.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _runningAll
                      ? null
                      : () => _runCases(group.cases, group.title),
                  icon: const Icon(Icons.playlist_play_rounded, size: 20),
                  label: const Text('运行本组', style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            ...group.cases.map(_buildCaseTile),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildCaseTile(ExceptionTestCase c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _statusIcon(c.status),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[${c.id}] ${c.name}',
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(c.position,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black45)),
                Text('预期：${c.expectation}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF5C6BC0))),
                if (c.resultDetail != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(c.status).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(c.resultDetail!,
                          style: TextStyle(
                              fontSize: 11, color: _statusColor(c.status))),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: '运行该用例',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.play_circle_outline_rounded,
                color: _runningAll ? Colors.black26 : const Color(0xFF5E35B1)),
            onPressed:
                _runningAll ? null : () => _runCases([c], '[${c.id}] ${c.name}'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(ExceptionTestStatus status) {
    switch (status) {
      case ExceptionTestStatus.passed:
        return const Color(0xFF2E7D32);
      case ExceptionTestStatus.warning:
        return const Color(0xFFEF6C00);
      case ExceptionTestStatus.failed:
        return const Color(0xFFC62828);
      case ExceptionTestStatus.running:
        return const Color(0xFF1565C0);
      case ExceptionTestStatus.pending:
        return Colors.black38;
    }
  }

  Widget _statusIcon(ExceptionTestStatus status) {
    switch (status) {
      case ExceptionTestStatus.running:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        );
      case ExceptionTestStatus.passed:
        return const Icon(Icons.check_circle_rounded,
            color: Color(0xFF43A047), size: 20);
      case ExceptionTestStatus.warning:
        return const Icon(Icons.error_rounded,
            color: Color(0xFFFB8C00), size: 20);
      case ExceptionTestStatus.failed:
        return const Icon(Icons.cancel_rounded,
            color: Color(0xFFE53935), size: 20);
      case ExceptionTestStatus.pending:
        return const Icon(Icons.radio_button_unchecked_rounded,
            color: Colors.black26, size: 20);
    }
  }

  // ---------------- 日志控制台 ----------------

  Widget _buildLogConsole() {
    return Container(
      height: _logExpanded ? 320 : 170,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 6, 0),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded,
                    color: Color(0xFF7CFFB2), size: 17),
                const SizedBox(width: 6),
                Text('实时日志（${_logs.length}）',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(
                  tooltip: '复制日志',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded,
                      color: Colors.white38, size: 16),
                  onPressed: () {
                    final text = _logs
                        .map((e) =>
                            '${_fmtTime(e.time)} ${e.text}')
                        .join('\n');
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('日志已复制到剪贴板')));
                  },
                ),
                IconButton(
                  tooltip: '清空日志',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.white38, size: 18),
                  onPressed: () => setState(() => _logs.clear()),
                ),
                IconButton(
                  tooltip: _logExpanded ? '收起' : '展开',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                      _logExpanded
                          ? Icons.close_fullscreen_rounded
                          : Icons.open_in_full_rounded,
                      color: Colors.white38,
                      size: 16),
                  onPressed: () =>
                      setState(() => _logExpanded = !_logExpanded),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text('暂无日志，点击「一键运行全部用例」开始',
                        style:
                            TextStyle(color: Colors.white24, fontSize: 12)))
                : ListView.builder(
                    controller: _logScroll,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final e = _logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: '${_fmtTime(e.time)}  ',
                                  style: const TextStyle(
                                      color: Colors.white30)),
                              TextSpan(
                                  text: e.text,
                                  style:
                                      TextStyle(color: _logColor(e.level))),
                            ],
                          ),
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontFamily: 'monospace',
                              height: 1.35),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _logColor(ExceptionLogLevel level) {
    switch (level) {
      case ExceptionLogLevel.success:
        return const Color(0xFF7CFFB2);
      case ExceptionLogLevel.warn:
        return const Color(0xFFFFD97C);
      case ExceptionLogLevel.error:
        return const Color(0xFFFF8A8A);
      case ExceptionLogLevel.info:
        return const Color(0xFF9CDCFE);
    }
  }

  String _fmtTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    final ms = (t.millisecond ~/ 10).toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.$ms';
  }

  // ---------------- 异常清单弹层 ----------------

  void _showInventorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: Color(0xFF5E35B1)),
                    SizedBox(width: 8),
                    Text('全量异常清单',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: kExceptionInventory.length,
                  itemBuilder: (context, index) =>
                      _buildInventoryLayer(kExceptionInventory[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryLayer(ExceptionInventoryLayer layer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E0F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(layer.title,
              style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A1C71))),
          const SizedBox(height: 4),
          Text(layer.description,
              style: const TextStyle(fontSize: 11.5, color: Colors.black54)),
          const SizedBox(height: 10),
          ...layer.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(Icons.circle,
                            size: 6, color: Color(0xFF7A3CB8)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.name,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, top: 2),
                    child: Text('触发：${item.source}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, top: 1),
                    child: Text('兜底：${item.behavior}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF2E7D32))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
