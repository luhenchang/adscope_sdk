/// 日志级别枚举（对应Java端LOG_LEVEL）
enum LogLevel {
  /// 错误级别
  logLevelError(2),
  /// 警告级别
  logLevelWarn(4),
  /// 调试级别
  logLevelDebug(8),
  /// 堆栈级别
  logLevelStack(16),
  /// 渲染级别
  logLevelRender(32),
  /// 所有级别
  logLevelAll(268435455);

  /// 枚举对应的值
  final int value;

  /// 构造函数
  const LogLevel(this.value);

  /// 获取枚举对应的值（对应Java的getValue()方法）
  int getValue() {
    return value;
  }

  /// 扩展方法：通过数值反向获取枚举（可选，增强实用性）
  static LogLevel? fromValue(int value) {
    return LogLevel.values.firstWhere(
          (level) => level.value == value
    );
  }
}