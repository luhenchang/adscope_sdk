//
//  AMPSUnifiedManager.swift
//

import Foundation
import AMPSAdSDK
import Flutter

class AmpsIosUnifiedNativeManager: NSObject, AMPSUnifiedNativeManagerDelegate {
    let instanceId: String
    private weak var eventManager: AMPSEventManager?
    var unifiedNative: AMPSUnifiedNativeManager?
    var configuration: AMPSAdConfiguration?
    var adIdMap: [String: AMPSUnifiedNativeView] = [:]
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
        let config = AdOptionModule.getAdConfig(para: arguments)
        config.adCount = 1
        configuration = config
        refreshPresenter()
        unifiedNative = AMPSUnifiedNativeManager(spaceId: config.spaceId, adConfiguration: config)
        result(true)
    }
    
    private func handleNativeLoad(result: FlutterResult) {
        refreshPresenter()
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
        }
    }
    
    func cleanup() {
        for view in adIdMap.values {
            view.delegate = nil
            view.mediaView?.delegate = nil
            view.removeFromSuperview()
        }
        self.unifiedNative?.remove()
        self.unifiedNative?.delegate = nil
        self.unifiedNative = nil
        self.configuration = nil
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
        sendMessage(AMPSNativeCallBackChannelMethod.loadFail, [
            "code": (error as? NSError)?.code ?? 0,
            "message": error?.localizedDescription ?? ""
        ])
    }
}

extension AmpsIosUnifiedNativeManager: AMPSUnifiedNativeViewDelegate, AMPSMediaVideoViewDelegate {
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
