//
//  AMPSDrawManager.swift
//  adscope_sdk
//
//  Created by dzq_bookPro on 2025/12/11.
//

import Foundation
import Flutter
import AMPSAdSDK
//import ASNPAdSDK

class AMPSDrawManager: NSObject {
    
    static let shared = AMPSDrawManager()
    // Singleton
    private override init() {super.init()}
    
    var drawAd: AMPSDrawAdManager?
    var adIdMap: [AMPSDrawAdView: String] = [:]
    
    var isDrawExpress:Bool = true

    
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.drawCreate:
            handleDrawCreate(call, result: result)
        case AMPSAdSdkMethodNames.drawLoad:
            handleDrawLoad(result: result)
        case AMPSAdSdkMethodNames.drawGetEcpm:
            if let adId = arguments?["adId"] as? String {
                if  let view = self.getAdView(adId: adId) {
                    result(view.eCPM())
                    return
                }
            }
            result(0)
        case AMPSAdSdkMethodNames.drawIsReadyAd:
            if let adId = arguments?["adId"] as? String {
                if  let view = self.getAdView(adId: adId) {
                    result(view.isReadyAd())
                    return
                }
            }
            result(false)
            
            
        case AMPSAdSdkMethodNames.drawPauseAd:
            if let adId = arguments?["adId"] as? String {
                if  let view = self.getAdView(adId: adId) {
                    view.pause()
                }
            }
            result(nil)
        case AMPSAdSdkMethodNames.drawResumeAd:
            if let adId = arguments?["adId"] as? String {
                if  let view = self.getAdView(adId: adId) {
                    view.play()
                }
            }
            result(nil)
        case AMPSAdSdkMethodNames.drawDestroyAd:
            if let adId = arguments?["adId"] as? String {
                if  let view = self.getAdView(adId: adId) {
                    view.removeDrawAd()
                }
            }
            result(nil)
        default:
            result(nil)
        }
        
        
        
    }

    // MARK: - Private Methods
    private func handleDrawCreate(_ call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        let configAM = AdOptionModule.getAdConfig(para: arguments)
        if configAM.adSize.width == 0 {
            configAM.adSize.width = UIScreen.main.bounds.width
        }
        configAM.viewController = UIViewController.current()
        drawAd = AMPSDrawAdManager(spaceId: configAM.spaceId, adConfiguration: configAM)
        result(true)
    }
    
    // MARK: - Private Methods
    private func handleDrawLoad(result: FlutterResult) {
        
        drawAd?.delegate = self
        drawAd?.load()
        result(true)
    }
    
    
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
    
    //根据adID获取广告位
    func getAdView(adId:String) -> AMPSDrawAdView?{
        if let (view,_) =  self.adIdMap.first(where: { (key: AMPSDrawAdView, value: String) in
            return  value == adId
        }) {
            return view
        }
        return nil
    }
    
    
}
extension AMPSDrawManager: AMPSDrawAdManagerDelegate{
    func ampsDrawAdLoadSuccess(_ drawVideoAd: AMPSDrawAdManager) {
        self.adIdMap.removeAll()
        let ids: [String]? =  drawVideoAd.drawAdsArray.map({ view in
            let id = UUID().uuidString
            self.adIdMap[view] = id
            return id
        })
        sendMessage(AmpsDrawCallbackChannelMethod.onLoadSuccess, ids)
        
        drawVideoAd.drawAdsArray.forEach { view in
            view.delegate = self
            view.render()
        }
    }
    func ampsDrawAdLoadFail(_ drawVideoAd: AMPSDrawAdManager, error: (any Error)?) {
        sendMessage(AmpsDrawCallbackChannelMethod.onLoadFailure,["code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
    }
    
}

extension AMPSDrawManager: AMPSDrawAdViewDelegate{
    
    func ampsDrawAdRenderSuccess(_ drawAdView: AMPSDrawAdView) {
        if let adID = self.adIdMap[drawAdView] {
            sendMessage(AmpsDrawCallbackChannelMethod.onRenderSuccess,adID)
        }
    }
    
    func ampsDrawAdRenderFail(_ drawAdView: AMPSDrawAdView, error: (any Error)?) {
        if let adID = self.adIdMap[drawAdView] {
            sendMessage(AmpsDrawCallbackChannelMethod.onRenderFail,["adId":adID,"code":(error as? NSError)?.code ?? 0,"message": error?.localizedDescription ?? ""])
        }
    }
    
    func ampsDrawAdExposured(_ drawAdView: AMPSDrawAdView) {
        if let adID = self.adIdMap[drawAdView] {
            sendMessage(AmpsDrawCallbackChannelMethod.onAdShow,adID)
        }
    }
    
    func ampsDrawAdDidClick(_ drawAdView: AMPSDrawAdView) {
        if let adID = self.adIdMap[drawAdView] {
            sendMessage(AmpsDrawCallbackChannelMethod.onAdClicked,adID)
        }
    }
    
    func ampsDrawAdDidCloseOtherController(_ drawAdView: AMPSDrawAdView) {
        drawAdView.removeDrawAd()
        if let adID = self.adIdMap[drawAdView] {
            sendMessage(AmpsDrawCallbackChannelMethod.onAdClosed,adID)
        }
        self.adIdMap.removeValue(forKey: drawAdView)
    }
    func ampsDrawAdDidPlayFinish(_ drawAdView: AMPSDrawAdView)  {
        if let adID = self.adIdMap[drawAdView] {
            sendMessage(AmpsDrawCallbackChannelMethod.onVideoAdComplete,adID)
        }
    }
    
    
}








