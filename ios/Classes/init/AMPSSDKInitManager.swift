//
//  AMPSSDKInitManageer.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation
import Flutter
import AMPSAdSDK


class AMPSSDKInitManager {
    static let shared: AMPSSDKInitManager = AMPSSDKInitManager()
    
    private init() {}
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let flutterParams = call.arguments as? [String: Any]
        switch method {
        case AMPSAdSdkMethodNames.sdk_init:
            initAMPSSDK(flutterParams)
            result(true)
        case AMPSAdSdkMethodNames.getInitStatus:
            result(AMPSAdSDKManager.sharedInstance().sdkInitializationStatus().rawValue)
        case AMPSAdSdkMethodNames.getSdkVersion:
            result(AMPSAdSDKManager.sdkVersion())
        case AMPSAdSdkMethodNames.setPersonalRecommend:
            if let recommen = call.arguments as? Bool {
                AMPSAdSDKManager.sharedInstance().setPersonalizedRecommendState(recommen == true ? AMPSPersonalizedRecommendState.open : AMPSPersonalizedRecommendState.close)
            }
            result(nil)
        default:
            result(nil)
        }
    }
    
    func initAMPSSDK(_ flutterParams: [String:Any]?) {
        guard let flutterParams = flutterParams else {
            return
        }
        let initParam: AMPSIOSInitModel? = Tools.convertToModel(from: flutterParams)
        let appid = initParam?.appId ?? ""
        
        let config =  AMPSAdSDKManager.sharedInstance().sdkConfiguration
        
        if let https = initParam?._isUseHttps{
            config.isUseHttps = https
        }
        if let recommend = initParam?.adController?.isSupportPersonalized{
            config.recommend = recommend ? .open : .close
        }
        if let adapterNames = initParam?.adapterNames {
            config.adapterName = adapterNames
        }
        if let idfa = initParam?.adController?.OAID{
            config.customIDFA = idfa
        }
        if let sensor = initParam?.adController?.isCanUseSensor,sensor == false{
            config.closeShakeAd = true
        }

        AMPSAdSDKManager.sharedInstance().startAsync(withAppId: appid) { status in
    
            if status == AMPSAdSDKInitStatus.success {
                self.sendMessage(AMPSInitChannelMethod.initSuccess)
            }else if status == AMPSAdSDKInitStatus.fail {
                self.sendMessage(AMPSInitChannelMethod.initFailed)
            }else if status == AMPSAdSDKInitStatus.loading {
                self.sendMessage(AMPSInitChannelMethod.initializing)
            }else{
                self.sendMessage(AMPSInitChannelMethod.alreadyInit)
            }
        }
    
    }
    
    func sendMessage(_ method: String, args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method)
    }
}


