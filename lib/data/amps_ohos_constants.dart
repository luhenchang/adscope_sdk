// 枚举：首字母小写，后续单词首字母大写（lowerCamelCase）
enum UiModelOhos {
  uiModelAuto,
  uiModelDark,
  uiModelLight
}

enum CoordinateTypeOhos {
  // 增强枚举值：驼峰命名，参数保持原字符串
  wgs84("WGS84"),
  gcj02("GCJ02"),
  baidu("BAIDU");

  final String value;
  const CoordinateTypeOhos(this.value);
}

/// 初始化设置, 货币选项
class CurrencyTypeOhos {
  static const String currencyTypeCny = "CNY"; //人民币
  static const String currencyTypeUsd = "USD"; //美元
  static const String currencyTypeJpy = "JPY"; //日元
  static const String currencyTypeEur = "EUR"; //欧元
  static const String currencyTypeGbp = "GBP"; //英镑
  static const String currencyTypeIdr = "IDR"; //印尼盾
  static const String currencyTypeMyr = "MYR"; //马来西亚林吉特
  static const String currencyTypePhp = "PHP"; //菲律宾比索
  static const String currencyTypeThb = "THB"; //泰铢（修正原KRW对应THB的命名错误）
}

///初始化设置, 国家类型选项
class CountryTypeOhos {
  // 修正语法错误：字符串类型不能赋值数字，改为字符串形式（或根据需求改为 int 类型）
  static const String countryTypeChinaMainland = "1";
  static const String countryTypeOther = "0";
}

/// 初始化设置,各个广告平台前置初始化
class AdapterNameOhos {
  //优加
  static const String asnp = "amps_asnp_adapter.AMPSASNPSDKManagerAdapter";
  //华为
  static const String hw = "amps_hw_adapter.AMPSHWSDKManagerAdapter";
  //穿山甲
  static const String csj = "amps_csj_adapter.AMPSCSJSDKManagerAdapter";
  //Gromore
  static const String groMore = "amps_gm_adapter.AMPSGMSDKManagerAdapter";
  //快手
  static const String ks = "amps_ks_adapter.AMPSKSSDKManagerAdapter";
  //百度
  static const String bd = "amps_bd_adapter.AMPSBDSDKManagerAdapter";
  //趣萌
  static const String qm = "amps_qm_adapter.AMPSQMSDKManagerAdapter";
  //广点通
  static const String gdt = "amps_gdt_adapter.AMPSGDTSDKManagerAdapter";
  //sigMob
  static const String sigMob = "amps_sigmob_adapter.AMPSSigmobSDKManagerAdapter";
  //京东
  static const String jd = "amps_jad_adapter.AMPSJDSDKManagerAdapter";
}

/// 初始化设置,各个广告平台透传参数
class ExtensionParamKeyOhos {
  //华为惊鸿
  static const String hw = "AMPSExtensionParamKeyHW";
  //穿山甲
  static const String csj = "AMPSExtensionParamKeyCSJ";
  //Gromore
  static const String groMore = "AMPSExtensionParamKeyGroMore";
  //快手
  static const String ks = "AMPSExtensionParamKeyKS";
  //百度
  static const String bd = "AMPSExtensionParamKeyBD";
  //趣萌
  static const String qm = "AMPSExtensionParamKeyQM";
  //广点通
  static const String gdt = "AMPSExtensionParamKeyGDT";
}

class OptionFieldKeyOhos {
  static const String keyColorLight = "lightColor";
  static const String keyColorDark = "darkColor";
  static const String keyNoCrashCollect = "crashCollectSwitch"; // 补充 const 和类型，修正原语法错误
}