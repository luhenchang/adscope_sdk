//
//  AMPSEventManager.swift
//  amps_sdk
//
//  Created by 王飞 on 2025/10/21.
//

import Foundation
import Flutter


class AMPSEventManager : NSObject{
   
    static let shared = AMPSEventManager()
    private override init(){super.init()}
    
    var channel: FlutterMethodChannel?
    var registrar: FlutterPluginRegistrar?
    func regist(_ registrar: FlutterPluginRegistrar?) {
        guard let registrar = registrar else {
            return
        }
        self.registrar = registrar
        channel = FlutterMethodChannel(name: "adscope_sdk", binaryMessenger:  registrar.messenger())
        channel?.setMethodCallHandler { methodCall, result in
            switch methodCall.method {
            case let name where  initMethodNames.contains(name):
                AMPSSDKInitManager.shared.handleMethodCall(methodCall, result: result)
            case let name where splashMethodNames.contains(name):
                AMPSSplashManager.shared.handleMethodCall(methodCall, result:result)
            case let name where interstitialMethodNames.contains(name):
                AMPSInterstitialManager.shared.handleMethodCall(methodCall, result: result)
            case let name where  nativeMethodNames.contains(name):
                AMPSNativeManager.shared.handleMethodCall(methodCall, result: result)
            case let name where  rewardVideoMethodNames.contains(name):
                AMPSRewardVideoManager.shared.handleMethodCall(methodCall, result: result)
            case let name where  bannerMethodNames.contains(name):
                AMPSBannerManager.shared.handleMethodCall(methodCall, result: result)
            case let name where  drawMethodNames.contains(name):
                AMPSDrawManager.shared.handleMethodCall(methodCall, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
    }
    func sendToFlutter(_ method:String,arg:Any? = nil){
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod(method, arguments: arg)
        }
    }
    
    func getImage(_ name:String) -> UIImage?  {
        let imageName = name.components(separatedBy: "/").last
        let source = imageName?.components(separatedBy: ".").first
        let type = imageName?.components(separatedBy: ".").last ?? "png"
        
        let tem = "flutter_assets/" + name
        var arr1 = tem.components(separatedBy: "/")
        arr1.removeLast()
        let dir = arr1.joined(separator: "/")
        
        guard let frameworkPath = Bundle.main.path(forResource: "App", ofType: "framework", inDirectory: "Frameworks"),
              let bundle = Bundle(path: frameworkPath) else {
            return nil
        }
        
        // 根据屏幕 scale 优先选择对应分辨率的变体目录，不存在时回退到低分辨率
        let scale = UIScreen.main.scale
        let variants: [String]
        if scale >= 3 {
            variants = ["3.0x", "2.0x", ""]
        } else if scale >= 2 {
            variants = ["2.0x", ""]
        } else {
            variants = [""]
        }
        for variant in variants {
            let variantDir = variant.isEmpty ? dir : dir + "/" + variant
            if let imagePath = bundle.path(forResource: source, ofType: type, inDirectory: variantDir),
               let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
        }
        return nil
    }
}
