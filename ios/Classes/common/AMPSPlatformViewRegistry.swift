//
//  AMPSPlatformViewRegistry.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/29.
//

import Foundation
import Flutter

class AMPSPlatformViewRegistry {
    
    
    init() {}
    
    
    func regist(_ binding: FlutterPluginRegistrar?, eventManager: AMPSEventManager){
        guard let binding = binding else {
            return
        }
        
        binding.register(AMPSNAtiveViewFactory(eventManager: eventManager), withId: AMPSPlatformViewIds.nativeViewId)
        
        binding.register(AMPSUnifiedNAtiveViewFactory(eventManager: eventManager), withId: AMPSPlatformViewIds.unifiedViewId)
        
        binding.register(AMPSBannerViewFactory(eventManager: eventManager), withId: AMPSPlatformViewIds.bannerViewId)
        
        binding.register(AMPSDrawViewFactory(eventManager: eventManager), withId: AMPSPlatformViewIds.drawViewId)
        
    }
    
    
    
}
