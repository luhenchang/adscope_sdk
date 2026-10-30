//
//  AMPSUnifiedNativeView.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/29.
//

import Foundation
import Flutter
import AMPSAdSDK


class AMPSUnifiedNAtiveViewFactory: NSObject, FlutterPlatformViewFactory {
    private let eventManager: AMPSEventManager

    init(eventManager: AMPSEventManager) {
        self.eventManager = eventManager
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AMPSSelfRenderView(frame: frame, viewId: viewId, args: args, eventManager: eventManager)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    
}
      
class AMPSSelfRenderView : NSObject, FlutterPlatformView {
    
    private static let selfRenderTag = 0xAD5C0DE
    
    
    private weak var eventManager: AMPSEventManager?
    private var iosView: UIView
    private var adId: String?
    private var layoutModel: FlutterUnifiedParam?
    private weak var unifiedAdView: AMPSUnifiedNativeView?
    
    init(frame: CGRect,viewId: Int64,args:Any?, eventManager: AMPSEventManager) {
        self.eventManager = eventManager
        self.iosView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        super.init()
//        self.iosView.backgroundColor = UIColor.orange
        
        if let param = args as? [String: Any?]{
            let model: FlutterUnifiedParam? = Tools.convertToModel(from: param as [String : Any])
            if let adId = model?.adId {
               if let adView = eventManager.nativeManager.getUnifiedNativeView(adId) {
                   self.adId = adId
                   self.layoutModel = model
                   self.unifiedAdView = adView
                   eventManager.nativeManager.refreshUnifiedPresenter(adId: adId)
                   eventManager.nativeManager.selfRenderViews.setObject(self, forKey: adId as NSString)
                   if adView.nativeAd.nativeMode == .nativeExpress {
                       adView.removeFromSuperview()
                       self.iosView.addSubview(adView)
                       return
                   }
                   
                   adView.frame  =  CGRect(x:0, y: 0, width: model?.unifiedWidget?.width ?? UIScreen.main.bounds.width, height: model?.unifiedWidget?.height ?? self.iosView.frame.size.height)
                   if let bgColor = model?.unifiedWidget?.backgroundColor {
                       adView.backgroundColor = UIColor(hexString: bgColor)
                   }
                   adView.removeFromSuperview()
                   self.iosView.addSubview(adView)
                   self.layoutItems(adView,model!)
               }
           }
        }
    }
    func view() -> UIView {
        return iosView
    }
    
    /// 轮播换素材后，同一套 Flutter 布局模型重新填充新的 nativeAd。
    func reloadAd() {
        guard let adView = unifiedAdView ?? (adId.flatMap { eventManager?.nativeManager.getUnifiedNativeView($0) }),
              let model = layoutModel else { return }
        unifiedAdView = adView
        layoutItems(adView, model)
    }
    
    private func clearSelfRenderSubviews(_ adView: AMPSUnifiedNativeView) {
        adView.subviews.filter { $0.tag == AMPSSelfRenderView.selfRenderTag }.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func markSelfRender(_ view: UIView) {
        view.tag = AMPSSelfRenderView.selfRenderTag
    }
    
    func layoutItems(_ adView: AMPSUnifiedNativeView, _ model: FlutterUnifiedParam){
        clearSelfRenderSubviews(adView)
                
        var clickViews: [UIView] = []
        let ad = adView.nativeAd
        
        if ad.nativeMode == .unifiedVideo {
            adView.mediaView?.delegate = eventManager?.nativeManager.unifiedSlot(owning: adView)
            if let videoModel = model.unifiedWidget?.children?.first(where: { child in
                child.type == .video
            }){
                adView.mediaView?.resetLayout(with: CGRect(x: videoModel.x ?? 0, y: videoModel.y ?? 0, width:  videoModel.width ?? adView.frame.width, height: videoModel.height ?? 150))
            }
        } else if let imagesChildModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .imagesChild
        }) {
            // 自渲染多图：遍历 children，每张图用独立 ImageView 展示
            let imageModels = imagesChildModel.children ?? []
            let fallbackUrls = ad.imageUrls.compactMap { $0 as? String }
            for (index, imgModel) in imageModels.enumerated() {
                let contain = fallbackUrls.contains { item  in
                    return item == imgModel.url
                }
                if (!contain){
                    continue
                }
                // 优先使用 Flutter 传入的 url，否则用广告数据兜底
                let urlString = (imgModel.url != nil && !imgModel.url!.isEmpty) ? imgModel.url : (index < fallbackUrls.count ? fallbackUrls[index] : nil)
                
                guard let finalUrl = urlString, !finalUrl.isEmpty else { continue }
                let imageView = UIImageView(frame: CGRect(
                    x: imgModel.x ?? 0,
                    y: imgModel.y ?? 0,
                    width: imgModel.width ?? 100,
                    height: imgModel.height ?? 100
                ))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                if let bgColor = imgModel.backgroundColor {
                    imageView.backgroundColor = UIColor(hexString: bgColor)
                }
                if let _ = URL(string: finalUrl) {
                    Tools.fetchImageData(from: finalUrl) { [weak imageView] result in
                        if case let .success(data) = result {
                            imageView?.image = UIImage(data: data)
                        }
                    }
                }
                markSelfRender(imageView)
                adView.addSubview(imageView)
                if imgModel.clickType == 0 {
                    clickViews.append(imageView)
                }
            }
        } else if !ad.imageUrl.isEmpty {
            let imageUrl = ad.imageUrl
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: adView.frame.size.width, height: 150))
            if let imgModel = model.unifiedWidget?.children?.first(where: { child in
                child.type == .mainImage
            }){
                imageView.frame = CGRect(x: imgModel.x ?? 0, y: imgModel.y ?? 0, width: imgModel.width ??  adView.frame.size.width, height: imgModel.height ?? adView.frame.size.height)
                if let bgColor = imgModel.backgroundColor{
                    imageView.backgroundColor = UIColor(hexString: bgColor)
                }
                if imgModel.clickType == 0 {
                    clickViews.append(imageView)
                }
            }
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            if let _ = URL(string: imageUrl) {
                Tools.fetchImageData(from: imageUrl) { [weak imageView] result in
                    if case let .success(data) = result {
                        imageView?.image = UIImage(data: data)
                    }
                }
            }
            markSelfRender(imageView)
            adView.addSubview(imageView)
                             
        }

        // 设置广告Logo
        let adLogoImageView = UIImageView(frame: CGRect(x: adView.frame.width - 50, y: adView.frame.width - 20, width: 36, height: 14))
        adLogoImageView.contentMode = .scaleAspectFit
        if !ad.adLogoUrl.isEmpty, let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .adSourceLogo
        }){
           adLogoImageView.frame = CGRect(x: imgModel.x ?? adView.frame.width - 50, y: imgModel.y ?? adView.frame.width - 20, width: imgModel.width ?? 36, height: imgModel.height ?? 14)
            let adLogoUrl = ad.adLogoUrl
            if URL(string: adLogoUrl) != nil {
                Tools.fetchImageData(from: adLogoUrl) { [weak adLogoImageView] result in
                    if case let .success(data) = result {
                        adLogoImageView?.image = UIImage(data: data)
                    }
                }
            }
            markSelfRender(adLogoImageView)
            adView.addSubview(adLogoImageView)
            if imgModel.clickType == 0 {
                clickViews.append(adLogoImageView)
            }
            
        }
        
        let iconImageView = UIImageView()
        // 创建图标iconImageView
        if let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .appIcon
        }){
            if  !ad.iconUrl.isEmpty {
                let iconUrl = ad.iconUrl
                iconImageView.frame = CGRectMake(
                    imgModel.x ?? 0,
                    imgModel.y ?? 0,
                    imgModel.width ?? 0,
                    imgModel.height ?? 0
                )
                iconImageView.contentMode = .scaleAspectFit
                if let _ = URL(string: iconUrl) {
                    Tools
                        .fetchImageData(from: iconUrl) { [weak iconImageView] result in
                            if case let .success(data) = result {
                                iconImageView?.image = UIImage(data: data)
                            }
                        }
                }
            }
            markSelfRender(iconImageView)
            adView.addSubview(iconImageView)
            if imgModel.clickType == 0 {
                clickViews.append(iconImageView)
            }
        }

        // 创建标题Label
        let titleLabel = UILabel()
        if !ad.title.isEmpty ,let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .mainTitle
        }){
            titleLabel.text = ad.title
            titleLabel.textColor = .darkGray
            titleLabel.frame = CGRectMake(imgModel.x ?? 0, imgModel.y ?? 0, adView.frame.width - 40, imgModel.height ?? 20)
            if let bgColor = imgModel.backgroundColor {
                titleLabel.backgroundColor = UIColor(hexString: bgColor)
            }
            if let fontSize = imgModel.fontSize {
                titleLabel.font = UIFont.systemFont(ofSize: fontSize)
            }
            if let color = imgModel.color {
                titleLabel.textColor = UIColor(hexString: color)
            }
            markSelfRender(titleLabel)
            adView.addSubview(titleLabel)
            if imgModel.clickType == 0 {
                clickViews.append(titleLabel)
            }
        }
        
        // 创建描述Label
        let descLabel = UILabel()
        if let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .descText
        }){
            descLabel.frame = CGRect(
                x: iconImageView.frame.width + 10,
                y: 0,
                width: adView.frame.width - 85,
                height: 30
            )
            descLabel.text = ad.desc
            descLabel.font = .systemFont(ofSize: 21.0)
            descLabel.textColor = .gray
            
            descLabel.frame = CGRectMake(imgModel.x ?? 0, imgModel.y ?? 0, imgModel.width ?? adView.frame.width - 40, imgModel.height ?? 30)
            print("imageModel:\(imgModel)")
            if let bgColor = imgModel.backgroundColor {
                descLabel.backgroundColor = UIColor(hexString: bgColor)
            }
            if let fontSize = imgModel.fontSize {
                descLabel.font = UIFont.systemFont(ofSize: fontSize)
            }
            if let color = imgModel.color {
                descLabel.textColor = UIColor(hexString: color)
            }
            markSelfRender(descLabel)
            adView.addSubview(descLabel)
            if imgModel.clickType == 0 {
                clickViews.append(descLabel)
            }
        }
        // 操作按钮： actionText，可渲染文字或图片。
        if let buttonModel = model.unifiedWidget?.children?.first(where: { $0.type == .actionButton }),
           !ad.actionText.isEmpty {
            let buttonFrame = CGRect(
                x: buttonModel.x ?? 0,
                y: buttonModel.y ?? 0,
                width: buttonModel.width ?? adView.frame.width - 40,
                height: buttonModel.height ?? 30
            )
            let actionView: UIView
            if ad.actionText.hasPrefix("http") {
                let imageView = UIImageView(frame: buttonFrame)
                imageView.contentMode = .scaleAspectFit
                actionView = imageView
                Tools.fetchImageData(from: ad.actionText) { [weak imageView] result in
                    guard case let .success(data) = result else { return }
                    imageView?.image = UIImage(data: data)
                }
            } else {
                let label = UILabel(frame: buttonFrame)
                label.text = ad.actionText
                label.textAlignment = .center
                if let fontSize = buttonModel.fontSize {
                    label.font = .systemFont(ofSize: fontSize)
                }
                if let fontColor = buttonModel.fontColor {
                    label.textColor = UIColor(hexString: fontColor)
                }
                actionView = label
            }

            if let backgroundColor = buttonModel.backgroundColor {
                actionView.backgroundColor = UIColor(hexString: backgroundColor)
            }
            let cornerRadius: CGFloat
            switch buttonModel.buttonType {
            case "normal":
                cornerRadius = 0
            case "roundedRectangle":
                cornerRadius = 8
            case "circle":
                cornerRadius = min(buttonFrame.width, buttonFrame.height) / 2
            default: // capsule（默认）
                cornerRadius = buttonFrame.height / 2
            }
            actionView.layer.cornerRadius = cornerRadius
            actionView.layer.masksToBounds = cornerRadius > 0

            markSelfRender(actionView)
            adView.addSubview(actionView)
            if buttonModel.clickType == 0 {
                clickViews.append(actionView)
            }
        }
        // 注册可点击视图
        adView.registerClickableViews(clickViews)
    }
    
}
