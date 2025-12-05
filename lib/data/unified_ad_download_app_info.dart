class UnifiedAdDownloadAppInfo {
  final String? appName;
  final String? appVersion;
  final String? appDeveloper;
  final String? appPermission;
  final String? appPrivacy;
  final String? appIntro;
  final String? downloadCountDesc;
  final String? appScore;
  final String? appPrice;
  final String? appSize;
  final String? appPackageName;
  final String? appIconUrl;

  UnifiedAdDownloadAppInfo({
    this.appName,
    this.appVersion,
    this.appDeveloper,
    this.appPermission,
    this.appPrivacy,
    this.appIntro,
    this.downloadCountDesc,
    this.appScore,
    this.appPrice,
    this.appSize,
    this.appPackageName,
    this.appIconUrl,
  });

  // 从Map解析创建实例（保持空安全判断）
  static UnifiedAdDownloadAppInfo? fromMap(Map<String, dynamic>? map) {
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
      downloadCountDesc: map['downloadCountDesc'],
      appScore: map['appScore'],
      appPrice: map['appPrice'],
      appSize: map['appSize'],
      appPackageName: map['appPackageName'],
      appIconUrl: map['appIconUrl'],
    );
  }

  // 转为Map（完整包含所有属性）
  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'appDeveloper': appDeveloper,
      'appPermission': appPermission,
      'appPrivacy': appPrivacy,
      'appIntro': appIntro,
      'downloadCountDesc': downloadCountDesc,
      'appScore': appScore,
      'appPrice': appPrice,
      'appSize': appSize,
      'appPackageName': appPackageName,
      'appIconUrl': appIconUrl,
    };
  }

  // 可选：重写toString，便于日志打印（按需使用）
  @override
  String toString() {
    return "UnifiedAdDownloadAppInfo("
        "appName: $appName, "
        "appVersion: $appVersion, "
        "appDeveloper: $appDeveloper, "
        "appPermission: $appPermission, "
        "appPrivacy: $appPrivacy, "
        "appIntro: $appIntro, "
        "downloadCountDesc: $downloadCountDesc, "
        "appScore: $appScore, "
        "appPrice: $appPrice, "
        "appSize: $appSize, "
        "appPackageName: $appPackageName, "
        "appIconUrl: $appIconUrl"
        ")";
  }
}