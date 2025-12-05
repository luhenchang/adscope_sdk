class UnifiedAdDownloadAppInfo {
  final String? appName;
  final String? appVersion;
  final String? appDeveloper;
  final String? appPermission;
  final String? appPrivacy;
  final String? appIntro;

  UnifiedAdDownloadAppInfo({
    this.appName,
    this.appVersion,
    this.appDeveloper,
    this.appPermission,
    this.appPrivacy,
    this.appIntro,
  });

  // 从Map解析创建实例
  static UnifiedAdDownloadAppInfo? fromMap(Map<String, dynamic>? map) {
    // 如果map为空，返回null
    if (map == null || map.isEmpty) {
      return null;
    }

    return UnifiedAdDownloadAppInfo(
      appName: map['appName'],
      appVersion: map['appVersion'],
      appDeveloper: map['appDeveloper'],
      appPermission: map['appPermission'],
      appPrivacy: map['appPrivacy'],
      appIntro: map['appIntro'],
    );
  }

  // 可选：转为Map，便于后续处理
  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appDeveloper': appDeveloper,
      'appPermission': appPermission,
      'appPrivacy': appPrivacy,
      'appIntro': appIntro,
    };
  }
}
