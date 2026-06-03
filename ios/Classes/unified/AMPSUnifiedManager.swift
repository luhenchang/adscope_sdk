//
//  AMPSUnifiedManager.swift
//

import Foundation
import AMPSAdSDK
import Flutter

class AmpsIosUnifiedNativeManager: NSObject, AMPSUnifiedNativeManagerDelegate {
    let instanceId: String
    var unifiedNative: AMPSUnifiedNativeManager?
    var adIdMap: [String: AMPSUnifiedNativeView] = [:]
    
    init(instanceId: String) {
        self.instanceId = instanceId
        super.init()
    }
    
    func getUnifiedNativeAdView(_ adId: String) -> AMPSUnifiedNativeView? {
        return self.adIdMap[adId]
    }
    
    func getadId(unifiedAd: AMPSUnifiedNativeView) -> String? {
        if let (id, _) = self.adIdMap.first(where: { (_, value: AMPSUnifiedNativeView) in value == unifiedAd }) {
            return id
        }
        return nil
    }
    
    func getadIdFrom(mediaView: AMPSMediaView) -> String? {
        if let (id, _) = self.adIdMap.first(where: { (_, value: AMPSUnifiedNativeView) in value.mediaView == mediaView }) {
            return id
        }
        return nil
    }
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        switch call.method {
        case AMPSAdSdkMethodNames.nativeCreate:
            handleNativeCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeLoad:
            handleNativeLoad(result: result)
        case AMPSAdSdkMethodNames.nativeGetEcpm:
            if let adId = arguments["adId"] as? String, let view = getUnifiedNativeAdView(adId) {
                result(view.eCPM())
                return
            }
            result(0)
        case AMPSAdSdkMethodNames.nativeGetUnifiedPattern:
            if let adId = arguments["adId"] as? String, let view = getUnifiedNativeAdView(adId) {
                result(view.nativeAd.nativeMode.rawValue == 3 ? 2 : 0)
                return
            }
            result(0)
        case AMPSAdSdkMethodNames.nativeIsNativeExpress:
            if let adId = arguments["adId"] as? String {
                result(getUnifiedNativeAdView(adId)?.nativeAd.nativeMode == .nativeExpress)
            } else {
                result(false)
            }
        case AMPSAdSdkMethodNames.nativeGetSeatId:
            result(unifiedNative?.successAdInfo.adapterSeatId)
            return
        case AMPSAdSdkMethodNames.nativeIsReadyAd:
            result(unifiedNative?.adArray.count ?? 0 > 0)
        case AMPSAdSdkMethodNames.nativeDestroy:
            cleanup()
            result(nil)
        case AMPSAdSdkMethodNames.nativeResume:
            result(nil)
        case AMPSAdSdkMethodNames.nativePause:
            result(nil)
        case AMPSAdSdkMethodNames.nativeGetMediaExtraInfo:
            result(nil)
        default:
            result(nil)
        }
    }
    
    private func handleNativeCreate(arguments: [String: Any], result: FlutterResult) {
        let config = AdOptionModule.getAdConfig(para: arguments)
        config.adCount = 1
        config.viewController = UIViewController.current()
        unifiedNative = AMPSUnifiedNativeManager(spaceId: config.spaceId, adConfiguration: config)
        result(true)
    }
    
    private func handleNativeLoad(result: FlutterResult) {
        unifiedNative?.delegate = self
        unifiedNative?.load()
        result(true)
    }
    
    func cleanup() {
        self.unifiedNative?.remove()
        self.unifiedNative?.delegate = nil
        self.unifiedNative = nil
        self.adIdMap.removeAll()
    }
    
    private func sendMessage(_ method: String, _ args: [String: Any] = [:]) {
        var payload = args
        payload[ArgumentKeys.adInstanceId] = instanceId
        AMPSEventManager.shared.sendToFlutter(method, arg: payload)
    }
    
    private func sendAdIdMessage(_ method: String, _ adId: String, extra: [String: Any] = [:]) {
        var payload: [String: Any] = ["adId": adId]
        for (k, v) in extra { payload[k] = v }
        sendMessage(method, payload)
    }
    
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSUnifiedNativeManager) {
        self.adIdMap.removeAll()
        let ids: [String] = nativeAd.adArray.map { ad in
            let id = UUID().uuidString
            let view = AMPSUnifiedNativeView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
            view.viewController = UIViewController.current()
            view.refreshData(ad)
            view.delegate = self
            self.adIdMap[id] = view
            return id
        }
        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ["adIds": ids])
        ids.forEach { adId in
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.renderSuccess, adId)
        }
    }
    
    func ampsNativeAdLoadFail(_ nativeAd: AMPSUnifiedNativeManager, error: (any Error)?) {
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
            "code": (error as? NSError)?.code ?? 0,
            "message": error?.localizedDescription ?? ""
        ])
    }
}

extension AmpsIosUnifiedNativeManager: AMPSUnifiedNativeViewDelegate, AMPSMediaVideoViewDelegate {
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.renderSuccess, adId)
        }
    }
    
    func ampsNativeAdRenderFail(_ nativeView: AMPSUnifiedNativeView, error: (any Error)?) {
        if let adID = self.getadId(unifiedAd: nativeView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.renderFailed, adID, extra: [
                "code": (error as? NSError)?.code ?? 0,
                "message": error?.localizedDescription ?? ""
            ])
        }
    }
    
    func ampsNativeAdExposured(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdExposure, adId)
        }
    }
    
    func ampsNativeAdDidClick(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdClicked, adId)
        }
    }
    
    func ampsNativeAdDidClose(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView) {
            self.adIdMap.removeValue(forKey: adId)
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdClosed, adId)
        }
        if self.adIdMap.isEmpty {
            cleanup()
        }
    }
    
    func ampsNativeAdDidPlayFinish(_ nativeView: AMPSUnifiedNativeView) { }
    func ampsNativeAdDidCloseOtherController(_ nativeView: AMPSUnifiedNativeView) { }
    
    func ampsMediaVideoViewDidPlay(_ mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onVideoPlayStart, adId)
        }
    }
    
    func ampsMediaVideoViewDidPause(_ mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onVideoPause, adId)
        }
    }
    
    func ampsMediaVideoViewDidFinishPlay(_ mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onVideoPlayComplete, adId)
        }
    }
    
    func ampsMediaVideoViewDidFailed(toPlay mediaView: AMPSMediaView) {
        if let adId = self.getadIdFrom(mediaView: mediaView) {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onVideoPlayError, adId)
        }
    }
    
    func ampsMediaVideoViewPlayerLeftTime(_ leftTime: Int, mediaView: AMPSMediaView) { }
}
