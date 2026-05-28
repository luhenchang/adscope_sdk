//
//  AMPSDrawManager.swift
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSDrawSlot: NSObject {
    let instanceId: String
    var drawAd: AMPSDrawAdManager?
    var adIdMap: [AMPSDrawAdView: String] = [:]
    
    init(instanceId: String) {
        self.instanceId = instanceId
        super.init()
    }
    
    func getAdView(adId: String) -> AMPSDrawAdView? {
        if let (view, _) = self.adIdMap.first(where: { (_, value: String) in value == adId }) {
            return view
        }
        return nil
    }
    
    func cleanup() {
        self.drawAd?.remove()
        self.drawAd = nil
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
    
    /// 准备 adId 映射并通知 Flutter 加载成功。注意：实际的 `view.render()` 必须在外部
    /// 设置完 `view.delegate` 之后再触发，否则 render 回调收不到。
    func prepareIdsAndNotifyLoaded() -> [AMPSDrawAdView] {
        guard let drawAd = self.drawAd else { return [] }
        self.adIdMap.removeAll()
        let ids: [String] = drawAd.drawAdsArray.map { view in
            let id = UUID().uuidString
            self.adIdMap[view] = id
            return id
        }
        sendMessage(AmpsDrawCallbackChannelMethod.onLoadSuccess, ["adIds": ids])
        return drawAd.drawAdsArray
    }
    
    func handleAdLoadFail(_ error: (any Error)?) {
        sendMessage(AmpsDrawCallbackChannelMethod.onLoadFailure, [
            "code": (error as? NSError)?.code ?? 0,
            "message": error?.localizedDescription ?? ""
        ])
    }
    
    func handleRenderSuccess(_ view: AMPSDrawAdView) {
        view.viewController = UIViewController.current()
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AmpsDrawCallbackChannelMethod.onRenderSuccess, adID)
        }
    }
    
    func handleRenderFail(_ view: AMPSDrawAdView, error: (any Error)?) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AmpsDrawCallbackChannelMethod.onRenderFail, adID, extra: [
                "code": (error as? NSError)?.code ?? 0,
                "message": error?.localizedDescription ?? ""
            ])
        }
    }
    
    func handleAdExposured(_ view: AMPSDrawAdView) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AmpsDrawCallbackChannelMethod.onAdShow, adID)
        }
    }
    
    func handleAdClick(_ view: AMPSDrawAdView) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AmpsDrawCallbackChannelMethod.onAdClicked, adID)
        }
    }
    
    func handleAdPlayFinish(_ view: AMPSDrawAdView) {
        if let adID = self.adIdMap[view] {
            sendAdIdMessage(AmpsDrawCallbackChannelMethod.onVideoAdComplete, adID)
        }
    }
}

class AMPSDrawManager: NSObject {
    
    static let shared = AMPSDrawManager()
    private override init() { super.init() }
    
    private var drawSlots: [String: AMPSDrawSlot] = [:]
    
    private func instanceId(from arguments: [String: Any]?) -> String? {
        return arguments?[ArgumentKeys.adInstanceId] as? String
    }
    
    private func slot(of view: AMPSDrawAdView) -> AMPSDrawSlot? {
        return drawSlots.values.first { $0.adIdMap[view] != nil }
    }
    
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        let id = instanceId(from: arguments)
        switch call.method {
        case AMPSAdSdkMethodNames.drawCreate:
            handleDrawCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.drawLoad:
            if let id = id {
                handleDrawLoad(instanceId: id, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            }
        case AMPSAdSdkMethodNames.drawGetEcpm:
            if let adId = arguments?["adId"] as? String, let view = getAdView(adId: adId) {
                result(view.eCPM())
                return
            }
            result(0)
        case AMPSAdSdkMethodNames.drawIsReadyAd:
            if let adId = arguments?["adId"] as? String, let view = getAdView(adId: adId) {
                result(view.isReadyAd())
                return
            }
            result(false)
        case AMPSAdSdkMethodNames.drawPauseAd:
            if let adId = arguments?["adId"] as? String, let view = getAdView(adId: adId) {
                view.pause()
            }
            result(nil)
        case AMPSAdSdkMethodNames.drawResumeAd:
            if let adId = arguments?["adId"] as? String, let view = getAdView(adId: adId) {
                view.play()
            }
            result(nil)
        case AMPSAdSdkMethodNames.drawDestroyAd:
            if let id = id {
                drawSlots.removeValue(forKey: id)?.cleanup()
            }
            result(nil)
        default:
            result(nil)
        }
    }

    private func handleDrawCreate(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments = arguments else {
            result(false)
            return
        }
        guard let id = instanceId(from: arguments) else {
            result(FlutterError(code: "INVALID_ARGS", message: "adInstanceId is required", details: nil))
            return
        }
        let configAM = AdOptionModule.getAdConfig(para: arguments)
        if configAM.adSize.width == 0 {
            configAM.adSize.width = UIScreen.main.bounds.width
        }
        configAM.viewController = UIViewController.current()
        let slot = AMPSDrawSlot(instanceId: id)
        slot.drawAd = AMPSDrawAdManager(spaceId: configAM.spaceId, adConfiguration: configAM)
        drawSlots[id] = slot
        result(true)
    }
    
    private func handleDrawLoad(instanceId: String, result: FlutterResult) {
        guard let slot = drawSlots[instanceId] else {
            result(false)
            return
        }
        slot.drawAd?.delegate = self
        slot.drawAd?.load()
        result(true)
    }
    
    // 视图工厂按 adId 全局查找（UUID 不冲突）
    func getAdView(adId: String) -> AMPSDrawAdView? {
        for slot in drawSlots.values {
            if let v = slot.getAdView(adId: adId) { return v }
        }
        return nil
    }
}

extension AMPSDrawManager: AMPSDrawAdManagerDelegate {
    func ampsDrawAdLoadSuccess(_ drawVideoAd: AMPSDrawAdManager) {
        guard let slot = drawSlots.values.first(where: { $0.drawAd === drawVideoAd }) else { return }
        // 1. 必须先把 delegate 挂上，否则 render 回调收不到。
        drawVideoAd.drawAdsArray.forEach { view in
            view.delegate = self
        }
        // 2. 注册 adId 映射 + 通知 Flutter，并触发 render。
        let views = slot.prepareIdsAndNotifyLoaded()
        views.forEach { view in
            view.render()
        }
    }
    
    func ampsDrawAdLoadFail(_ drawVideoAd: AMPSDrawAdManager, error: (any Error)?) {
        guard let slot = drawSlots.values.first(where: { $0.drawAd === drawVideoAd }) else { return }
        slot.handleAdLoadFail(error)
    }
}

extension AMPSDrawManager: AMPSDrawAdViewDelegate {
    func ampsDrawAdRenderSuccess(_ drawAdView: AMPSDrawAdView) {
        slot(of: drawAdView)?.handleRenderSuccess(drawAdView)
    }
    
    func ampsDrawAdRenderFail(_ drawAdView: AMPSDrawAdView, error: (any Error)?) {
        slot(of: drawAdView)?.handleRenderFail(drawAdView, error: error)
    }
    
    func ampsDrawAdExposured(_ drawAdView: AMPSDrawAdView) {
        slot(of: drawAdView)?.handleAdExposured(drawAdView)
    }
    
    func ampsDrawAdDidClick(_ drawAdView: AMPSDrawAdView) {
        slot(of: drawAdView)?.handleAdClick(drawAdView)
    }
    
    func ampsDrawAdDidCloseOtherController(_ drawAdView: AMPSDrawAdView) {
        // 点击进入其他控制器后再返回 app 时触发，非广告关闭，不处理。
    }
    
    func ampsDrawAdDidPlayFinish(_ drawAdView: AMPSDrawAdView) {
        slot(of: drawAdView)?.handleAdPlayFinish(drawAdView)
    }
}
