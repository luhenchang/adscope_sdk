import Flutter
import UIKit
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let labChannelName = "adscope_example_multi_engine"
    private var labChannelA: FlutterMethodChannel?
    private var labChannelB: FlutterMethodChannel?
    private var labEngineB: FlutterEngine?
    private var labPageB: FlutterViewController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let launched = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        if let controller = flutterController() {
            labChannelA = installLabChannel(messenger: controller.binaryMessenger, engine: "A")
        }
        return launched
    }

    private func flutterController() -> FlutterViewController? {
        let root = window?.rootViewController
        if let controller = root as? FlutterViewController {
            return controller
        }
        if let navigation = root as? UINavigationController {
            return navigation.viewControllers.first as? FlutterViewController
        }
        return nil
    }

    private func installLabChannel(messenger: FlutterBinaryMessenger, engine: String) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(name: labChannelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(nil)
                return
            }
            switch call.method {
            case "openEngineB":
                if engine != "A" || self.labEngineB != nil {
                    result(false)
                } else {
                    self.openEngineB()
                    result(true)
                }
            case "closeEngineB":
                self.closeEngineB()
                result(true)
            case "publish":
                let peer = engine == "A" ? self.labChannelB : self.labChannelA
                peer?.invokeMethod("peer", arguments: call.arguments)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        return channel
    }

    private func openEngineB() {
        guard let presenter = flutterController() else { return }
        let engine = FlutterEngine(name: "example_engine_b", project: nil, allowHeadlessExecution: false)
        labEngineB = engine
        engine.run(withEntrypoint: nil, initialRoute: "/engine-b")
        GeneratedPluginRegistrant.register(with: engine)
        labChannelB = installLabChannel(messenger: engine.binaryMessenger, engine: "B")
        let page = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        page.modalPresentationStyle = .fullScreen
        labPageB = page
        presenter.present(page, animated: true)
        labChannelA?.invokeMethod("peerState", arguments: ["opened": true])
    }

    private func closeEngineB() {
        let page = labPageB
        labPageB = nil
        let finish = {
            self.labChannelB?.setMethodCallHandler(nil)
            self.labChannelB = nil
            self.labEngineB?.viewController = nil
            self.labEngineB?.destroyContext()
            self.labEngineB = nil
            self.labChannelA?.invokeMethod("peerState", arguments: ["opened": false])
        }
        if let page = page, page.presentingViewController != nil {
            page.dismiss(animated: true, completion: finish)
        } else {
            finish()
        }
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { state in
                    
            }
        }
                
        
    }
}
