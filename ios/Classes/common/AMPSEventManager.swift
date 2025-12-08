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
    func regist(_ registrar: FlutterPluginRegistrar) {
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
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
    }
    func sendToFlutter(_ method:String,arg:Any? = nil){
        
        channel?.invokeMethod(method, arguments: arg)
    }
    
    func getImage(_ name:String) -> UIImage?  {
        let imageName = name.components(separatedBy: "/").last
        let source = imageName?.components(separatedBy: ".").first
        let type = imageName?.components(separatedBy: ".").last ?? "png"
        
        let tem = "flutter_assets/" + name
        var arr1 = tem.components(separatedBy: "/")
        arr1.removeLast()
        let dir = arr1.joined(separator: "/")
        
        
        if let frameworkPath = Bundle.main.path(forResource: "App", ofType: "framework", inDirectory: "Frameworks"),
           let imagePath = Bundle(path: frameworkPath)?.path(forResource: source, ofType: type, inDirectory: dir) { // 从路径加载图片
            if let image = UIImage(contentsOfFile: imagePath) {
                return image
            }
        }
        return nil
    }
}
