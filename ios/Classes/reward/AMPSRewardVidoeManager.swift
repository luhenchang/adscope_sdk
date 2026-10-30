//
//  AMPSRewardVidoeManager.swift
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSRewardVideoManager: NSObject {
    
    private weak var eventManager: AMPSEventManager?

    init(eventManager: AMPSEventManager) {
        self.eventManager = eventManager
        super.init()
    }
    
    private var rewardVideoAds: [String: AMPSRewardedVideoAd] = [:]
    private var rewardVideoAdConfigs: [String: AMPSAdConfiguration] = [:]
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        let instanceId = instanceId(from: arguments)
        switch call.method {
        case AMPSAdSdkMethodNames.rewardVideoCreate:
            handleRewardVideoCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.rewardVideoLoad:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
                return
            }
            handleRewardVideoLoad(instanceId: instanceId, result: result)
        case AMPSAdSdkMethodNames.rewardVideoShowAd:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
                return
            }
            handleRewardVideoShowAd(instanceId: instanceId, result: result)
        case AMPSAdSdkMethodNames.rewardVideoGetECPM:
            result(rewardVideoAds[instanceId ?? ""]?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.rewardVideoGetSeatId:
            result(rewardVideoAds[instanceId ?? ""]?.successAdInfo.adapterSeatId)
        case AMPSAdSdkMethodNames.rewardVideoPreLoad:
            if let instanceId = instanceId {
                rewardVideoAds[instanceId]?.preloadAd()
            }
            result(nil)
        case AMPSAdSdkMethodNames.rewardVideoDestroyAd:
            if let instanceId = instanceId {
                cleanupViewsAfterAdClosed(instanceId: instanceId)
            }
            result(nil)
        case AMPSAdSdkMethodNames.rewardVideoIsReadyAd:
            if let instanceId = instanceId {
                result(rewardVideoAds[instanceId] != nil)
            } else {
                result(false)
            }
        case AMPSAdSdkMethodNames.rewardVideoSetExtraDataMap:
            handleSetExtraDataMap(arguments: arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func release() {
        for id in Array(rewardVideoAds.keys) { cleanupViewsAfterAdClosed(instanceId: id) }
    }

    private func instanceId(from arguments: [String: Any]?) -> String? {
        return arguments?[ArgumentKeys.adInstanceId] as? String
    }
    
    private func rewardId(for ad: AMPSRewardedVideoAd) -> String? {
        return rewardVideoAds.first { $0.value === ad }?.key
    }
    
    private func handleRewardVideoCreate(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let param = arguments else {
            result(nil)
            return
        }
        guard let instanceId = instanceId(from: param) else {
            result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        if let temp = config.customExtraDict as? [String: [String: String]] {
            config.customExtraDict = temp
        }
        let ad = AMPSRewardedVideoAd(spaceId: config.spaceId, adConfiguration: config)
        ad.delegate = self
        rewardVideoAdConfigs[instanceId] = config
        rewardVideoAds[instanceId] = ad
        result(nil)
    }

    private func handleSetExtraDataMap(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let instanceId = instanceId(from: arguments) else {
            result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            return
        }
        guard let config = rewardVideoAdConfigs[instanceId] else {
            result(FlutterError(code: "UPDATE_FAILED", message: "Reward ad instance not found", details: instanceId))
            return
        }
        let extraDataMap = arguments?[AdOptionKeys.keyExtraDataMap] as? [String: Any]
        if let value = extraDataMap?[AdOptionKeys.keyAdnAmps] {
            config.extra = extraString(from: value)
        }
        result(nil)
    }

    private func extraString(from value: Any) -> String {
        if let extra = value as? String {
            return extra
        }
        if let extraDict = value as? [String: Any], let extra = extraDict[AdOptionKeys.keyExtra] as? String {
            return extra
        }
        return "\(value)"
    }
    
    private func handleRewardVideoLoad(instanceId: String, result: @escaping FlutterResult) {
        guard let rewardVideoAd = rewardVideoAds[instanceId] else {
            result(FlutterError(code: "LOAD_FAILED", message: "Reward ad instance not found", details: instanceId))
            return
        }
        rewardVideoAd.delegate = self
        rewardVideoAd.load()
        result(nil)
    }
        
    private func handleRewardVideoShowAd(instanceId: String, result: @escaping FlutterResult) {
        guard let rewardVideoAd = rewardVideoAds[instanceId] else {
            result(false)
            return
        }
        guard let vc = eventManager?.viewController else {
            result(false)
            return
        }
        rewardVideoAd.show(withRootViewController: vc)
        result(true)
    }
    
    private func cleanupViewsAfterAdClosed(instanceId: String) {
        rewardVideoAds[instanceId]?.delegate = nil
        rewardVideoAds[instanceId]?.remove()
        rewardVideoAds.removeValue(forKey: instanceId)
        rewardVideoAdConfigs.removeValue(forKey: instanceId)
    }
    
    private func sendMessage(_ method: String, instanceId: String, args: [String: Any]? = nil) {
        var payload: [String: Any] = [ArgumentKeys.adInstanceId: instanceId]
        if let args = args {
            for (k, v) in args { payload[k] = v }
        }
        eventManager?.sendToFlutter(method, arg: payload)
    }
}

extension AMPSRewardVideoManager : AMPSRewardedVideoAdDelegate {
    func ampsRewardedVideoAdLoadSuccess(_ rewardVideoAd: AMPSRewardedVideoAd) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onLoadSuccess, instanceId: id)
    }
    func ampsRewardedVideoAdLoadFail(_ rewardVideoAd: AMPSRewardedVideoAd, error: (any Error)?) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onLoadFailure, instanceId: id, args: [
            "code": (error as? NSError)?.code ?? 0,
            "message": (error as? NSError)?.localizedDescription ?? ""
        ])
    }
    func ampsRewardedVideoAdDidShow(_ rewardVideoAd: AMPSRewardedVideoAd) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdShow, instanceId: id)
    }
    func ampsRewardedVideoAdDidClick(_ rewardVideoAd: AMPSRewardedVideoAd) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdClicked, instanceId: id)
    }
    func ampsRewardedVideoAdDidClose(_ rewardVideoAd: AMPSRewardedVideoAd) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdClosed, instanceId: id)
        cleanupViewsAfterAdClosed(instanceId: id)
    }
    func ampsRewardedVideoAdDidPlayFinish(_ rewardVideoAd: AMPSRewardedVideoAd) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onVideoPlayEnd, instanceId: id)
    }
    func ampsRewardedVideoAdDidRewardEffective(_ rewardVideoAd: AMPSRewardedVideoAd) {
        guard let id = rewardId(for: rewardVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onAdReward, instanceId: id)
    }
    func ampsRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: AMPSRewardedVideoAd, error: any Error) {
        guard let id = rewardId(for: rewardedVideoAd) else { return }
        sendMessage(AMPSRewardedVideoCallBackChannelMethod.onServerRewardDidFail, instanceId: id, args: [
            "code": (error as NSError).code,
            "message": (error as NSError).localizedDescription
        ])
    }
}
