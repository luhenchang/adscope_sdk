//
//  AdOptionModule.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import AMPSAdSDK
import AdScopeFoundation
struct AdOptionModule{
    
    static func getAdConfig(para:[String:Any?]) -> AMPSAdConfiguration{
        let config = AMPSAdConfiguration()
        config.adCount = para[AdOptionKeys.keyAdCount] as? Int ?? 1
        config.spaceId = para[AdOptionKeys.keySpaceId] as? String ?? ""
        let size = para[AdOptionKeys.keyExpressSize] as? [CGFloat]
        if size?.count ?? 0 > 0 && size![0] > 0{
            config.adSize.width = size![0]
        }
        if size?.count ?? 0 > 1 && size![1] > 0{
            config.adSize.height = size![1]
        }
        if let s2s = para[AdOptionKeys.keyS2SImpl] as? String{
            config.s2sIp = s2s
        }
        
        if let userId = para[AdOptionKeys.keyUserId] as? String {
            config.userID = userId
        }
        if let extra = para[AdOptionKeys.keyExtra] as? String {
            config.extra = extra
        }
//        if let ip = para[AdOptionKeys.keyIpAddress] as? String {
//
//        }
        if let timeout = para[AdOptionKeys.keyTimeoutInterval] as? TimeInterval {
            config.timeoutInterval = timeout
        }
        if let customExtra = para[AdOptionKeys.keyCustomExtraParameters] as? [String: Any]{
            config.customExtraDict = customExtra
        }else if let customExtra = para[AdOptionKeys.keyExtraDataMap] as? [String: Any]{
            config.customExtraDict = customExtra
        }
        return config
    }

}
