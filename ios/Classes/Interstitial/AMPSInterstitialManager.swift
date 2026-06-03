//
//  AMPSInterstitialManager.swift
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSInterstitialManager: NSObject {
    
    static let shared = AMPSInterstitialManager()
    private override init() {super.init()}
    
    private var interstitialAds: [String: AMPSInterstitialAd] = [:]
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        let instanceId = instanceId(from: arguments)
        switch call.method {
        case AMPSAdSdkMethodNames.interstitialCreate:
            handleInterstitialCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.interstitialLoad:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
                return
            }
            handleInterstitialLoad(instanceId: instanceId, result: result)
        case AMPSAdSdkMethodNames.interstitialShowAd:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
                return
            }
            handleInterstitialShowAd(instanceId: instanceId, result: result)
        case AMPSAdSdkMethodNames.interstitialGetEcpm:
            result(interstitialAds[instanceId ?? ""]?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.interstitialGetSeatId:
            result(interstitialAds[instanceId ?? ""]?.successAdInfo.adapterSeatId)
        case AMPSAdSdkMethodNames.interstitialDestroy:
            if let instanceId = instanceId {
                cleanupViewsAfterAdClosed(instanceId: instanceId)
            }
            result(nil)
        case AMPSAdSdkMethodNames.interstitialIsReadyAd:
            if let instanceId = instanceId {
                result(interstitialAds[instanceId] != nil)
            } else {
                result(false)
            }
        case AMPSAdSdkMethodNames.interstitialPreLoad:
            if let instanceId = instanceId {
                interstitialAds[instanceId]?.preloadAd()
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func instanceId(from arguments: [String: Any]?) -> String? {
        return arguments?[ArgumentKeys.adInstanceId] as? String
    }
    
    private func interstitialId(for ad: AMPSInterstitialAd) -> String? {
        return interstitialAds.first { $0.value === ad }?.key
    }
    
    private func handleInterstitialCreate(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let param = arguments else {
            result(false)
            return
        }
        guard let instanceId = instanceId(from: param) else {
            result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        let ad = AMPSInterstitialAd(spaceId: config.spaceId, adConfiguration: config)
        ad.delegate = self
        interstitialAds[instanceId] = ad
        result(true)
    }
    
    private func handleInterstitialLoad(instanceId: String, result: @escaping FlutterResult) {
        guard let interstitialAd = interstitialAds[instanceId] else {
            result(FlutterError(code: "LOAD_FAILED", message: "Interstitial ad instance not found", details: instanceId))
            return
        }
        interstitialAd.delegate = self
        interstitialAd.load()
        result(true)
    }
        
    private func handleInterstitialShowAd(instanceId: String, result: @escaping FlutterResult) {
        guard let interstitialAd = interstitialAds[instanceId] else {
            result(false)
            return
        }
        guard let vc = getKeyWindow()?.rootViewController else {
            result(false)
            return
        }
        interstitialAd.show(withRootViewController: vc)
        result(true)
    }
    
    private func cleanupViewsAfterAdClosed(instanceId: String) {
        interstitialAds[instanceId]?.delegate = nil
        interstitialAds[instanceId]?.remove()
        interstitialAds.removeValue(forKey: instanceId)
    }
    
    private func sendMessage(_ method: String, instanceId: String, args: [String: Any]? = nil) {
        var payload: [String: Any] = [ArgumentKeys.adInstanceId: instanceId]
        if let args = args {
            for (k, v) in args { payload[k] = v }
        }
        AMPSEventManager.shared.sendToFlutter(method, arg: payload)
    }
}

extension AMPSInterstitialManager : AMPSInterstitialAdDelegate {
    func ampsInterstitialAdLoadSuccess(_ interstitialAd: AMPSInterstitialAd) {
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onLoadSuccess, instanceId: id)
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onRenderOk, instanceId: id)
    }
    func ampsInterstitialAdLoadFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onLoadFailure, instanceId: id, args: [
            "code": (error as? NSError)?.code ?? 0,
            "message": (error as? NSError)?.localizedDescription ?? ""
        ])
    }
    func ampsInterstitialAdDidShow(_ interstitialAd: AMPSInterstitialAd) {
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onAdShow, instanceId: id)
    }
    func ampsInterstitialAdExposured(_ interstitialAd: AMPSInterstitialAd){
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onAdExposure, instanceId: id)
    }
    func ampsInterstitialAdDidClick(_ interstitialAd: AMPSInterstitialAd) {
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onAdClicked, instanceId: id)
    }
    func ampsInterstitialAdShowFail(_ interstitialAd: AMPSInterstitialAd, error: (any Error)?) {
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onAdShowError, instanceId: id, args: [
            "code": (error as? NSError)?.code ?? 0,
            "message": (error as? NSError)?.localizedDescription ?? ""
        ])
    }
    func ampsInterstitialAdDidClose(_ interstitialAd: AMPSInterstitialAd) {
        guard let id = interstitialId(for: interstitialAd) else { return }
        sendMessage(AMPSInterstitialAdCallBackChannelMethod.onAdClosed, instanceId: id)
        cleanupViewsAfterAdClosed(instanceId: id)
    }
}
