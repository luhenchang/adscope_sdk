import { HashMap, JSON } from "@kit.ArkTS";
import { Any } from "@ohos/flutter_ohos";
import { AMPSConstants, AMPSCustomController, AMPSInitConfig, AMPSLocation } from "xyz.adscope.amps";
import { common } from "@kit.AbilityKit";

// -------------------------- 1. 定义常量对应的接口（一定和Flutter需一致） --------------------------
// UI模型常量接口
interface UiModelConstantInterface {
  readonly AUTO: string;
  readonly DARK: string;
  readonly LIGHT: string;
}

// 坐标类型常量接口
interface CoordinateConstantInterface {
  readonly BAIDU: string;
  readonly WGS84: string;
  readonly GCJ02: string;
}

// 外部参数Key接口
interface ParamsKeyInterface {
  // 核心参数
  readonly TEST_MODEL: string;
  readonly APP_ID: string;
  readonly IS_DEBUG_SETTING: string;
  readonly IS_USE_HTTPS: string;
  readonly IS_TEST_AD: string;

  // 基础信息参数
  readonly CURRENCY: string;
  readonly COUNTRY_CN: string;
  readonly USER_ID: string;
  readonly APP_NAME: string;
  readonly PROVINCE: string;
  readonly CITY: string;
  readonly REGION: string;

  // 中介与UI参数
  readonly IS_MEDIATION: string;
  readonly IS_MEDIATION_STATIC: string;
  readonly UI_MODEL: string;
  readonly ADAPTER_NAMES: string;

  // 扩展与配置参数
  readonly EXTENSION_PARAM: string;
  readonly OPTION_FIELDS: string;
  readonly AD_CONTROLLER: string;
  readonly ADAPTER_STATUS_BAR_HEIGHT: string;
}

// AdController内部属性Key接口
interface AdControllerPropKeyInterface {
  readonly IS_CAN_USE_PHONE_STATE: string;
  readonly OAID: string;
  readonly IS_SUPPORT_PERSONALIZED: string;
  readonly GET_UNDERAGE_TAG: string;
  readonly USER_AGENT: string;
  readonly IS_CAN_USE_SENSOR: string;
  readonly IS_LOCATION_ENABLED: string;
  readonly LOCATION: string;
}

// Location内部属性Key接口
interface LocationPropKeyInterface {
  readonly LATITUDE: string;
  readonly LONGITUDE: string;
  readonly TIME_STAMP: string;
  readonly COORDINATE: string;
}

// -------------------------- 2. 基于接口创建常量（确保类型合规） --------------------------
// UI模型常量
export const UiModelConstant: UiModelConstantInterface = {
  AUTO: "uiModelAuto",
  DARK: "uiModelDark",
  LIGHT: "uiModelLight"
};

// 坐标类型常量
export const CoordinateConstant: CoordinateConstantInterface = {
  BAIDU: "BAIDU",
  WGS84: "WGS84",
  GCJ02: "GCJ02"
};

// 外部参数Key常量
export const ParamsKey: ParamsKeyInterface = {
  // 核心参数
  TEST_MODEL: "testModel",
  APP_ID: "appId",
  IS_DEBUG_SETTING: "_isDebugSetting",
  IS_USE_HTTPS: "_isUseHttps",
  IS_TEST_AD: "isTestAd",
  // 基础信息参数
  CURRENCY: "currency",
  COUNTRY_CN: "countryCN",
  USER_ID: "userId",
  APP_NAME: "appName",
  PROVINCE: "province",
  CITY: "city",
  REGION: "region",
  // 中介与UI参数
  IS_MEDIATION: "isMediation",
  IS_MEDIATION_STATIC: "isMediationStatic",
  UI_MODEL: "uiModel",
  ADAPTER_NAMES: "adapterNames",
  // 扩展与配置参数
  EXTENSION_PARAM: "extensionParam",
  OPTION_FIELDS: "optionFields",
  AD_CONTROLLER: "adController",
  ADAPTER_STATUS_BAR_HEIGHT: "adapterStatusBarHeight"
};

// AdController内部属性Key常量
export const AdControllerPropKey: AdControllerPropKeyInterface = {
  IS_CAN_USE_PHONE_STATE: "isCanUsePhoneState",
  OAID: "OAID",
  IS_SUPPORT_PERSONALIZED: "isSupportPersonalized",
  GET_UNDERAGE_TAG: "getUnderageTag",
  USER_AGENT: "userAgent",
  IS_CAN_USE_SENSOR: "isCanUseSensor",
  IS_LOCATION_ENABLED: "isLocationEnabled",
  LOCATION: "location"
};

// Location内部属性Key常量（修复报错核心）
export const LocationPropKey: LocationPropKeyInterface = {
  LATITUDE: "latitude",
  LONGITUDE: "longitude",
  TIME_STAMP: "timeStamp",
  COORDINATE: "coordinate"
};

// -------------------------- 3. 统一类型定义 --------------------------
type ExtensionParamType = Map<string, HashMap<string, string | boolean | number | object>>;
type OptionFieldsType = HashMap<string, string | boolean>;
type AdControllerType = HashMap<string, string | boolean | number | HashMap<string, number | string>>;
type LocationMapType = HashMap<string, number | string>;

// -------------------------- 4. 业务类（逻辑完全不变） --------------------------
export class AMPSInitConfigConverter {
  static  testModel:boolean = false;
  /**
   * 将Flutter传递的Map参数转换为AMPSInitConfig实例
   * @param flutterParams Flutter端传递的初始化参数Map
   * @return 转换后的AMPSInitConfig实例
   * @throws IllegalArgumentException 当必要参数缺失或格式错误时
   */
  convert(flutterParams: Map<string, Any> | undefined, context: common.UIAbilityContext): AMPSInitConfig | undefined {
    // 核心参数：appId
    const mAppId = (flutterParams?.get(ParamsKey.APP_ID) as string) ?? "";
    let ampsInitConfigBuilder: AMPSInitConfig.Builder | undefined = new AMPSInitConfig.Builder(mAppId, context);
    if (flutterParams && flutterParams.size > 0) {
      if (context.windowStage) {
        ampsInitConfigBuilder?.setWindowStage(context.windowStage)
      }
      const _testModel = flutterParams.get(ParamsKey.TEST_MODEL) as boolean;
      if (_testModel) {
        AMPSInitConfigConverter.testModel = _testModel;
      }
      // 调试与网络配置
      const _isDebugSetting = flutterParams.get(ParamsKey.IS_DEBUG_SETTING) as boolean;
      if (_isDebugSetting != undefined) {
        ampsInitConfigBuilder?.setDebugSetting(_isDebugSetting);
      }
      const _isUseHttps = flutterParams.get(ParamsKey.IS_USE_HTTPS) as boolean;
      if (_isUseHttps != undefined) {
        ampsInitConfigBuilder?.setUseHttps(_isUseHttps);
      }
      const isTestAd = flutterParams.get(ParamsKey.IS_TEST_AD) as boolean;
      if (isTestAd != undefined) {
        ampsInitConfigBuilder?.setIsTestAd(isTestAd);
      }

      // 基础信息
      const currency = flutterParams.get(ParamsKey.CURRENCY) as string;
      if (currency) {
        ampsInitConfigBuilder?.setCurrency(currency);
      }
      const countryCN = flutterParams.get(ParamsKey.COUNTRY_CN) as number;
      if (countryCN) {
        ampsInitConfigBuilder?.setCountryCN(countryCN);
      }
      const appName = flutterParams.get(ParamsKey.APP_NAME) as string;
      if (appName) {
        ampsInitConfigBuilder?.setAppName(appName);
      }
      const userId = flutterParams.get(ParamsKey.USER_ID) as string;
      if (userId) {
        ampsInitConfigBuilder?.setUserId(userId);
      }
      const province = flutterParams.get(ParamsKey.PROVINCE) as string;
      if (province) {
        ampsInitConfigBuilder?.setProvince(province);
      }
      const city = flutterParams.get(ParamsKey.CITY) as string;
      if (city) {
        ampsInitConfigBuilder?.setCity(city);
      }
      const region = flutterParams.get(ParamsKey.REGION) as string;
      if (region) {
        ampsInitConfigBuilder?.setRegion(region);
      }

      // 中介配置
      const isMediation = flutterParams.get(ParamsKey.IS_MEDIATION) as boolean;
      if (isMediation != undefined) {
        ampsInitConfigBuilder?.setIsMediation(isMediation);
      }

      // UI模型配置
      const uiModel = flutterParams.get(ParamsKey.UI_MODEL) as string;
      if (uiModel) {
        if (uiModel === UiModelConstant.AUTO) {
          ampsInitConfigBuilder?.setUiModel(AMPSConstants.UiModel.UI_MODEL_AUTO);
        }
        if (uiModel === UiModelConstant.DARK) {
          ampsInitConfigBuilder?.setUiModel(AMPSConstants.UiModel.UI_MODEL_DARK);
        }
        if (uiModel === UiModelConstant.LIGHT) {
          ampsInitConfigBuilder?.setUiModel(AMPSConstants.UiModel.UI_MODEL_LIGHT);
        }
      }

      // 适配器配置
      const adapterNames = flutterParams.get(ParamsKey.ADAPTER_NAMES) as string[];
      if (adapterNames && adapterNames.length > 0) {
        ampsInitConfigBuilder?.setAdapterNames(adapterNames);
      }

      // 扩展参数
      const extensionParam = flutterParams.get(ParamsKey.EXTENSION_PARAM) as ExtensionParamType;
      if (extensionParam) {
        extensionParam.forEach((value, key) => {
          ampsInitConfigBuilder?.setExtensionParamItems(key, value);
        });
      }

      // 选项字段
      const optionFields = flutterParams.get(ParamsKey.OPTION_FIELDS) as OptionFieldsType;
      if (optionFields) {
        ampsInitConfigBuilder?.setOptionFields(optionFields);
      }

      // 状态栏高度适配
      const adapterStatusBarHeight = flutterParams.get(ParamsKey.ADAPTER_STATUS_BAR_HEIGHT) as boolean;
      if (adapterStatusBarHeight != undefined) {
        ampsInitConfigBuilder?.setLandStatusBarHeight(adapterStatusBarHeight);
      }

      // 广告控制器配置
      const adCmController = flutterParams.get(ParamsKey.AD_CONTROLLER) as AdControllerType;
      if (adCmController) {
        const ampsCustomController = new AMPSCustomController({});

        // 控制器基础属性
        const isCanUsePhoneState = adCmController.get(AdControllerPropKey.IS_CAN_USE_PHONE_STATE) as boolean;
        if (isCanUsePhoneState != undefined) {
          ampsCustomController.isCanUsePhoneState = isCanUsePhoneState;
        }
        const OAID = adCmController.get(AdControllerPropKey.OAID) as string;
        if (OAID) {
          ampsCustomController.OAID = OAID;
        }
        const isSupportPersonalized = adCmController.get(AdControllerPropKey.IS_SUPPORT_PERSONALIZED) as boolean;
        if (isSupportPersonalized != undefined) {
          ampsCustomController.isSupportPersonalized = isSupportPersonalized;
        }
        const getUnderageTag = adCmController.get(AdControllerPropKey.GET_UNDERAGE_TAG) as number;
        if (getUnderageTag != undefined) {
          ampsCustomController.getUnderageTag = getUnderageTag;
        }
        const userAgent = adCmController.get(AdControllerPropKey.USER_AGENT) as string;
        if (userAgent != undefined) {
          ampsCustomController.userAgent = userAgent;
        }
        const isCanUseSensor = adCmController.get(AdControllerPropKey.IS_CAN_USE_SENSOR) as boolean;
        if (isCanUseSensor != undefined) {
          ampsCustomController.isCanUseSensor = isCanUseSensor;
        }
        const isLocationEnabled = adCmController.get(AdControllerPropKey.IS_LOCATION_ENABLED) as boolean;
        if (isLocationEnabled != undefined) {
          ampsCustomController.isLocationEnabled = isLocationEnabled;
        }

        // 位置信息配置
        const locationMap = adCmController.get(AdControllerPropKey.LOCATION) as LocationMapType;
        if (locationMap != undefined) {
          const ampsLocation = new AMPSLocation();
          const latitude = locationMap.get(LocationPropKey.LATITUDE) as number;
          if (latitude) {
            ampsLocation.latitude = latitude;
          }
          const longitude = locationMap.get(LocationPropKey.LONGITUDE) as number;
          if (longitude) {
            ampsLocation.longitude = longitude;
          }
          const timeStamp = locationMap.get(LocationPropKey.TIME_STAMP) as number;
          if (timeStamp) {
            ampsLocation.timeStamp = timeStamp;
          }
          const coordinate = locationMap.get(LocationPropKey.COORDINATE) as string;
          if (coordinate) {
            if (coordinate === CoordinateConstant.BAIDU) {
              ampsLocation.coordinate = AMPSConstants.CoordinateType.BAIDU;
            }
            if (coordinate === CoordinateConstant.WGS84) {
              ampsLocation.coordinate = AMPSConstants.CoordinateType.WGS84;
            }
            if (coordinate === CoordinateConstant.GCJ02) {
              ampsLocation.coordinate = AMPSConstants.CoordinateType.GCJ02;
            }
          }
          ampsCustomController.location = ampsLocation;
        }
        ampsInitConfigBuilder?.setAdCustomController(ampsCustomController);
      }
    }
    return ampsInitConfigBuilder?.build();
  }
}