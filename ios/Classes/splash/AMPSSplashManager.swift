//
//  AMPSSplashManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import Flutter
import AMPSAdSDK

class AMPSSplashManager: NSObject {
    
    static let shared = AMPSSplashManager()
    private override init() {super.init()}
    
    private var splashAds: [String: AMPSSplashAd] = [:]
    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        let instanceId = instanceId(from: arguments)
        switch call.method {
        case AMPSAdSdkMethodNames.splashCreate:
            handleSplashCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashLoad:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "splashInstanceId is required", details: nil))
                return
            }
            handleSplashLoad(instanceId: instanceId, result: result)
        case AMPSAdSdkMethodNames.splashShowAd:
            guard let instanceId = instanceId else {
                result(FlutterError(code: "INVALID_ARGS", message: "splashInstanceId is required", details: nil))
                return
            }
            handleSplashShowAd(instanceId: instanceId, arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashGetEcpm:
            result(splashAds[instanceId ?? ""]?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.splashGetSeatId:
            result(splashAds[instanceId ?? ""]?.successAdInfo.adapterSeatId)
        case AMPSAdSdkMethodNames.splashDestroy:
            if let instanceId = instanceId {
                cleanupViewsAfterAdClosed(instanceId: instanceId)
            }
            result(nil)
        case AMPSAdSdkMethodNames.splashIsReadyAd:
            if let instanceId = instanceId {
                result(splashAds[instanceId] != nil)
            } else {
                result(false)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func instanceId(from arguments: [String: Any]?) -> String? {
        return arguments?[ArgumentKeys.splashInstanceId] as? String
    }
    
    private func splashId(for ad: AMPSSplashAd) -> String? {
        return splashAds.first { $0.value === ad }?.key
    }
    
    private func handleSplashCreate(arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let param = arguments else {
            result(false)
            return
        }
        guard let instanceId = instanceId(from: param) else {
            result(FlutterError(code: "INVALID_ARGS", message: "splashInstanceId is required", details: nil))
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        let ad = AMPSSplashAd(spaceId: config.spaceId, adConfiguration: config)
        ad.delegate = self
        splashAds[instanceId] = ad
        result(true)
    }
    
    private func handleSplashLoad(instanceId: String, result: @escaping FlutterResult) {
        guard let splashAd = splashAds[instanceId] else {
            result(FlutterError(code: "LOAD_FAILED", message: "Splash ad instance not found", details: instanceId))
            return
        }
        splashAd.delegate = self
        splashAd.load()
        result(true)
    }
    
    private func resolveBottomParams(_ arguments: [String: Any]?) -> [String: Any]? {
        guard let arguments = arguments else { return nil }
        if let nested = arguments[ArgumentKeys.splashBottom] as? [String: Any] {
            return nested
        }
        if arguments["type"] as? String == "parent" {
            return arguments
        }
        return nil
    }
    
    private func handleSplashShowAd(instanceId: String, arguments: [String: Any]?, result: @escaping FlutterResult) {
        guard let splashAd = splashAds[instanceId] else {
            result(false)
            return
        }
        
        guard let window = getKeyWindow() else {
            result(false)
            return
        }
        if let param = resolveBottomParams(arguments) {
            let height = param["height"] as? CGFloat ?? 0
            let bgColor = param["backgroundColor"] as? String
            var imageModel: SplashBottomImage?
            var textModel: SplashBottomText?
            if let children = param["children"] as? [[String: Any]] {
                children.forEach { child in
                    let type = child["type"] as? String ?? ""
                    if type == "image"{
                        imageModel = Tools.convertToModel(from: child)
                    }else if type == "text" {
                        textModel = Tools.convertToModel(from: child)
                    }
                }
            }
            if height > 1 {
                let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(window.bounds.width), height: height))
                if let bgColor = bgColor{
                    bottomView.backgroundColor = UIColor(hexString: bgColor)
                }
                
                if let imageModel = imageModel {
                    let imageView = UIImageView(frame: CGRect(x: imageModel.x ?? 0, y: imageModel.y ?? 0, width: imageModel.width ?? 100, height: imageModel.height ?? 100))
                    if let imageName =  imageModel.imagePath {
                        imageView.image = AMPSEventManager.shared.getImage(imageName)
                    }
                    
                    bottomView.addSubview(imageView)
                    imageView.backgroundColor  = UIColor.orange
                }
                if let text = textModel?.text {
                    let widht = window.bounds.width - (textModel?.x ?? 0)
                    let tagLabel = UILabel(frame: CGRect(x: textModel?.x ?? 0, y: textModel?.y ?? 0, width: widht, height: 0))
                    tagLabel.numberOfLines = 0
                    if let color = textModel?.color {
                        tagLabel.textColor = UIColor(hexString: color)
                    }
                    tagLabel.text = text
                    if let font = textModel?.fontSize {
                        tagLabel.font = UIFont.systemFont(ofSize: font)
                    }
                    bottomView.addSubview(tagLabel)
                    let fittingSize = tagLabel.sizeThatFits(CGSize(width: widht, height: CGFloat.greatestFiniteMagnitude))
                    tagLabel.frame.size.height = fittingSize.height
                }
                splashAd.adConfiguration.bottomView = bottomView
                splashAd.showSplashView(in: window)
                result(true)
                return
            }
        }
        splashAd.showSplashView(in: window)
        result(true)
    }
    
    private func cleanupViewsAfterAdClosed(instanceId: String) {
        splashAds[instanceId]?.delegate = nil
        splashAds[instanceId]?.remove()
        splashAds.removeValue(forKey: instanceId)
    }
    
    private func sendMessage(_ method: String, instanceId: String, args: [String: Any]? = nil) {
        var payload: [String: Any] = [ArgumentKeys.splashInstanceId: instanceId]
        if let args = args {
            args.forEach { payload[$0.key] = $0.value }
        }
        AMPSEventManager.shared.sendToFlutter(method, arg: payload)
    }
}

extension AMPSSplashManager: AMPSSplashAdDelegate {
    func ampsSplashAdLoadSuccess(_ splashAd: AMPSSplashAd) {
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onLoadSuccess, instanceId: id)
        sendMessage(AMPSSplashAdCallBackChannelMethod.onRenderOk, instanceId: id)
    }
    func ampsSplashAdLoadFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onLoadFailure, instanceId: id, args: [
            "code": (error as? NSError)?.code ?? 0,
            "message": (error as? NSError)?.localizedDescription ?? ""
        ])
    }
    func ampsSplashAdDidShow(_ splashAd: AMPSSplashAd) {
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onAdShow, instanceId: id)
    }
    func ampsSplashAdExposured(_ splashAd: AMPSSplashAd){
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onAdExposure, instanceId: id)
    }
    func ampsSplashAdDidClick(_ splashAd: AMPSSplashAd) {
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onAdClicked, instanceId: id)
    }
    
    func ampsSplashAdShowFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onAdShowError, instanceId: id, args: [
            "code": (error as? NSError)?.code ?? 0,
            "message": (error as? NSError)?.localizedDescription ?? ""
        ])
    }
    func ampsSplashAdDidClose(_ splashAd: AMPSSplashAd) {
        guard let id = splashId(for: splashAd) else { return }
        sendMessage(AMPSSplashAdCallBackChannelMethod.onAdClosed, instanceId: id)
        cleanupViewsAfterAdClosed(instanceId: id)
    }
}
