//
//  AMPSSplashManager.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import Flutter
import AMPSAdSDK

private enum AMPSSplashConstant {
    /// 开屏广告默认底部视图高度（兜底值）
    static let defaultBottomViewHeight: CGFloat = 0
    /// 图片视图默认尺寸（避免零尺寸导致不可见）
    static let defaultImageSize: CGSize = CGSize(width: 100, height: 100)
    /// 标签视图默认字体大小
    static let defaultFontSize: CGFloat = 14
}

class AMPSSplashManager: NSObject {
    
    static let shared = AMPSSplashManager()
    private override init() {super.init()}
//    private var splashAd: ASNPSplashAd?
    private var splashAd: AMPSSplashAd?

    
    // MARK: - Public Methods
    func handleMethodCall(_ call: FlutterMethodCall, result: FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        switch call.method {
        case AMPSAdSdkMethodNames.splashCreate:
            handleSplashCreate(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashLoad:
            handleSplashLoad(result: result)
        case AMPSAdSdkMethodNames.splashShowAd:
            handleSplashShowAd(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashGetEcpm:
            result(splashAd?.eCPM() ?? 0)
        case AMPSAdSdkMethodNames.splashNotifyRtbWin:
            handleNotifyRTBWin(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashNotifyRtbLoss:
            handleNotifyRTBLoss(arguments: arguments, result: result)
        case AMPSAdSdkMethodNames.splashIsReadyAd:
            result(splashAd != nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleSplashCreate(arguments: [String: Any]?, result: FlutterResult) {
    
        guard let param = arguments else {
            return
        }
        let config = AdOptionModule.getAdConfig(para: param)
        splashAd = AMPSSplashAd(spaceId: config.spaceId, adConfiguration: config)
        splashAd?.delegate = self
        splashAd?.load()
        result(true)
    }
//    // MARK: - Private Methods
    private func handleSplashLoad( result: FlutterResult) {
    
        splashAd?.delegate = self
        splashAd?.load()
        result(true)
    }
    
//    func createSplashBottomView(arguments: [String: Any]?, windowWidth: CGFloat) -> UIView? {
//        guard let params = arguments else { return nil }
//        
//        // 1. 解析底部视图高度（小于等于 1 时不创建底部视图）
//        let bottomViewHeight = params["height"] as? CGFloat ?? AMPSSplashConstant.defaultBottomViewHeight
//        guard bottomViewHeight > 1 else { return nil }
//        
//        // 2. 创建底部视图容器
//        let bottomView = UIView(frame: CGRect(
//            x: 0,
//            y: 0,
//            width: windowWidth,
//            height: bottomViewHeight
//        ))
//        
//        // 3. 设置底部视图背景色（支持十六进制字符串）
//        if let bgColorHex = params["backgroundColor"] as? String {
//            bottomView.backgroundColor = UIColor(hexString: bgColorHex) ?? .clear
//        }
//        
//        // 4. 解析子视图参数（图片 + 文本）
//        let children = params["children"] as? [[String: Any]] ?? []
//        let (imageModel, textModel) = parseChildModels(from: children)
//        
//        // 5. 添加图片子视图
//        if let imageModel = imageModel {
//            addImageSubview(to: bottomView, model: imageModel)
//        }
//        
//        // 6. 添加文本子视图
//        if let textModel = textModel {
//            addTextSubview(to: bottomView, model: textModel, maxWidth: windowWidth)
//        }
//        
//        return bottomView
//    }
//        
//    /// 解析子视图模型（图片 + 文本）
//    func parseChildModels(from children: [[String: Any]]) -> (SplashBottomImage?, SplashBottomText?) {
//        var imageModel: SplashBottomImage?
//        var textModel: SplashBottomText?
//        
//        children.forEach { child in
//            let type = child["type"] as? String ?? ""
//            switch type {
//            case "image":
//                imageModel = Tools.convertToModel(from: child)
//            case "text":
//                textModel = Tools.convertToModel(from: child)
//            default:
//                break
//            }
//        }
//        
//        return (imageModel, textModel)
//    }
//        
//    /// 向底部视图添加图片子视图
//    func addImageSubview(to bottomView: UIView, model: SplashBottomImage) {
//        // 1. 计算图片视图frame（使用默认值兜底，避免零尺寸）
//        let x = model.x ?? 0
//        let y = model.y ?? 0
//        let width = model.width ?? AMPSSplashConstant.defaultImageSize.width
//        let height = model.height ?? AMPSSplashConstant.defaultImageSize.height
//        let imageFrame = CGRect(x: x, y: y, width: width, height: height)
//        
//        // 2. 创建图片视图
//        let imageView = UIImageView(frame: imageFrame)
//        // 注：橙色背景仅用于调试，正式环境可移除
//        imageView.backgroundColor = .orange
//        
//        // 3. 设置图片（从资源管理器获取）
//        if let imageName = model.imagePath {
//            imageView.image = AMPSEventManager.shared.getImage(imageName)
//        }
//        
//        bottomView.addSubview(imageView)
//    }
//        
//    /// 向底部视图添加文本子视图
//    func addTextSubview(to bottomView: UIView, model: SplashBottomText, maxWidth: CGFloat) {
//        // 1. 校验文本是否存在（无文本则不创建）
//        guard let text = model.text, !text.isEmpty else { return }
//        
//        // 2. 计算文本视图frame（适配自动换行）
//        let x = model.x ?? 0
//        let y = model.y ?? 0
//        let availableWidth = maxWidth - x
//        guard availableWidth > 0 else { return }
//        
//        // 3. 创建文本视图
//        let textLabel = UILabel()
//        textLabel.frame = CGRect(x: x, y: y, width: availableWidth, height: 0)
//        textLabel.numberOfLines = 0 // 支持多行
//        textLabel.text = text
//        
//        // 4. 设置文本样式（颜色 + 字体）
//        if let colorHex = model.color {
//            textLabel.textColor = UIColor(hexString: colorHex) ?? .black
//        }
//        let fontSize = model.fontSize ?? AMPSSplashConstant.defaultFontSize
//        textLabel.font = UIFont.systemFont(ofSize: fontSize)
//        
//        // 5. 自动计算文本高度并调整frame
//        let fittingSize = textLabel.sizeThatFits(CGSize(
//            width: availableWidth,
//            height: CGFloat.greatestFiniteMagnitude
//        ))
//        textLabel.frame.size.height = fittingSize.height
//        
//        bottomView.addSubview(textLabel)
//    }
    
    private func handleSplashShowAd(arguments: [String: Any]?, result: FlutterResult) {
        guard let splashAd = splashAd else {
            result(false)
            return
        }
        
        guard let window = getKeyWindow() else {
            
            result(false)
            return
        }
        if let param = arguments {
            let height = param["height"]  as? CGFloat ?? 0
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
                    tagLabel.frame.size.height = fittingSize.height // 应用计算出的高度
                }
                splashAd.adConfiguration.bottomView = bottomView
                splashAd.showSplashView(in: window)
                
            }
            
        }
        else{
            if let window = getKeyWindow() {
                splashAd.showSplashView(in: window)
            }
        }

    }
    
    private func handleNotifyRTBWin(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let winPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let secPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        splashAd?.sendWinNotification(withInfo: [BidKeys.winPrince:winPrice,BidKeys.lossSecondPrice:secPrice])
        result(true)
    }
    
    private func handleNotifyRTBLoss(arguments: [String: Any]?, result: FlutterResult) {
        guard let arguments =  arguments else{
            return
        }
        let lossWinPrice = arguments[ArgumentKeys.adWinPrice] as? Int ?? 0
        let lossSecPrice = arguments[ArgumentKeys.adSecPrice] as? Int ?? 0
        let lossReason = arguments[ArgumentKeys.adLossReason] as? String ?? ""
        splashAd?.sendLossNotification(withInfo: [
            BidKeys.winPrince:lossWinPrice,
            BidKeys.lossSecondPrice:lossSecPrice,
            BidKeys.lossReason:lossReason
        ])
        result(true)
    }
    
    private func cleanupViewsAfterAdClosed() {
        splashAd = nil
    }
    
    private func sendMessage(_ method: String, _ args: Any? = nil) {
        AMPSEventManager.shared.sendToFlutter(method, arg: args)
    }
    

}

extension AMPSSplashManager: AMPSSplashAdDelegate {
    func ampsSplashAdLoadSuccess(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadSuccess)
        sendMessage(AMPSAdCallBackChannelMethod.onRenderOk)
    }
    func ampsSplashAdLoadFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onLoadFailure, ["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsSplashAdDidShow(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShow)
    }
    func ampsSplashAdExposured(_ splashAd: AMPSSplashAd){
        sendMessage(AMPSAdCallBackChannelMethod.onAdExposure)
    }
    func ampsSplashAdDidClick(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClicked)
    }
    
    func ampsSplashAdShowFail(_ splashAd: AMPSSplashAd, error: (any Error)?) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdShowError,["code": (error as? NSError)?.code ?? 0,"message":(error as? NSError)?.localizedDescription ?? ""])
    }
    func ampsSplashAdDidClose(_ splashAd: AMPSSplashAd) {
        sendMessage(AMPSAdCallBackChannelMethod.onAdClosed)
        cleanupViewsAfterAdClosed()
    }
}

