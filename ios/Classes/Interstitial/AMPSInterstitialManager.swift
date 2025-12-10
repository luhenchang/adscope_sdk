//
//  AMPS interstitialManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/23.
//

import Foundation

import Flutter
import AMPSAdSDK

class AMPSInterstitialManager: NSObject {
    
    static let shared = AMPSInterstitialManager()
    private override init() {super.init()}
    
    private var interstitialAd: AMPSInterstitialAd?
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.interstitialCreate:
            handleInterstitialCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialLoad:
            handleInterstitialLoad(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialShowAd:
            handleInterstitialShowAd(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialGetEcpm:
            result(interstitialAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.interstitialIsReadyAd:
            result(interstitialAd != nil)
        default:
            result(false)
        }
    }
//
//    // MARK: - Private Methods
    private func handleInterstitialCreate(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            result(nil)
            return
        }
        
        let config = AdOptionModule.getAdConfig(para: param)
        interstitialAd = AMPSInterstitialAd(spaceId: config.spaceId, adConfiguration: config)
        result(true)
    }
    private func handleInterstitialLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        interstitialAd?.delegate = self
        interstitialAd?.load()
        result(true)
    }
        
    private func handleInterstitialShowAd(arguments: [String: Any]?, result: FlutterResult) {
        guard let interstitialAd = interstitialAd else {
            result(false)
            return
        }
        
        guard let vc = getKeyWindow()?.rootViewController else {
            
            result(false)
            return
        }
        interstitialAd.show(withRootViewController: vc)
    
       
    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        interstitialAd?.sendWinNotification(withInfo: [BidKeys.winPrince:winPrice,BidKeys.lossSecondPrice:secPrice])
        result(true)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
        interstitialAd?.sendLossNotification(withInfo: [
            BidKeys.winPrince:lossWinPrice,
            BidKeys.lossSecondPrice:lossSecPrice,
            BidKeys.lossReason:lossReason
        ])
        result(true)
    }
    
    
    private func cleanupViewsAfterAdClosed() {
        interstitialAd?.delegate = nil
        interstitialAd?.remove()
        interstitialAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
}


extension AMPSInterstitialManager : AMPSInterstitialAdDelegate {
    func ampsInterstitialAdLoadSuccess(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
        sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
    }
    func ampsInterstitialAdLoadFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsInterstitialAdDidShow(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
    }
    func ampsInterstitialAdExposured(_ interstitialAd: AMPSInterstitialAd){
        sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
    }
    func ampsInterstitialAdDidClick(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
    }
    
    func ampsInterstitialAdShowFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShowError,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsInterstitialAdDidClose(_ interstitialAd: AMPSInterstitialAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
        cleanupViewsAfterAdClosed()
    }
}
