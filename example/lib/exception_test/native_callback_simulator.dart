import 'dart:async';

import 'package:adscope_sdk/common.dart';
import 'package:flutter/services.dart';

/// 模拟原生端向 Flutter 发送 MethodChannel 回调。
///
/// 通过 [ChannelBuffers.push] 把编码后的 MethodCall 直接投递到
/// `adscope_sdk` 通道的入站队列，效果与原生 `channel.invokeMethod` 一致，
/// 用于注入 code=null / code="abc" / arguments 非 Map 等畸形参数，
/// 验证 Dart 侧回调路由的空安全转换不会把回调吞掉。
class NativeCallbackSimulator {
  NativeCallbackSimulator._();

  static const StandardMethodCodec _codec = StandardMethodCodec();

  static Future<void> push(String method, dynamic arguments) async {
    final ByteData data = _codec.encodeMethodCall(MethodCall(method, arguments));
    final completer = Completer<void>();
    ServicesBinding.instance.channelBuffers.push(
      AMPSChannels.ampsSdk,
      data,
      (ByteData? reply) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    // 正常情况下 handler 处理完会应答；兜底 2 秒防止无 handler 时卡住用例
    await completer.future.timeout(const Duration(seconds: 2), onTimeout: () {});
  }
}
