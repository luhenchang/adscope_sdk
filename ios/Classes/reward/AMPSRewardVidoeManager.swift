//
//  AMPSRewardVidoeManager.swift
//  adscope_sdk
//
//  Created by dzq_bookPro on 2025/12/9.
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSRewardVideoManager: NSObject {
    
    static let shared = AMPSRewardVideoManager()
    private override init() {super.init()}
    
    private var rewardVideoAd: AMPSRewardedVideoAd?
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.rewardVideoCreate:
            handleRewardVideoCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.rewardVideoLoad:
            handleRewardVideoLoad(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.rewardVideoShowAd:
            handleRewardVideoShowAd(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.rewardVideoGetECPM:
            result(rewardVideoAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.rewardVideoPreLoad:
            result(nil)
        case AMPSAdSdkMethodNames.rewardVideoDestroyAd:
            cleanupViewsAfterAdClosed()
            result(nil)
        case AMPSAdSdkMethodNames.rewardVideoIsReadyAd:
            result(rewardVideoAd != nil)
        default:
            result(nil)
        }
    }
//
//    // MARK: - Private Methods
    private func handleRewardVideoCreate(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            result(nil)
            return
        }
        
        let config = AdOptionModule.getAdConfig(para: param)
        rewardVideoAd = AMPSRewardedVideoAd(spaceId: config.spaceId, adConfiguration: config)
        result(nil)
    }
    private func handleRewardVideoLoad(arguments: [String: Any]?, result: FlutterResult) {
    
        rewardVideoAd?.delegate = self
        rewardVideoAd?.load()
        result(nil)
    }
        
    private func handleRewardVideoShowAd(arguments: [String: Any]?, result: FlutterResult) {
        guard let rewardVideoAd = rewardVideoAd else {
            result(false)
            return
        }
        
        guard let vc = getKeyWindow()?.rootViewController else {
            
            result(false)
            return
        }
        rewardVideoAd.show(withRootViewController: vc)
        result(true)
       
    }
    
    private func cleanupViewsAfterAdClosed() {
        rewardVideoAd?.delegate = nil
        rewardVideoAd?.remove()
        rewardVideoAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    
}


extension AMPSRewardVideoManager : AMPSRewardedVideoAdDelegate {
    func ampsRewardedVideoAdLoadSuccess(_ rewardVideoAd: AMPSRewardedVideoAd) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess)
    }
    func ampsRewardedVideoAdLoadFail(_ rewardVideoAd: AMPSRewardedVideoAd, error: (any Error)?) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsRewardedVideoAdDidShow(_ rewardVideoAd: AMPSRewardedVideoAd) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdShow)
    }
    
    func ampsRewardedVideoAdDidClick(_ rewardVideoAd: AMPSRewardedVideoAd) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdClicked)
    }
    
    func ampsRewardedVideoAdShowFail(_ rewardVideoAd: AMPSRewardedVideoAd, error: (any Error)?) {
        
    }
    func ampsRewardedVideoAdDidClose(_ rewardVideoAd: AMPSRewardedVideoAd) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdClosed)
        cleanupViewsAfterAdClosed()
    }
    func ampsRewardedVideoAdDidPlayFinish(_ rewardVideoAd: AMPSRewardedVideoAd) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd)
    }
    func ampsRewardedVideoAdDidRewardEffective(_ rewardVideoAd: AMPSRewardedVideoAd) {
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdReward)
    }
    
}
