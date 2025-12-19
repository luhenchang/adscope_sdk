//
//  AMPSNativeManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/24.
//

import Foundation

import Flutter
import AMPSAdSDK
//import ASNPAdSDK

class AMPSNativeManager: NSObject {
    
    static let shared = AMPSNativeManager()
    // Singleton
    private override init() {super.init()}
    
    var nativeAd: AMPSNativeExpressManager?
    var adIdMap: [AMPSNativeExpressView: String] = [:]
    
    let unifiedManager: AmpsIosUnifiedNativeManager = .init()
    

    var isNativeExpress:Bool = true

    
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        
        if let arguments = call.arguments as? [String: Any] {
            if let type = arguments["nativeType"] as? Int, type == 1 {
                self.unifiedManager.handleMethodCall(call, result: result)
                return
            }
            switch call.method {
            case AMPSAdSdkMethodNames.nativeCreate:
                handleNativeCreate(call, result: result)
            case AMPSAdSdkMethodNames.nativeGetEcpm:
                if let adId = arguments["adId"] as? String {
                    if  let view = self.getAdView(adId: adId) {
                        
                        result(view.eCPM())
                        return
                    }
                }
                result(0)
            case AMPSAdSdkMethodNames.nativeIsNativeExpress:
                result(true)
                
            case AMPSAdSdkMethodNames.nativeIsReadyAd:
                if let adId = arguments["adId"] as? String {
                    if  let view = self.getAdView(adId: adId) {
                        result(view.isReadyAd())
                        return
                    }
                }
            default:
                result(nil)
            }
        }
        
        if let type = call.arguments as? Int {
            if type == 1 {
                unifiedManager.handleMethodCall(call, result: result)
            }else{
                handleNativeLoad( result: result)
            }
            return
        }
        
    }

    // MARK: - Private Methods
    private func handleNativeCreate(_ call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        let configAM = AdOptionModule.getAdConfig(para: arguments)
        if configAM.adSize.width == 0 {
            configAM.adSize.width = UIScreen.main.bounds.width
        }
        nativeAd = AMPSNativeExpressManager(spaceId: configAM.spaceId, adConfiguration: configAM)
        result(true)
    }
    
    // MARK: - Private Methods
    private func handleNativeLoad(result: FlutterResult) {
        
        nativeAd?.delegate = self
        nativeAd?.load()
        result(true)
    }
    
    
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
    
    //根据adID获取广告位
    func getAdView(adId:String) -> AMPSNativeExpressView?{
        if let (view,_) =  self.adIdMap.first(where: { (key: AMPSNativeExpressView, value: String) in
            return  value == adId
        }) {
            return view
        }
        return nil
    }
    
    func getUnifiedNativeView(_ adId: String) -> AMPSUnifiedNativeView?{
       return self.unifiedManager.getUnifiedNativeAdView(adId)
    }
    
    
}
extension AMPSNativeManager: AMPSNativeExpressManagerDelegate{
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSNativeExpressManager) {
        self.adIdMap.removeAll()
        let ids: [String]? =  nativeAd.viewsArray.map({ view in
            let id = UUID().uuidString
            self.adIdMap[view] = id
            return id
        })
        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ids)
        
        nativeAd.viewsArray.forEach { view in
            view.delegate = self
            view.render()
        }
    }
    func ampsNativeAdLoadFail(_ nativeAd: AMPSNativeExpressManager, error: (any Error)?) {
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail,["code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
    }
    
}

extension AMPSNativeManager: AMPSNativeExpressViewDelegate{
    
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.renderSuccess,adID)
        }
    }
    
    func ampsNativeAdRenderFail(_ nativeView: AMPSNativeExpressView, error: (any Error)?) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.renderFailed,["adId":adID,"code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
        }
    }
    
    func ampsNativeAdExposured(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.onAdExposure,adID)
        }
    }
    
    func ampsNativeAdDidClick(_ nativeView: AMPSNativeExpressView) {
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.onAdClicked,adID)
        }
    }
    
    func ampsNativeAdDidClose(_ nativeView: AMPSNativeExpressView) {
        nativeView.removeNativeAd()
        if let adID = self.adIdMap[nativeView] {
            sendMessage(AMPSNativeCallBackChannelMethod.onAdClosed,adID)
        }
        self.adIdMap.removeValue(forKey: nativeView)
        if adIdMap.isEmpty {
            self.nativeAd?.remove()
        }
    }
    
    
}







