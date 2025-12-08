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
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AMPSSelfRenderView(frame: frame, viewId: viewId, args: args)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    
}
      
class AMPSSelfRenderView : NSObject, FlutterPlatformView {
    
    private var iosView: UIView
    init(frame: CGRect,viewId: Int64,args:Any?) {
        self.iosView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        super.init()
        self.iosView.backgroundColor = UIColor.orange
        
        if let param = args as? [String: Any?]{
            let model: FlutterUnifiedParam? = Tools.convertToModel(from: param as [String : Any])
            if let adId = model?.adId {
               if let adView = AMPSNativeManager.shared.getUnifiedNativeView(adId) {
                   if adView.nativeAd.nativeMode == .nativeExpress {
                       self.iosView.addSubview(adView)
                       return
                   }
                   self.iosView.frame.size.width = UIScreen.main.bounds.width
                   self.iosView.frame.size.height = model?.unifiedWidget?.height ?? 200
                   let x =  (UIScreen.main.bounds.width - (model?.unifiedWidget?.width ?? 0))/2
                   adView.frame  =  CGRect(x:x, y: 0, width: model?.unifiedWidget?.width ?? UIScreen.main.bounds.width, height: self.iosView.frame.size.height)
                   if let bgColor = model?.unifiedWidget?.backgroundColor {
                       adView.backgroundColor = UIColor(hexString: bgColor)
                   }
                   self.iosView.addSubview(adView)
                   self.layoutItems(adView,model!)
               }
           }
        }
    }
    func view() -> UIView {
        return iosView
    }
    
    
    func layoutItems(_ adView: AMPSUnifiedNativeView, _ model: FlutterUnifiedParam){
                
        var clickViews: [UIView] = []
        let ad = adView.nativeAd
        
        if ad.nativeMode == .unifiedVideo {
            adView.mediaView?.delegate = AMPSNativeManager.shared.unifiedManager
            if let videoModel = model.unifiedWidget?.children?.first(where: { child in
                child.type == .video
            }){
                adView.mediaView?.resetLayout(with: CGRect(x: videoModel.x ?? 0, y: videoModel.y ?? 0, width:  videoModel.width ?? adView.frame.width, height: videoModel.height ?? 150))
            }
        } else if ad.imageUrls.count > 0 {
            for i in 0..<ad.imageUrls.count {
                let width = (adView.frame.width - 10 * CGFloat(ad.imageUrls.count - 1)) / CGFloat(ad.imageUrls.count)
                let imgView = UIImageView(frame: CGRect(
                    x: 10 + CGFloat(i) * width,
                    y: 10,
                    width: width,
                    height: 150
                ))
                imgView.contentMode = .scaleAspectFit
                if let urlString = ad.imageUrls[i] as? String, let _ = URL(string: urlString) {
                    Tools.fetchImageData(from: urlString) { [weak imgView] result in
                        if case let .success(data) = result {
                            imgView?.image = UIImage(data: data)
                        }
                    }
                   
                }
                adView.addSubview(imgView)
                clickViews.append(imgView)
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
                
            }
            imageView.contentMode = .scaleAspectFit
            if let _ = URL(string: imageUrl) {
                Tools.fetchImageData(from: imageUrl) { [weak imageView] result in
                    if case let .success(data) = result {
                        imageView?.image = UIImage(data: data)
                    }
                }
            }
            
            adView.addSubview(imageView)
            clickViews.append(imageView)
                             
        }

        // 设置广告Logo
        let adLogoImageView = UIImageView(frame: CGRect(x: adView.frame.width - 50, y: adView.frame.width - 20, width: 36, height: 14))
        adLogoImageView.contentMode = .scaleAspectFit
        if let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .adSourceLogo
        }){
           adLogoImageView.frame = CGRect(x: imgModel.x ?? adView.frame.width - 50, y: imgModel.y ?? adView.frame.width - 20, width: imgModel.width ?? 36, height: imgModel.height ?? 14)
        }
        if  !ad.adLogoUrl.isEmpty {
            let adLogoUrl = ad.adLogoUrl
            if URL(string: adLogoUrl) != nil {
                Tools.fetchImageData(from: adLogoUrl) { [weak adLogoImageView] result in
                    if case let .success(data) = result {
                        adLogoImageView?.image = UIImage(data: data)
                    }
                }
            }
        }

        // 创建图标iconImageView
        let iconImageView = UIImageView()
        if  !ad.iconUrl.isEmpty {
            let iconUrl = ad.iconUrl
            iconImageView.frame = CGRect(x: 5, y: 165, width: 65, height: 65)
            iconImageView.contentMode = .scaleAspectFit
            if let _ = URL(string: iconUrl) {
                Tools.fetchImageData(from: iconUrl) { [weak iconImageView] result in
                    if case let .success(data) = result {
                        iconImageView?.image = UIImage(data: data)
                    }
                }
            }
        }
        if let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .appIcon
        }){
            iconImageView.frame = CGRectMake(imgModel.x ?? 0, imgModel.y ?? 0, imgModel.width ?? 0, imgModel.height ?? 0)
        }

        // 创建标题Label
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(
            x: iconImageView.frame.width + 10,
            y: 165,
            width: adView.frame.width - 85,
            height: 30
        )
        titleLabel.text = ad.title
        titleLabel.textColor = .darkGray
        if let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .mainTitle
        }){
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
        }
        
        // 创建描述Label
        let descLabel = UILabel()
        descLabel.frame = CGRect(
            x: iconImageView.frame.width + 10,
            y: 200,
            width: adView.frame.width - 85,
            height: 30
        )
        descLabel.text = ad.desc
        descLabel.font = .systemFont(ofSize: 21.0)
        descLabel.textColor = .gray
        
        if let imgModel = model.unifiedWidget?.children?.first(where: { child in
            child.type == .descText
        }){
            descLabel.frame = CGRectMake(imgModel.x ?? 0, imgModel.y ?? 0, imgModel.width ?? adView.frame.width - 40, imgModel.height ?? 30)
            if let bgColor = imgModel.backgroundColor {
                descLabel.backgroundColor = UIColor(hexString: bgColor)
            }
            if let fontSize = imgModel.fontSize {
                descLabel.font = UIFont.systemFont(ofSize: fontSize)
            }
            if let color = imgModel.color {
                descLabel.textColor = UIColor(hexString: color)
            }
        }
        // 添加子视图
        adView.addSubview(adLogoImageView)
        adView.addSubview(iconImageView)
        adView.addSubview(titleLabel)
        adView.addSubview(descLabel)
       
        
        clickViews.append(contentsOf: [iconImageView,titleLabel,descLabel])
        // 注册可点击视图
        adView.registerClickableViews(clickViews)
    }
    
}
