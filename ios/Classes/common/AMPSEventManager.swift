import Foundation
import Flutter
import UIKit

/// One event channel and one set of ad stores per FlutterEngine registration.
final class AMPSEventManager: NSObject {
    private var channel: FlutterMethodChannel?
    private var messenger: FlutterBinaryMessenger?
    private(set) var isActive = false

    lazy var initManager = AMPSSDKInitManager(eventManager: self)
    lazy var splashManager = AMPSSplashManager(eventManager: self)
    lazy var interstitialManager = AMPSInterstitialManager(eventManager: self)
    lazy var nativeManager = AMPSNativeManager(eventManager: self)
    lazy var rewardManager = AMPSRewardVideoManager(eventManager: self)
    lazy var bannerManager = AMPSBannerManager(eventManager: self)
    lazy var drawManager = AMPSDrawManager(eventManager: self)

    func regist(_ registrar: FlutterPluginRegistrar) {
        messenger = registrar.messenger()
        isActive = true
        let channel = FlutterMethodChannel(name: "adscope_sdk", binaryMessenger: registrar.messenger())
        self.channel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self, self.isActive else {
                result(FlutterError(code: "ENGINE_DETACHED", message: "Flutter engine is detached", details: nil))
                return
            }
            switch call.method {
            case let name where initMethodNames.contains(name):
                self.initManager.handleMethodCall(call, result: result)
            case let name where splashMethodNames.contains(name):
                self.splashManager.handleMethodCall(call, result: result)
            case let name where interstitialMethodNames.contains(name):
                self.interstitialManager.handleMethodCall(call, result: result)
            case let name where nativeMethodNames.contains(name):
                self.nativeManager.handleMethodCall(call, result: result)
            case let name where rewardVideoMethodNames.contains(name):
                self.rewardManager.handleMethodCall(call, result: result)
            case let name where bannerMethodNames.contains(name):
                self.bannerManager.handleMethodCall(call, result: result)
            case let name where drawMethodNames.contains(name):
                self.drawManager.handleMethodCall(call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func sendToFlutter(_ method: String, arg: Any? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.isActive else { return }
            self.channel?.invokeMethod(method, arguments: arg)
        }
    }

    func release() {
        // Invalidate first: native remove() may synchronously trigger a delegate callback.
        isActive = false
        channel?.setMethodCallHandler(nil)
        channel = nil
        messenger = nil
        initManager.release()
        splashManager.release()
        interstitialManager.release()
        nativeManager.release()
        rewardManager.release()
        bannerManager.release()
        drawManager.release()
    }

    /// Write the owning page only when it is currently attached. A nil lookup keeps the previous controller.
    func bindPresenter(_ apply: (UIViewController) -> Void) {
        guard let controller = viewController else { return }
        apply(controller)
    }

    /// Find the view controller belonging to this messenger, including pages below the top page.
    /// A headless engine has no presenter; never borrow another engine's page.
    var viewController: UIViewController? {
        guard isActive, let messenger = messenger else { return nil }
        let identity = ObjectIdentifier(messenger)
        func find(in controller: UIViewController) -> UIViewController? {
            if let flutter = controller as? FlutterViewController,
               ObjectIdentifier(flutter.binaryMessenger) == identity { return flutter }
            if let presented = controller.presentedViewController, let found = find(in: presented) { return found }
            let children = (controller as? UINavigationController)?.viewControllers
                ?? (controller as? UITabBarController)?.viewControllers ?? controller.children
            for child in children {
                if let found = find(in: child) { return found }
            }
            return nil
        }
        let windows: [UIWindow]
        if #available(iOS 13.0, *) {
            windows = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }
                + UIApplication.shared.windows
        } else {
            windows = UIApplication.shared.windows
        }
        for window in windows {
            if let root = window.rootViewController, let found = find(in: root) { return found }
        }
        return nil
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
