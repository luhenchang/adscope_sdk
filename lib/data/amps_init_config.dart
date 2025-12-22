import 'amps_sdk_api_keys.dart';

///UI模式【自动、黑色、浅色】
enum UiModel { uiModelAuto, uiModelDark, uiModelLight }

///坐标系类型
enum CoordinateType {
  wgs84('WGS84'),
  gcj02('GCJ02'),
  baidu('BAIDU');

  final String value;

  const CoordinateType(this.value);

  @override
  String toString() => value;
}

///适龄标记
enum UnderageTag {
  unknown(-1),
  maturity(0),
  underage(1);

  final int value;

  const UnderageTag(this.value);
}

///初始化设置, 国家类型选项
class CountryType {
  static const countryTypeChinaMainland = 1;
  static const countryTypeOther = 0;
}

///支持的货币类型
class CurrencyType {
  // 小驼峰式（lowerCamelCase）命名：currencyTypeCny
  static const currencyTypeCny = "CNY"; // 人民币
  static const currencyTypeUsd = "USD"; // 美元
  static const currencyTypeJpy = "JPY"; // 日元
  static const currencyTypeEur = "EUR"; // 欧元
  static const currencyTypeGbp = "GBP"; // 英镑
  static const currencyTypeIdr = "IDR"; // 印尼盾
  static const currencyTypeMyr = "MYR"; // 马来西亚林吉特
  static const currencyTypePhp = "PHP"; // 菲律宾比索
  static const currencyTypeKRW = "THB"; // 泰铢
}

/// 记录三方传入的位置信息，用于上报
class AMPSLocation {
  /// 经度
  double? longitude;

  /// 纬度
  double? latitude;

  /// 坐标系类型，对应原代码中的AMPSConstants.CoordinateType
  /// （默认 0：GCJ02   1:WGS84   2:BAIDU，仅支持QM渠道）
  CoordinateType? coordinate;

  /// 时间戳
  int? timeStamp = 0;

  /// 构造函数，支持初始化时设置属性
  AMPSLocation({
    this.longitude,
    this.latitude,
    this.coordinate,
    int? timeStamp,
  }) {
    this.timeStamp = timeStamp ?? 0; // 确保默认值为0
  }

  /// 转为 Map
  Map<String, dynamic> toJson() {
    return {
      AMPSLocationKey.latitude: latitude,
      AMPSLocationKey.longitude: longitude,
      AMPSLocationKey.timeStamp: timeStamp,
      AMPSLocationKey.coordinate: coordinate?.value
    };
  }
}

/// 假设的工具类
class StrUtil {
  static bool isEmpty(String? str) => str == null || str.isEmpty;

  static String replace(String str, String pattern, String replacement) {
    return str.replaceAll(RegExp(pattern), replacement);
  }
}

///对应Android端的PackageInfo
class PackageInfo {
  String? packageName;
  int? versionCode;
  String? versionName;
  int? firstInstallTime;
  int? lastUpdateTime;

  PackageInfo.required({
    required this.packageName,
    required this.versionName,
    this.versionCode,
    this.firstInstallTime,
    this.lastUpdateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "packageName": packageName,
      "versionCode": versionCode,
      "versionName": versionName,
      "firstInstallTime": firstInstallTime,
      "lastUpdateTime": lastUpdateTime
    };
  }
}

/// 用户控制类. 重写相关方法设置SDK可用内容
class AMPSCustomController {
  /// 是否可以使用PhoneState权限
  bool isCanUsePhoneState;

  /// 是否允许使用个性化推荐
  /// true: 允许 false: 不允许
  bool isSupportPersonalized;

  /// 适龄标记
  /// 取值参考 [UnderageTag]
  UnderageTag getUnderageTag;

  /// userAgent
  String? userAgent;

  /// 是否可以使用传感器
  bool isCanUseSensor;

  /// 是否允许SDK自身获取定位
  bool isLocationEnabled;

  /// 用于记录，三方设置的位置信息
  AMPSLocation? location;

  bool isCanUseWifiState;
  bool isCanUseOaid;
  String? devOaid;
  bool isCanUseAppList;
  List<PackageInfo>? getAppList;
  bool isCanUseAndroidId;
  String? androidId;
  bool isCanUseMacAddress;
  String? macAddress;
  bool isCanUseWriteExternal;
  bool isCanUseShakeAd;
  String? devImei;
  List<String>? devImeiList;
  bool isCanUseRecordAudio;
  bool isCanUseIP;
  String? ip;
  bool isCanUseSimOperator;
  String? devSimOperatorCode;
  String? devSimOperatorName;

  AMPSCustomController({
    required AMPSCustomControllerParam? param,
  })  : isCanUsePhoneState = param?.isCanUsePhoneState ?? false,
        isSupportPersonalized = param?.isSupportPersonalized ?? true,
        getUnderageTag = param?.getUnderageTag ?? UnderageTag.unknown,
        userAgent = param?.userAgent,
        isCanUseSensor = param?.isCanUseSensor ?? true,
        getAppList = param?.getAppList,
        isLocationEnabled = param?.isLocationEnabled ?? true,
        location = param?.location,
        isCanUseWifiState = param?.isCanUseWifiState ?? true,
        isCanUseOaid = param?.isCanUseOaid ?? true,
        devOaid = param?.devOaid,
        isCanUseAppList = param?.isCanUseAppList ?? true,
        isCanUseAndroidId = param?.isCanUseAndroidId ?? true,
        androidId = param?.androidId,
        isCanUseMacAddress = param?.isCanUseMacAddress ?? true,
        macAddress = param?.macAddress ?? "",
        isCanUseWriteExternal = param?.isCanUseWriteExternal ?? true,
        isCanUseShakeAd = param?.isCanUseShakeAd ?? true,
        devImei = param?.devImei,
        devImeiList = param?.devImeiList,
        isCanUseRecordAudio = param?.isCanUseRecordAudio ?? true,
        isCanUseIP = param?.isCanUseIP ?? true,
        ip = param?.ip,
        isCanUseSimOperator = param?.isCanUseSimOperator ?? true,
        devSimOperatorCode = param?.devSimOperatorCode ?? "",
        devSimOperatorName = param?.devSimOperatorName ?? "";

  /// 转为 Map
  Map<String, dynamic> toJson() {
    return {
      AMPSControllerKey.isCanUsePhoneState: isCanUsePhoneState,
      AMPSControllerKey.isSupportPersonalized: isSupportPersonalized,
      AMPSControllerKey.getUnderageTag: getUnderageTag.value, // 枚举用名称传递
      AMPSControllerKey.userAgent: userAgent,
      AMPSControllerKey.isCanUseSensor: isCanUseSensor,
      AMPSControllerKey.isLocationEnabled: isLocationEnabled,
      AMPSControllerKey.location: location?.toJson(), // 嵌套对象序列化
      AMPSControllerKey.isCanUseWifiState: isCanUseWifiState,
      AMPSControllerKey.isCanUseOaid: isCanUseOaid,
      AMPSControllerKey.devOaid: devOaid,
      AMPSControllerKey.isCanUseAppList: isCanUseAppList,
      AMPSControllerKey.getAppList:
          getAppList?.map((info) => info.toJson()).toList(),
      AMPSControllerKey.isCanUseAndroidId: isCanUseAndroidId,
      AMPSControllerKey.androidId: androidId,
      AMPSControllerKey.isCanUseMacAddress: isCanUseMacAddress,
      AMPSControllerKey.macAddress: macAddress,
      AMPSControllerKey.isCanUseWriteExternal: isCanUseWriteExternal,
      AMPSControllerKey.isCanUseShakeAd: isCanUseShakeAd,
      AMPSControllerKey.devImei: devImei,
      AMPSControllerKey.devImeiList: devImeiList,
      AMPSControllerKey.isCanUseRecordAudio: isCanUseRecordAudio,
      AMPSControllerKey.isCanUseIP: isCanUseIP,
      AMPSControllerKey.ip: ip,
      AMPSControllerKey.isCanUseSimOperator: isCanUseSimOperator,
      AMPSControllerKey.devSimOperatorCode: devSimOperatorCode,
      AMPSControllerKey.devSimOperatorName: devSimOperatorName,
    };
  }
}

/// AMPSCustomController 的参数类
class AMPSCustomControllerParam {
  /// 是否可以使用PhoneState权限
  final bool? isCanUsePhoneState;

  /// 透传OAID
  final String? OAID;

  /// 是否允许使用个性化推荐
  final bool? isSupportPersonalized;

  /// 适龄标记
  final UnderageTag? getUnderageTag;

  /// userAgent
  final String? userAgent;

  /// 是否可以使用传感器
  final bool? isCanUseSensor;

  /// 是否允许SDK自身获取定位
  final bool? isLocationEnabled;

  /// 三方设置的位置信息
  final AMPSLocation? location;

  final bool? isCanUseWifiState;
  final bool? isCanUseOaid;
  final String? devOaid;
  final bool? isCanUseAppList;

  /// app安装列表
  final List<PackageInfo>? getAppList;
  final bool? isCanUseAndroidId;
  final String? androidId;
  final bool? isCanUseMacAddress;
  final String? macAddress;
  final bool? isCanUseWriteExternal;
  final bool? isCanUseShakeAd;
  final String? devImei;
  final List<String>? devImeiList;
  final bool? isCanUseRecordAudio;
  final bool? isCanUseIP;
  final String? ip;
  final bool? isCanUseSimOperator;
  final String? devSimOperatorCode;
  final String? devSimOperatorName;

  AMPSCustomControllerParam({
    this.isCanUsePhoneState,
    this.OAID,
    this.isSupportPersonalized,
    this.getUnderageTag,
    this.userAgent,
    this.isCanUseSensor,
    this.isLocationEnabled,
    this.location,
    this.isCanUseWifiState,
    this.isCanUseOaid,
    this.devOaid,
    this.isCanUseAppList,
    this.getAppList,
    this.isCanUseAndroidId,
    this.androidId,
    this.isCanUseMacAddress,
    this.macAddress,
    this.isCanUseWriteExternal,
    this.isCanUseShakeAd,
    this.devImei,
    this.devImeiList,
    this.isCanUseRecordAudio,
    this.isCanUseIP,
    this.ip,
    this.isCanUseSimOperator,
    this.devSimOperatorCode,
    this.devSimOperatorName,
  });
}

/// AMPSInitConfig类，用于表示初始化配置
class AMPSInitConfig {
  /// 媒体的账户ID
  String appId = "";

  /// 日志模式
  final bool _isDebugSetting;
  final bool _isUseHttps;

  /// 是否测试广告位(是否计价)
  final bool isTestAd;

  /// 添加支持的现金类型
  final String currency;

  /// 国家
  final int countryCN;

  final String appName;
  final UiModel uiModel;
  final bool adapterStatusBarHeight;
  final String userId;
  final String? province;
  final String? city;
  final String? region;
  final String? customGAID;
  /// 自定义UA
  final String? customUA;

  /// androidID
  final String? androidID;

  ///optionInfo Android特有
  final String? optionInfo;

  /// 聚合模式下，提前初始化的第三方广告渠道平台
  final List<String>? adapterNames;

  /// 聚合模式下，传递第三方广告渠道平台初始化参数
  final Map<String, Map<String, dynamic>> extensionParam;

  final bool isUseSplashPunchLine;

  final Map<String, dynamic> optionFields;

  final AMPSCustomController adController;
  final bool isMediation;
  static bool isMediationStatic = false;

  void a7bc8pp9i7d(String a5) {
    appId = a5;
  }

  /// 构造函数，接收Builder对象并进行初始化
  AMPSInitConfig(AMPSBuilder builder)
      : appId = builder.appId,
        appName = builder.appName,
        _isDebugSetting = builder.isDebugSetting,
        _isUseHttps = builder.isUseHttps,
        userId = builder.userId,
        optionFields = builder.optionFields,
        currency = builder.currency,
        countryCN = builder.countryCN,
        customUA = builder.customUA,
        androidID = builder.androidID,
        customGAID = builder.customGAID,
        optionInfo = builder.optionInfo,
        isTestAd = builder.isTestAd,
        adController = builder.adController,
        uiModel = builder.uiModel,
        adapterStatusBarHeight = builder.adapter,
        province = builder.province,
        city = builder.city,
        region = builder.region,
        adapterNames = builder.adapterNames,
        extensionParam = builder.extensionParam,
        isUseSplashPunchLine = builder.isUseSplashPunchLine,
        isMediation = builder.isMediation;

  /// 转为 Map（用于JSON序列化）
  Map<String, dynamic> toMap(bool testModel) {
    return {
      /// 基础类型直接传递
      AMPSInitConfigKey.testModel: testModel,
      AMPSInitConfigKey.appId: appId,
      AMPSInitConfigKey.isDebugSetting: _isDebugSetting,
      AMPSInitConfigKey.isUseHttps: _isUseHttps,
      AMPSInitConfigKey.isTestAd: isTestAd,
      AMPSInitConfigKey.currency: currency,
      AMPSInitConfigKey.countryCN: countryCN,
      AMPSInitConfigKey.appName: appName,
      AMPSInitConfigKey.customUA: customUA,
      AMPSInitConfigKey.customGAID: customGAID,
      AMPSInitConfigKey.optionInfo: optionInfo,
      AMPSInitConfigKey.userId: userId,
      AMPSInitConfigKey.province: province,
      AMPSInitConfigKey.adapterStatusBarHeight: adapterStatusBarHeight,
      AMPSInitConfigKey.city: city,
      AMPSInitConfigKey.region: region,
      AMPSInitConfigKey.isMediation: isMediation,
      AMPSInitConfigKey.uiModel: uiModel.name, // 假设 UiModel 是枚举
      AMPSInitConfigKey.adapterNames: adapterNames,
      AMPSInitConfigKey.extensionParam: extensionParam,
      AMPSInitConfigKey.optionFields: optionFields,
      AMPSInitConfigKey.isUseSplashPunchLine: isUseSplashPunchLine,
      AMPSInitConfigKey.adController: adController.toJson(),
    };
  }
}

class AMPSBuilder {
  String appId;
  String appName = "";
  bool isDebugSetting = false;
  bool isUseHttps = false;
  String userId = "";
  String? customUA;
  String? androidID;
  String? optionInfo;
  String? customGAID;
  Map<String, dynamic> optionFields = {};
  String currency = "";
  int countryCN = CountryType.countryTypeChinaMainland;
  bool isTestAd = false;
  bool adapter = true;
  UiModel uiModel = UiModel.uiModelAuto;
  AMPSCustomController adController = AMPSCustomController(param: null);
  String? province;
  String? city;
  String? region;
  List<String>? adapterNames = [];
  late Map<String, Map<String, dynamic>> extensionParam;
  bool isMediation = true;
  var isUseSplashPunchLine = false;

  /// 构造函数，接收appId和context并进行初始化
  AMPSBuilder(this.appId) {
    extensionParam = <String, Map<String, dynamic>>{};
  }

  /// 设置是否启用聚合功能
  AMPSBuilder setIsMediation(bool isMediation) {
    this.isMediation = isMediation;
    return this;
  }

  /// 设置自定义UserAgent
  AMPSBuilder setCustomUA(String ua) {
    customUA = ua;
    return this;
  }

  /// 设置optionJson
  AMPSBuilder setOptionInfo(String optionJson) {
    optionInfo = optionJson;
    return this;
  }

  /// 设置省份
  AMPSBuilder setProvince(String pro) {
    province = pro;
    return this;
  }

  /// 设置城市
  AMPSBuilder setCity(String city) {
    this.city = city;
    return this;
  }

  /// 设置地区
  AMPSBuilder setRegion(String region) {
    this.region = region;
    return this;
  }

  /// 设置初始化第三方广告平台
  AMPSBuilder setAdapterNames(List<String> adapters) {
    adapterNames = adapters;
    return this;
  }

  /*
   * 设置某个渠道平台特有配置参数
   * key：渠道参数key，在AMPSConstants.ExtensionParamKey选择
   * param：具体参数集合
   */
  AMPSBuilder setExtensionParamItems(String key, Map<String, dynamic> param) {
    extensionParam[key] = param;
    return this;
  }

  /// 设置广告控制器
  AMPSBuilder setAdCustomController(AMPSCustomController controller) {
    adController = controller;
    return this;
  }

  /// 设置appName
  AMPSBuilder setAppName(String appName) {
    this.appName = appName;
    return this;
  }

  /// 设置调试模式
  AMPSBuilder setDebugSetting(bool debugSetting) {
    isDebugSetting = debugSetting;
    return this;
  }

  /// 设置是否使用HTTPS
  AMPSBuilder setUseHttps(bool isUseHttps) {
    this.isUseHttps = isUseHttps;
    return this;
  }

  /// 设置用户ID
  AMPSBuilder setUserId(String userId) {
    this.userId = userId;
    return this;
  }

  /// 设置选项字段
  AMPSBuilder setOptionFields(Map<String, dynamic> optionFields) {
    this.optionFields = optionFields;
    return this;
  }

  /// 设置货币类型
  AMPSBuilder setCurrency(String currency) {
    this.currency = currency;
    return this;
  }

  /// 设置国家代码
  AMPSBuilder setCountryCN(int countryCN) {
    this.countryCN = countryCN;
    return this;
  }

  /// 设置UI模型
  AMPSBuilder setUiModel(UiModel uiModel) {
    this.uiModel = uiModel;
    return this;
  }

  /// 设置是否为测试广告
  AMPSBuilder setIsTestAd(bool isTestAd) {
    this.isTestAd = isTestAd;
    return this;
  }

  /// 设置customGAID
  AMPSBuilder setGAID(String customGAID) {
    this.customGAID = customGAID;
    return this;
  }

  /// 设置落地页是否适配状态栏高度
  AMPSBuilder setLandStatusBarHeight([bool adapter = true]) {
    this.adapter = adapter;
    return this;
  }

  /// 设置是否使用开屏广告标语
  AMPSBuilder setIsUseSplashPunchLine(bool isUseSplashPunchLine) {
    this.isUseSplashPunchLine = isUseSplashPunchLine;
    return this;
  }

  /// 构建AMPSInitConfig对象的方法
  AMPSInitConfig build() {
    return AMPSInitConfig(this);
  }
}
