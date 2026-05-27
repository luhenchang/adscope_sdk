//
//  AMPSDrawView.swift
//  adscope_sdk
//
//  Created by dzq_bookPro on 2025/12/11.
//

import Foundation
import Flutter

class AMPSDrawViewFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AMPSDrawView(frame: frame, viewId: viewId, args: args)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AMPSDrawView: NSObject, FlutterPlatformView {
    
    private let iosView: IOSDrawView
    
    init(frame: CGRect, viewId: Int64, args: Any?) {
        self.iosView = IOSDrawView(frame: frame)
        super.init()
        
        guard let param = args as? [String: Any?],
              let adId = param["adId"] as? String,
              let adView = AMPSDrawManager.shared.getAdView(adId: adId) else { return }
        
        iosView.adId = adId
        iosView.adInstanceId = param[ArgumentKeys.adInstanceId] as? String
        iosView.clipsToBounds = true
        if adView.superview !== iosView {
            adView.removeFromSuperview()
            iosView.adView = adView   // 直接持有引用，不再依赖 tag
            iosView.addSubview(adView)
        }
    }
    
    func view() -> UIView {
        return iosView
    }
}

class IOSDrawView: UIView {
    
    weak var adView: UIView?   // 弱引用，避免循环持有（adView 已被外部管理器持有）
    var adId: String?
    var adInstanceId: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let adView = adView,
              !adView.bounds.isEmpty else { return }
        
        let targetFrame = CGRect(
            x: (bounds.width  - adView.bounds.width)  / 2,
            y: (bounds.height - adView.bounds.height) / 2,
            width:  adView.bounds.width,
            height: adView.bounds.height
        )
        
        guard adView.frame != targetFrame else { return }
        
        adView.frame = targetFrame
        
        AMPSEventManager.shared.sendToFlutter(
            AmpsDrawCallbackChannelMethod.drawSizeUpdate,
            arg: [
                "adId":   adId ?? "",
                ArgumentKeys.adInstanceId: adInstanceId ?? "",
                "width":  targetFrame.width,
                "height": targetFrame.height
            ]
        )
    }
}
