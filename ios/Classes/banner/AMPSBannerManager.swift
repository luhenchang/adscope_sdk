//
//  AMPSBannerManager.swift
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSBannerManager: NSObject {
    
    static let shared = AMPSBannerManager()
    private override init() {super.init()}
    
    private var bannerAds: [String: AMPSBannerAd] = [:]
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        let instanceId = instanceId(from: arguments)
        switch call.method {
        case AMPSAdSdkMethodNames.bannerCreate:
            handlebannerCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.bannerLoad:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
                return
            }
            handlebannerLoad(instanceId: instanceId, result: result)
        case AMPSAdSdkMethodNames.bannerGetECPM:
            result(bannerAds[instanceId ?? ""]?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.bannerIsReadyAd:
            if let instanceId = instanceId {
                result(bannerAds[instanceId] != nil)
            } else {
                result(false)
            }
        case AMPSAdSdkMethodNames.bannerDestroyAd:
            if let instanceId = instanceId {
                cleanupViewsAfterAdClosed(instanceId: instanceId)
            }
            result(nil)
        case AMPSAdSdkMethodNames.bannerPreLoad:
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func instanceId(from arguments: [String: Any]?) -> String? {
        return arguments?[ArgumentKeys.adInstanceId] as? String
    }
    
    private func bannerId(for ad: AMPSBannerAd) -> String? {
        return bannerAds.first { $0.value === ad }?.key
    }
    
    func getBannerView(instanceId: String? = nil) -> UIView? {
        if let instanceId = instanceId {
            return bannerAds[instanceId]?.bannerView
        }
        return bannerAds.values.last?.bannerView
    }
    
    private func handlebannerCreate(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let param = arguments else {
            result(nil)
            return
        }
        guard let instanceId = instanceId(from: param) else {
            result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        config.viewController = UIViewController.current()
        let ad = AMPSBannerAd(spaceId: config.spaceId, adConfiguration: config)
        ad.delegate = self
        bannerAds[instanceId] = ad
        result(true)
    }
    
    private func handlebannerLoad(instanceId: String, result: @escaping FlutterResult) {
        guard let bannerAd = bannerAds[instanceId] else {
            result(false)
            return
        }
        bannerAd.delegate = self
        bannerAd.load()
        result(true)
    }
    
    private func cleanupViewsAfterAdClosed(instanceId: String) {
        bannerAds[instanceId]?.delegate = nil
        bannerAds[instanceId]?.remove()
        bannerAds.removeValue(forKey: instanceId)
    }
    
    private func sendMessage(_ method: String, instanceId: String, args: [String: Any]? = nil) {
        var payload: [String: Any] = [ArgumentKeys.adInstanceId: instanceId]
        if let args = args {
            for (k, v) in args { payload[k] = v }
        }
        AMPSEventManager.shared.sendToFlutter(method, arg: payload)
    }
}

extension AMPSBannerManager : AMPSBannerAdDelegate {
    func ampsBannerAdLoadSuccess(_ bannerAd: AMPSBannerAd) {
        guard let id = bannerId(for: bannerAd) else { return }
        sendMessage(AMPSBannerCallBackChannelMethod.onLoadSuccess, instanceId: id)
    }
    func ampsBannerAdLoadFail(_ bannerAd: AMPSBannerAd, error: (any Error)?) {
        guard let id = bannerId(for: bannerAd) else { return }
        sendMessage(AMPSBannerCallBackChannelMethod.onLoadFailure, instanceId: id, args: [
            "code": (error as? NSError)?.code ?? 0,
            "message": (error as? NSError)?.localizedDescription ?? ""
        ])
    }
    func ampsBannerAdDidShow(_ bannerAd: AMPSBannerAd) {
        guard let id = bannerId(for: bannerAd) else { return }
        sendMessage(AMPSBannerCallBackChannelMethod.onAdShow, instanceId: id)
    }
    func ampsBannerAdDidClick(_ bannerAd: AMPSBannerAd) {
        guard let id = bannerId(for: bannerAd) else { return }
        sendMessage(AMPSBannerCallBackChannelMethod.onAdClicked, instanceId: id)
    }
    func ampsBannerAdDidClose(_ bannerAd: AMPSBannerAd) {
        guard let id = bannerId(for: bannerAd) else { return }
        sendMessage(AMPSBannerCallBackChannelMethod.onAdClosed, instanceId: id)
        cleanupViewsAfterAdClosed(instanceId: id)
    }
}
