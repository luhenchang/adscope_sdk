//
//  AMPSBannerView.swift
//  adscope_sdk
//
//  Created by dzq_bookPro on 2025/12/10.
//

import Foundation
import Flutter


class AMPSBannerViewFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AMPSBannerView(frame: frame, viewId: viewId, args: args)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AMPSBannerView: NSObject, FlutterPlatformView {
    
    private let iosView: IOSBannerView
    
    init(frame: CGRect, viewId: Int64, args: Any?) {
        self.iosView = IOSBannerView(frame: frame)
        super.init()
        
        let argsMap = args as? [String: Any]
        let instanceId = argsMap?[ArgumentKeys.adInstanceId] as? String
        guard let adView = AMPSBannerManager.shared.getBannerView(instanceId: instanceId) else { return }
        
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

class IOSBannerView: UIView {
    
    weak var adView: UIView?   // 弱引用，避免循环持有（adView 已被外部管理器持有）
    
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
    }
}
