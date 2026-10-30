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
    private weak var eventManager: AMPSEventManager?
    private let requester = UUID()

    init(eventManager: AMPSEventManager) {
        self.eventManager = eventManager
    }
    
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
        
        AMPSInitializationCoordinator.shared.initialize(
            requester: requester,
            currentStatus: { AMPSAdSDKManager.sharedInstance().sdkInitializationStatus().rawValue },
            start: { callback in
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
                if let sensor = initParam?.adController?.isCanUseShakeAd,sensor == false{
                    config.closeShakeAd = true
                }
                if let jsonOption = initParam?.optionInfo {
                    config.optionalInfo = jsonOption
                }
                if let extensionParam: [String: Any] = flutterParams["extensionParam"] as? [String: Any] {
                    config.customExtraDict = extensionParam
                }

                AMPSAdSDKManager.sharedInstance().startAsync(withAppId: appid) { status in
                    callback(status.rawValue)
                }
            },
            completion: { [weak self] status in
                guard let self = self else { return }
                if status == 2 {
                    self.sendMessage(AMPSInitChannelMethod.initSuccess)
                }else if status == 3 {
                    self.sendMessage(AMPSInitChannelMethod.initFailed)
                }else if status == 1 {
                    self.sendMessage(AMPSInitChannelMethod.initializing)
                }else{
                    self.sendMessage(AMPSInitChannelMethod.alreadyInit)
                }
            }
        )
    }

    func release() {
        AMPSInitializationCoordinator.shared.cancel(requester: requester)
    }

    func sendMessage(_ method: String, args: Any? = nil) {
        eventManager?.sendToFlutter(method)
    }
}


