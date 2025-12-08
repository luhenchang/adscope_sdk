//
//  AMPSInitConfigConverter.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation


// MARK: - 常量定义
/// UI 模式常量
enum UiModelConstant {
    static let auto = "uiModelAuto"
    static let dark = "uiModelDark"
    static let light = "uiModelLight"
}

/// 坐标系常量
enum CoordinateConstant {
    static let baidu = "BAIDU"
    static let wgs84 = "WGS84"
    static let gcj02 = "GCJ02"
}

/// 参数键常量
enum ParamsKey {
    // 核心参数
    static let testModel = "testModel"
    static let appId = "appId"
    static let isDebugSetting = "_isDebugSetting"
    static let isUseHttps = "_isUseHttps"
    static let isTestAd = "isTestAd"
    
    // 基础信息参数
    static let currency = "currency"
    static let countryCN = "countryCN"
    static let userId = "userId"
    static let appName = "appName"
    static let province = "province"
    static let city = "city"
    static let region = "region"
    
    // 聚合与 UI 参数
    static let isMediation = "isMediation"
    static let isMediationStatic = "isMediationStatic"
    static let uiModel = "uiModel"
    static let adapterNames = "adapterNames"
    
    // 扩展与配置参数
    static let extensionParam = "extensionParam"
    static let optionFields = "optionFields"
    static let adController = "adController"
    static let adapterStatusBarHeight = "adapterStatusBarHeight"
}

/// 广告控制器属性键常量
enum AdControllerPropKey {
    static let isCanUsePhoneState = "isCanUsePhoneState"
    static let oaid = "OAID"
    static let androidID = "AndroidID"  // iOS 无此概念，仅保留键名
    static let gaid = "GAID"            // iOS 对应 IDFA，键名保留
    static let isSupportPersonalized = "isSupportPersonalized"
    static let isCanGatherOAID = "isCanGatherOAID"  // iOS 无此概念
    static let getUnderageTag = "getUnderageTag"
    static let userAgent = "userAgent"
    static let isCanUseSensor = "isCanUseSensor"
    static let isLocationEnabled = "isLocationEnabled"
    static let isCanUseAndroidID = "isCanUseAndroidID"  // iOS 无此概念
    static let location = "location"
}

struct AMPSIOSAdControllerModel:Codable {
    
    let isCanUsePhoneState: Bool?
    let OAID: String?
    let androidID : String?
    let gaid : String?
    let isSupportPersonalized: Bool?
    let isCanGatherOAID : Bool?
    let getUnderageTag : Int?
    let userAgent : String?
    let isCanUseSensor: Bool?
    let isLocationEnabled: Bool?
    let isCanUseAndroidID : Bool?
    let location : AMPSIOSLocationModel?
    let isCanUserSensor: Bool?
}
struct AMPSIOSLocationModel: Codable {
    let latitude: Double?
    let longitude: Double?
    let timeStamp: Double?
    let coordinate: String?
    
}

/// 定位属性键常量
enum LocationPropKey {
    static let latitude = "latitude"    // 纬度
    static let longitude = "longitude"  // 经度
    static let timeStamp = "timeStamp"  // 时间戳
    static let coordinate = "coordinate"// 坐标系
}


struct AMPSIOSInitModel:Codable {
    let appId: String?
    let _isUseHttps: Bool?
    let userId: String?
    let province: String?
    let city: String?
    let region: String?
    let customIDFA: String?
    let adapterName: [String]?
    var recommend: Bool? = true
    var adController: AMPSIOSAdControllerModel?
    let adapterNames: [String]?
    let isMediation: Bool?
    let currency: String?
    let _isDebugSetting: Bool?
    let appName: String?
//    let optionalInfor: [String:Any]?
}

