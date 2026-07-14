import 'dart:async';

import 'package:flutter/material.dart';

/// ---------------- 公共常量 ----------------

/// 不存在的实例 id，用于验证原生"实例不存在"错误路径
const String kExcFakeInstanceId = 'exc_test_no_such_instance';

/// 无效广告位 id，用于触发真实加载失败
const String kExcInvalidSpaceId = '999999999';

/// 通道直连调用的响应超时（超时 = 原生未回调 result，Future 挂起）
const Duration kExcChannelTimeout = Duration(seconds: 5);

/// 等待加载失败回调的超时
const Duration kExcLoadCallbackTimeout = Duration(seconds: 10);

/// 软预期回调（原生可能静默处理）的超时
const Duration kExcSoftCallbackTimeout = Duration(seconds: 6);

/// 注入模拟回调后的等待超时
const Duration kExcInjectTimeout = Duration(seconds: 3);

/// ---------------- 用例模型 ----------------

/// 单条用例的执行状态
enum ExceptionTestStatus { pending, running, passed, warning, failed }

/// 用例执行结果
class ExceptionTestOutcome {
  final ExceptionTestStatus status;
  final String detail;

  const ExceptionTestOutcome._(this.status, this.detail);

  factory ExceptionTestOutcome.passed(String detail) =>
      ExceptionTestOutcome._(ExceptionTestStatus.passed, detail);

  factory ExceptionTestOutcome.warning(String detail) =>
      ExceptionTestOutcome._(ExceptionTestStatus.warning, detail);

  factory ExceptionTestOutcome.failed(String detail) =>
      ExceptionTestOutcome._(ExceptionTestStatus.failed, detail);
}

/// 用例内部日志输出函数
typedef ExceptionTestLog = void Function(String message);

/// 用例执行体
typedef ExceptionTestRunner = Future<ExceptionTestOutcome> Function(ExceptionTestLog log);

/// 一条异常测试用例
class ExceptionTestCase {
  final String id;

  /// 用例名称
  final String name;

  /// 异常发生位置（哪一层、哪个调用）
  final String position;

  /// 预期表现
  final String expectation;

  final ExceptionTestRunner run;

  ExceptionTestStatus status = ExceptionTestStatus.pending;
  String? resultDetail;

  ExceptionTestCase({
    required this.id,
    required this.name,
    required this.position,
    required this.expectation,
    required this.run,
  });
}

/// 用例分组（对应一层防护）
class ExceptionTestGroup {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ExceptionTestCase> cases;

  const ExceptionTestGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cases,
  });
}

/// ---------------- 日志模型 ----------------

enum ExceptionLogLevel { info, success, warn, error }

class ExceptionLogEntry {
  final DateTime time;
  final ExceptionLogLevel level;
  final String text;

  ExceptionLogEntry(this.time, this.level, this.text);
}

/// ---------------- 工具 ----------------

/// 等待回调到达的辅助器：预期回调在超时内到达则返回值，否则返回 null
class CallbackWaiter<T> {
  final Completer<T> _completer = Completer<T>();

  bool get isCompleted => _completer.isCompleted;

  void complete(T value) {
    if (!_completer.isCompleted) {
      _completer.complete(value);
    }
  }

  Future<T?> wait(Duration timeout) async {
    try {
      return await _completer.future.timeout(timeout);
    } on TimeoutException {
      return null;
    }
  }
}
