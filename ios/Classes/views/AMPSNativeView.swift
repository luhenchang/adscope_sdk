
//
//  AMPSNativeView.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/24.
//

import Foundation
import Flutter


class AMPSNAtiveViewFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> any FlutterPlatformView {
        return AMPSNativeView(frame: frame, viewId: viewId, args: args)
    }
    
    func createArgsCodec() -> any FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    
}

class AMPSNativeView : NSObject, FlutterPlatformView {
    
    private var iosView: IOSView
    var args: Any?
    init(frame: CGRect,viewId: Int64,args:Any?) {
        self.iosView = IOSView(frame: frame)
//        self.iosView.backgroundColor = UIColor.orange
        self.args = args
        
        
    }
    func view() -> UIView {
        if let param = args as? [String: Any?]{
           if let adId = param["adId"] as? String {
               if let adView = AMPSNativeManager.shared.getAdView(adId: adId) {
                   iosView.adId = adId
                   self.iosView.clipsToBounds = true
                   self.iosView.addSubview(adView)
                   adView.tag = 10011
                   
                   
               }
           }
        }
        return iosView
    }
}




class IOSView: UIView {
    // 1. 记录上次的广告视图布局参数（位置+尺寸），初始值设为无效值
    private var lastAdFrame: CGRect = .zero
    var adId: String?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let adView = self.viewWithTag(10011) else { return }
        
        // 2. 计算目标布局（居中）
        let targetX = (self.bounds.width - adView.bounds.width) / 2
        let targetY = (self.bounds.height - adView.bounds.height) / 2
        let targetFrame = CGRect(
            x: targetX,
            y: targetY,
            width: adView.bounds.width,
            height: adView.bounds.height
        )
        
        // 3. 仅当目标布局与当前布局/上次记录的布局不一致时，才更新+发回调
        if adView.frame != targetFrame || lastAdFrame != targetFrame {
            // 更新广告视图布局
            adView.frame = targetFrame
            // 记录本次布局，用于下次对比
            lastAdFrame = targetFrame
            // 发送回调到Flutter
            AMPSEventManager.shared.sendToFlutter(
                AMPSNativeCallBackChannelMethod.nativeSizeUpdate,
                arg: [
                    "adId": adId ?? "",
                    "width": adView.frame.size.width,
                    "height": adView.frame.size.height
                ]
            )
            
        }
    }
}

