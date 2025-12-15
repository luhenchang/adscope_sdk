/// 对应 Java 端 AMPSSDKInitStatus 枚举
enum AMPSSDKInitStatus {
  ampsAdSDKInitStatusNormal(0, "sdk Init status normal"),
  ampsAdSDKInitStatusLoading(1, "sdk Init status loading"),
  ampsAdSDKInitStatusSuccess(2, "sdk Init status success"),
  ampsAdSDKInitStatusFail(3, "sdk Init status fail"),
  ampsAdSDKInitStatusFailRepeat(4, "sdk Init status fail repeat");
  final int code;
  final String msg;
  const AMPSSDKInitStatus(this.code, this.msg);
  static AMPSSDKInitStatus? fromCode(int code) {
    try {
      return AMPSSDKInitStatus.values.firstWhere(
        (status) => status.code == code,
      );
    } catch (_) {
      return null;
    }
  }
  int getCode() => code;
  String getMsg() => msg;
}
