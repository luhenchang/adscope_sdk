//
//  AMPSUnifiedManager.swift
//

import Foundation
import UIKit
import AMPSAdSDK
import Flutter

class AmpsIosUnifiedNativeManager: NSObject, AMPSUnifiedNativeManagerDelegate {
    let instanceId: String
    private weak var eventManager: AMPSEventManager?
    var unifiedNative: AMPSUnifiedNativeManager?
    var configuration: AMPSAdConfiguration?
    var adIdMap: [String: AMPSUnifiedNativeView] = [:]
    var isMallMode = false
    private(set) var mallViews: [String: AMPSNativeExpressView] = [:]
    /// 轮播 refreshData 可能再次触发 renderSuccess，这些 adId 不应通知 Dart 插入新广告。
    private var carouselRefreshingAdIds: Set<String> = []
    
    init(instanceId: String, eventManager: AMPSEventManager?) {
        self.eventManager = eventManager
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
        case AMPSAdSdkMethodNames.nativeGetUnifiedExtras:
            let id = arguments["adId"] as? String ?? ""
            result(adIdMap[id]?.nativeAd.extras ?? [:])
        case AMPSAdSdkMethodNames.nativeGetMallInfo:
            result(mallInfo(adId: arguments["adId"] as? String ?? ""))
        case AMPSAdSdkMethodNames.nativeSetMallVisible:
            setMallVisible(adId: arguments["adId"] as? String ?? "", visible: arguments["visible"] as? Bool ?? false)
            result(nil)
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
        case AMPSAdSdkMethodNames.nativeGetUnifiedImages:
            if let adId = arguments["adId"] as? String, let view = getUnifiedNativeAdView(adId) {
//                let test =  [view.nativeAd.imageUrl,view.nativeAd.imageUrl]
                let urls = view.nativeAd.imageUrls.compactMap { $0 as? String }
                result(urls)
                return
            }
            result([])
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
        isMallMode = arguments["mallMode"] as? Bool ?? false
        let config = AdOptionModule.getAdConfig(para: arguments)
        config.adCount = 1
        configuration = config
        refreshPresenter()
        unifiedNative = AMPSUnifiedNativeManager(spaceId: config.spaceId, adConfiguration: config)
        result(true)
    }
    
    private func handleNativeLoad(result: FlutterResult) {
        guard let config = configuration else {
            result(FlutterError(code: "LOAD_FAILED", message: "Native ad configuration is unavailable", details: nil))
            return
        }
        refreshPresenter()
        // 失败后的 SDK manager 已释放；保留请求配置供同一 Flutter 实例重试。
        if unifiedNative == nil {
            unifiedNative = AMPSUnifiedNativeManager(spaceId: config.spaceId, adConfiguration: config)
        }
        unifiedNative?.delegate = self
        unifiedNative?.load()
        result(true)
    }

    /// Rebind the owning page. Pass a view to update that view only; otherwise update every loaded view.
    func refreshPresenter(on view: AMPSUnifiedNativeView? = nil) {
        eventManager?.bindPresenter { controller in
            self.configuration?.viewController = controller
            if let view = view {
                view.viewController = controller
            } else {
                for loaded in self.adIdMap.values {
                    loaded.viewController = controller
                }
            }
            for mall in self.mallViews.values { mall.viewController = controller }
        }
    }
    
    func cleanup(preserveConfiguration: Bool = false) {
        for (id, mall) in mallViews {
            adIdMap[id]?.nativeAd.setMallViewVisible(false)
            mall.removeFromSuperview()
        }
        mallViews.removeAll()
        for view in adIdMap.values {
            view.delegate = nil
            view.mediaView?.delegate = nil
            view.removeFromSuperview()
        }
        self.unifiedNative?.remove()
        self.unifiedNative?.delegate = nil
        self.unifiedNative = nil
        if !preserveConfiguration { self.configuration = nil }
        self.adIdMap.removeAll()
        self.carouselRefreshingAdIds.removeAll()
    }
    
    private func sendMessage(_ method: String, _ args: [String: Any] = [:]) {
        var payload = args
        payload[ArgumentKeys.adInstanceId] = instanceId
        eventManager?.sendToFlutter(method, arg: payload)
    }
    
    private func sendAdIdMessage(_ method: String, _ adId: String, extra: [String: Any] = [:]) {
        var payload: [String: Any] = ["adId": adId]
        for (k, v) in extra { payload[k] = v }
        sendMessage(method, payload)
    }
    
    func ampsNativeAdLoadSuccess(_ nativeAd: AMPSUnifiedNativeManager) {
        if isMallMode {
            guard unifiedNative === nativeAd else { return }
            guard let ad = nativeAd.adArray.first, ad.supportsECMall else {
                cleanup(preserveConfiguration: true)
                sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
                    "code": -1001, "message": "Winner has no embedded mall view; use a supported mall placement"
                ])
                return
            }
            for (oldId, mall) in mallViews {
                adIdMap[oldId]?.nativeAd.setMallViewVisible(false)
                mall.removeFromSuperview()
            }
            mallViews.removeAll()
            for old in adIdMap.values { old.delegate = nil }
            adIdMap.removeAll()
            let id = UUID().uuidString
            let bridge = AMPSUnifiedNativeView(frame: .zero)
            adIdMap[id] = bridge
            bridge.delegate = self
            refreshPresenter(on: bridge)
            bridge.refreshData(ad)
            sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ["adIds": [id]])
            return
        }
        self.adIdMap.removeAll()
        let ids: [String] = nativeAd.adArray.map { ad in
            let id = UUID().uuidString
            let view = AMPSUnifiedNativeView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
            self.adIdMap[id] = view
            refreshPresenter(on: view)
            view.refreshData(ad)
            view.delegate = self
            return id
        }
        sendMessage(AMPSNativeCallBackChannelMethod.loadOk, ["adIds": ids])
        ids.forEach { adId in
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.renderSuccess, adId)
        }
    }
    
    func ampsNativeAdLoadFail(_ nativeAd: AMPSUnifiedNativeManager, error: (any Error)?) {
        if isMallMode && unifiedNative !== nativeAd { return }
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
            "code": (error as? NSError)?.code ?? 0,
            "message": error?.localizedDescription ?? ""
        ])
    }

    func mallInfo(adId: String) -> [String: Any] {
        guard isMallMode, let ad = adIdMap[adId]?.nativeAd else {
            return ["supportsMall": false, "viewCreated": false, "isValid": false, "extras": [:]]
        }
        return ["supportsMall": ad.supportsECMall, "viewCreated": mallViews[adId] != nil,
                "isValid": ad.isMallViewValid(), "extras": ad.extras ?? [:]]
    }

    /// 只由 PlatformView 的挂载入口调用；查询参数和预加载不创建商城页面。
    func obtainMallEntry(adId: String) -> (AMPSUnifiedNativeAd, AMPSNativeExpressView)? {
        guard isMallMode, let ad = adIdMap[adId]?.nativeAd, ad.supportsECMall else { return nil }
        if let mall = mallViews[adId] { return (ad, mall) }
        refreshPresenter()
        guard let mall = ad.nativeExpressAdView else {
            sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
                "code": -1001, "message": "Mall placement returned no embedded view"
            ])
            return nil
        }
        mallViews[adId] = mall
        refreshPresenter()
        ad.setMallViewVisible(false)
        return (ad, mall)
    }

    func setMallVisible(adId: String, visible: Bool) {
        guard let mall = mallViews[adId], let ad = adIdMap[adId]?.nativeAd else { return }
        mall.isHidden = !visible
        ad.setMallViewVisible(visible && mall.window != nil && UIApplication.shared.applicationState == .active)
    }
}

extension AmpsIosUnifiedNativeManager: AMPSUnifiedNativeViewDelegate, AMPSMediaVideoViewDelegate {
    func ampsNativeAd(onEvent nativeView: AMPSUnifiedNativeView, eventCode: Int, info: [AnyHashable: Any]?) {
        guard let id = getadId(unifiedAd: nativeView) else { return }
        sendAdIdMessage("Native_onMallEvent", id, extra: ["code": eventCode, "info": info ?? [:]])
    }
    func ampsNativeAdRenderSuccess(_ nativeView: AMPSUnifiedNativeView) {
        if let adId = self.getadId(unifiedAd: nativeView) {
            if carouselRefreshingAdIds.remove(adId) != nil {
                return
            }
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
            if let mall = mallViews.removeValue(forKey: adId) {
                nativeView.nativeAd.setMallViewVisible(false)
                mall.removeFromSuperview()
            }
            self.adIdMap.removeValue(forKey: adId)
            sendAdIdMessage(AMPSNativeCallBackChannelMethod.onAdClosed, adId)
        }
        if self.adIdMap.isEmpty {
            cleanup()
        }
    }
    
    /// 自渲染轮播：同一 Flutter adId 槽位换素材，不发 renderSuccess，避免 Feed 插重复项。
    func ampsNativeAdCarouselRefresh(_ nativeView: AMPSUnifiedNativeView, ad nativeAd: AMPSUnifiedNativeAd) {
        guard let adId = getadId(unifiedAd: nativeView) else { return }
        if isMallMode {
            let previous = mallViews[adId]
            let host = previous?.superview as? AMPSMallContainer
            let visible = previous?.isHidden == false
            nativeView.nativeAd.setMallViewVisible(false)
            previous?.removeFromSuperview()
            refreshPresenter(on: nativeView)
            nativeView.delegate = self
            nativeView.refreshData(nativeAd)
            mallViews.removeValue(forKey: adId)
            guard nativeAd.supportsECMall else {
                cleanup(preserveConfiguration: true)
                sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
                    "code": -1001, "message": "Refreshed ad has no embedded mall capability"
                ])
                return
            }
            // 未挂载的预加载广告轮播时仍不取 view。
            if let host = host, let (_, mall) = obtainMallEntry(adId: adId) {
                host.attach(ad: nativeAd, mall: mall, visible: visible)
            }
            return
        }
        carouselRefreshingAdIds.insert(adId)
        refreshPresenter(on: nativeView)
        nativeView.delegate = self
        nativeView.refreshData(nativeAd)
        eventManager?.nativeManager.selfRenderViews.object(forKey: adId as NSString)?.reloadAd()
        sendAdIdMessage(AMPSNativeCallBackChannelMethod.onCarouselAdLoad, adId)
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
