//
//  AMPSBannerManager.swift
//  adscope_sdk
//
//  Created by dzq_bookPro on 2025/12/10.
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSBannerManager: NSObject {
    
    static let shared = AMPSBannerManager()
    private override init() {super.init()}
    
    private var bannerAd: AMPSBannerAd?
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.bannerCreate:
            handlebannerCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.bannerLoad:
            handlebannerLoad(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.bannerGetECPM:
            result(bannerAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.bannerIsReadyAd:
            result(bannerAd != nil)
        default:
            result(false)
        }
    }
//
//    // MARK: - Private Methods
    private func handlebannerCreate(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            result(nil)
            return
        }
        
        let config = AdOptionModule.getAdConfig(para: param)
//        config.adSize = CGSize(width: 350, height: 50)
        config.viewController = UIViewController.current()
        bannerAd = AMPSBannerAd(spaceId: config.spaceId, adConfiguration: config)
        result(true)
    }
    private func handlebannerLoad(arguments: [String: Any]?, result: FlutterResult) {
        
        bannerAd?.delegate = self
        bannerAd?.load()
        
        result(true)
    }
        
    
    func getBannerView() -> UIView?{
        return bannerAd?.bannerView
    }
    
    
    
    private func cleanupViewsAfterAdClosed() {
        bannerAd?.delegate = nil
        bannerAd?.remove()
        bannerAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
}


extension AMPSBannerManager : AMPSBannerAdDelegate {
    func ampsBannerAdLoadSuccess(_ bannerAd: AMPSBannerAd) {
        sendMessage(AMPSBannerCallBackChannelMethod.onLoadSuccess)
    }
    func ampsBannerAdLoadFail(_ bannerAd: AMPSBannerAd, error: (any Error)?) {
        sendMessage(AMPSBannerCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsBannerAdDidShow(_ bannerAd: AMPSBannerAd) {
        sendMessage(AMPSBannerCallBackChannelMethod.onAdShow)
    }
   
    func ampsBannerAdDidClick(_ bannerAd: AMPSBannerAd) {
        sendMessage(AMPSBannerCallBackChannelMethod.onAdClicked)
    }
    
    func ampsBannerAdDidClose(_ bannerAd: AMPSBannerAd) {
        sendMessage(AMPSBannerCallBackChannelMethod.onAdClosed)
        cleanupViewsAfterAdClosed()
    }
}
