//
//  AMPSPlatformViewRegistry.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/29.
//

import Foundation
import Flutter

class AMPSPlatformViewRegistry {
    
    
    static let shared: AMPSPlatformViewRegistry = .init()
    private init() {}
    
    
    func regist(_ binding: FlutterPluginRegistrar){
        
        binding.register(AMPSNAtiveViewFactory(), withId: AMPSPlatformViewIds.nativeViewId)
        
        binding.register(AMPSUnifiedNAtiveViewFactory(), withId: AMPSPlatformViewIds.unifiedViewId)
        
        binding.register(AMPSBannerViewFactory(), withId: AMPSPlatformViewIds.bannerViewId)
        
        binding.register(AMPSDrawViewFactory(), withId: AMPSPlatformViewIds.drawViewId)
        
    }
    
    
    
}
