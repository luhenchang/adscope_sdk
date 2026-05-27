//
//  AMPSNativeManager.swift
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSNativeExpressSlot: NSObject {
    let instanceId: String
    var nativeAd: AMPSNativeExpressManager?
    var adIdMap: [AMPSNativeExpressView: String] = [:]
    
    init(instanceId: String) {
        self.instanceId = instanceId
        super.init()
    }
    
    func getAdView(adId: String) -> AMPSNativeExpressView? {
        if let (view, _) = self.adIdMap.first(where: { (_, value: String) in value == adId }) {
            return view
        }
        return nil
    }
    
    func cleanup() {
        self.nativeAd?.remove()
        self.nativeAd = nil
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
    
    func handleAdLoaded() {
        guard let nativeAd = self.nativeAd else { return }
        self.adIdMap.removeAll()
        let ids: [String] = nativeAd.viewsArray.map { view in
            let id = UUID().uuidString
            view.viewController = UIViewController.current()
            self.adIdMap[view] = id
            return id
        }
        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ["adIds": ids])
        nativeAd.viewsArray.forEach { view in
            view.render()
        }
    }
    
    func handleAdLoadFail(_ error: (any Error)?) {
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
            "code": (error as? NSError)?.code ?? 0,
            "message": error?.localizedDescription ?? ""
        ])
    }
    
    func handleRenderSuccess(_ view: AMPSNativeExpressView) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.renderSuccess, adID)
        }
    }
    
    func handleRenderFail(_ view: AMPSNativeExpressView, error: (any Error)?) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.renderFailed, adID, extra: [
                "code": (error as? NSError)?.code ?? 0,
                "message": error?.localizedDescription ?? ""
            ])
        }
    }
    
    func handleAdExposured(_ view: AMPSNativeExpressView) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdExposure, adID)
        }
    }
    
    func handleAdClick(_ view: AMPSNativeExpressView) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdClicked, adID)
        }
    }
    
    func handleAdClose(_ view: AMPSNativeExpressView) {
        view.removeNativeAd()
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdClosed, adID)
        }
        self.adIdMap.removeValue(forKey: view)
        if adIdMap.isEmpty {
            cleanup()
        }
    }
}

class AMPSNativeManager: NSObject {
    
    static let shared = AMPSNativeManager()
    private override init() { super.init() }
    
    private var expressSlots: [String: AMPSNativeExpressSlot] = [:]
    private var unifiedSlots: [String: AmpsIosUnifiedNativeManager] = [:]
    
    private func instanceId(from arguments: [String: Any]?) -> String? {
        return arguments?[ArgumentKeys.adInstanceId] as? String
    }
    
    private func slotForExpress(of view: AMPSNativeExpressView) -> AMPSNativeExpressSlot? {
        return expressSlots.values.first { $0.adIdMap[view] != nil }
    }
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(false)
            return
        }
        let nativeType = arguments["nativeType"] as? Int ?? 0
        if nativeType == 1 {
            if call.method == AMPSAdSdkMethodNames.nativeCreate {
                if let id = instanceId(from: arguments) {
                    let slot = AmpsIosUnifiedNativeManager(instanceId: id)
                    unifiedSlots[id] = slot
                    slot.handleMethodCall(call, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
                }
                return
            }
            if call.method == AMPSAdSdkMethodNames.nativeDestroy {
                if let id = instanceId(from: arguments) {
                    unifiedSlots.removeValue(forKey: id)?.cleanup()
                }
                result(nil)
                return
            }
            if let id = instanceId(from: arguments), let slot = unifiedSlots[id] {
                slot.handleMethodCall(call, result: result)
            } else {
                result(nil)
            }
            return
        }
        
        switch call.method {
        case AMPSAdSdkMethodNames.nativeCreate:
            handleNativeCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.nativeLoad:
            if let id = instanceId(from: arguments) {
                handleNativeLoad(instanceId: id, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            }
        case AMPSAdSdkMethodNames.nativeGetEcpm:
            if let adId = arguments["adId"] as? String, let view = getAdView(adId: adId) {
                result(view.eCPM())
                return
            }
            result(0)
        case AMPSAdSdkMethodNames.nativeIsNativeExpress:
            result(true)
        case AMPSAdSdkMethodNames.nativeIsReadyAd:
            if let adId = arguments["adId"] as? String, let view = getAdView(adId: adId) {
                result(view.isReadyAd())
                return
            }
            result(false)
        case AMPSAdSdkMethodNames.nativeDestroy:
            if let id = instanceId(from: arguments) {
                expressSlots.removeValue(forKey: id)?.cleanup()
            }
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

    // MARK: - Private Methods
    private func handleNativeCreate(arguments: [String: Any], result: FlutterResult) {
        guard let id = instanceId(from: arguments) else {
            result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            return
        }
        let configAM = AdOptionModule.getAdConfig(para: arguments)
        if let tamp = configAM.customExtraDict as? [String: [CGFloat]] {
            let dic: [String: [String: NSValue]] = tamp.mapValues { floatValues in
                let size: CGSize = floatValues.count >= 2
                    ? CGSize(width: floatValues[0], height: floatValues[1])
                    : .zero
                return ["adSize": NSValue(cgSize: size)]
            }
            configAM.customExtraDict = dic
        }
        if configAM.adSize.width == 0 {
            configAM.adSize.width = UIScreen.main.bounds.width
        }
        configAM.viewController = UIViewController.current()
        let slot = AMPSNativeExpressSlot(instanceId: id)
        slot.nativeAd = AMPSNativeExpressManager(spaceId: configAM.spaceId, adConfiguration: configAM)
        expressSlots[id] = slot
        result(true)
    }
    
    private func handleNativeLoad(instanceId: String, result: FlutterResult) {
        guard let slot = expressSlots[instanceId] else {
            result(false)
            return
        }
        slot.nativeAd?.delegate = self
        slot.nativeAd?.load()
        result(true)
    }
    
    // 视图工厂按 adId 全局查找（UUID 不冲突）
    func getAdView(adId: String) -> AMPSNativeExpressView? {
        for slot in expressSlots.values {
            if let v = slot.getAdView(adId: adId) { return v }
        }
        return nil
    }
    
    func getUnifiedNativeView(_ adId: String) -> AMPSUnifiedNativeView? {
        for slot in unifiedSlots.values {
            if let v = slot.getUnifiedNativeAdView(adId) { return v }
        }
        return nil
    }
    
    func unifiedSlot(owning adView: AMPSUnifiedNativeView) -> AmpsIosUnifiedNativeManager? {
        for slot in unifiedSlots.values {
            if slot.adIdMap.values.contains(where: { $0 === adView }) {
                return slot
            }
        }
        return nil
    }
}

extension AMPSNativeManager: AMPSNativeExpressManagerDelegate {
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSNativeExpressManager) {
        guard let slot = expressSlots.values.first(where: { $0.nativeAd === nativeAd }) else { return }
        slot.handleAdLoaded()
        nativeAd.viewsArray.forEach { view in
            view.delegate = self
        }
    }
    
    func ampsNativeAdLoadFail(_ nativeAd: AMPSNativeExpressManager, error: (any Error)?) {
        guard let slot = expressSlots.values.first(where: { $0.nativeAd === nativeAd }) else { return }
        slot.handleAdLoadFail(error)
    }
}

extension AMPSNativeManager: AMPSNativeExpressViewDelegate {
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSNativeExpressView) {
        slotForExpress(of: nativeView)?.handleRenderSuccess(nativeView)
    }
    
    func ampsNativeAdRenderFail(_ nativeView: AMPSNativeExpressView, error: (any Error)?) {
        slotForExpress(of: nativeView)?.handleRenderFail(nativeView, error: error)
    }
    
    func ampsNativeAdExposured(_ nativeView: AMPSNativeExpressView) {
        slotForExpress(of: nativeView)?.handleAdExposured(nativeView)
    }
    
    func ampsNativeAdDidClick(_ nativeView: AMPSNativeExpressView) {
        slotForExpress(of: nativeView)?.handleAdClick(nativeView)
    }
    
    func ampsNativeAdDidClose(_ nativeView: AMPSNativeExpressView) {
        slotForExpress(of: nativeView)?.handleAdClose(nativeView)
    }
}
