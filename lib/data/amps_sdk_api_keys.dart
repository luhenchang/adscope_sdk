//-------------------------------------------------------------------------------key固定不变和各端必须一致---------------------------------------------------------------
class OptionFieldKey {
  static const String colorLight = "lightColor";
  static const String colorDark = "darkColor";
  static const String crashCollectSwitch = "crashCollectSwitch";
}

class AMPSControllerKey {
  /// 对应 isCanUsePhoneState 的序列化键
  static const String isCanUsePhoneState = 'isCanUsePhoneState';

  /// 对应 OAID 的序列化键
  static const String oaid = 'OAID';

  /// 对应 isSupportPersonalized 的序列化键
  static const String isSupportPersonalized = 'isSupportPersonalized';

  /// 对应 getUnderageTag 的序列化键
  static const String getUnderageTag = 'getUnderageTag';

  /// 对应 userAgent 的序列化键
  static const String userAgent = 'userAgent';

  /// 对应 isCanUseSensor 的序列化键
  static const String isCanUseSensor = 'isCanUseSensor';

  /// 对应 isLocationEnabled 的序列化键
  static const String isLocationEnabled = 'isLocationEnabled';

  /// 对应 location 的序列化键
  static const String location = 'location';
}

class AMPSLocationKey {
  /// 对应纬度（latitude）的序列化键
  static const String latitude = 'latitude';

  /// 对应经度（longitude）的序列化键
  static const String longitude = 'longitude';

  /// 对应时间戳（timeStamp）的序列化键
  static const String timeStamp = 'timeStamp';

  /// 对应坐标系类型（coordinate）的序列化键
  static const String coordinate = 'coordinate';
}

class AMPSInitConfigKey {
  static const String testModel = 'testModel';
  /// 对应 appId 的序列化键
  static const String appId = 'appId';

  /// 对应 _isDebugSetting 的序列化键
  static const String isDebugSetting = '_isDebugSetting';

  /// 对应 _isUseHttps 的序列化键
  static const String isUseHttps = '_isUseHttps';

  /// 对应 isTestAd 的序列化键
  static const String isTestAd = 'isTestAd';

  /// 对应 currency 的序列化键
  static const String currency = 'currency';

  /// 对应 countryCN 的序列化键
  static const String countryCN = 'countryCN';

  /// 对应 appName 的序列化键
  static const String appName = 'appName';

  /// 对应 customUA 的序列化键
  static const String customUA = 'customUA';

  static const String androidId = "AndroidID";

  static const String gaId = "gaId";

  static const String optionInfo = "optionInfo";

  /// 对应 userId 的序列化键
  static const String userId = 'userId';

  /// 对应 province 的序列化键
  static const String province = 'province';

  /// 对应 adapterStatusBarHeight 的序列化键
  static const String adapterStatusBarHeight = 'adapterStatusBarHeight';

  /// 对应 city 的序列化键
  static const String city = 'city';

  /// 对应 region 的序列化键
  static const String region = 'region';

  /// 对应 isMediation 的序列化键
  static const String isMediation = 'isMediation';

  /// 对应 uiModel 的序列化键
  static const String uiModel = 'uiModel';

  /// 对应 adapterNames 的序列化键
  static const String adapterNames = 'adapterNames';

  /// 对应 extensionParam 的序列化键
  static const String extensionParam = 'extensionParam';

  /// 对应 optionFields 的序列化键
  static const String optionFields = 'optionFields';

  /// 对应 adController 的序列化键
  static const String adController = 'adController';
}