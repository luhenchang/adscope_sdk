// Test host fixture. run.sh temporarily uses this instead of Runner/AppDelegate.swift.
import Flutter
import UIKit

private func probeLog(_ message: String) {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("multi_engine_probe.log")
    if !FileManager.default.fileExists(atPath: url.path) {
        FileManager.default.createFile(atPath: url.path, contents: nil)
    }
    if let handle = try? FileHandle(forWritingTo: url) {
        handle.seekToEndOfFile()
        handle.write(("\(Date()) \(message)\n").data(using: .utf8)!)
        handle.closeFile()
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var bridgeA: FlutterMethodChannel?
    private var bridgeB: FlutterMethodChannel?
    private var engineB: FlutterEngine?
    private var pageB: FlutterViewController?
    private var navigation: UINavigationController?
    private var expectedEngine = "A"
    private var startedB = false
    private var requestedA = false
    private var closedB = false
    private var completed = false
    private var foreignCallback = false
    private var outcomes = [String: String]()

    override func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("multi_engine_probe.log")
        try? Data().write(to: url)
        GeneratedPluginRegistrant.register(with: self)
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        guard let pageA = window?.rootViewController as? FlutterViewController else { return result }
        bridgeA = makeBridge(messenger: pageA.binaryMessenger)
        let nav = UINavigationController(rootViewController: pageA)
        nav.setNavigationBarHidden(true, animated: false)
        navigation = nav
        window?.rootViewController = nav
        probeLog("ENGINE_A \(ObjectIdentifier(pageA.engine))")
        return result
    }

    private func makeBridge(messenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
        let channel = FlutterMethodChannel(name: "adscope_multi_engine_probe", binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            if call.method == "event", let data = call.arguments as? [String: Any] { self?.onEvent(data) }
            result(nil)
        }
        return channel
    }

    private func onEvent(_ data: [String: Any]) {
        probeLog("EVENT \(data)")
        let engine = data["engine"] as? String ?? ""
        let event = data["event"] as? String ?? ""
        let phase = data["phase"] as? String ?? ""
        let method = data["method"] as? String ?? ""
        if event == "sdkEvent", ["loadOk", "loadFail", "renderSuccess", "renderFailed"].contains(method), engine != expectedEngine {
            foreignCallback = true
            probeLog("FAIL_WRONG_ENGINE expected=\(expectedEngine) received=\(engine)")
        }
        let terminal = event == "loadFail" || event == "renderFail" || event == "renderOk"
        if terminal { outcomes["\(engine)_\(phase)"] = event }
        if engine == "A", phase == "initial", terminal, !startedB {
            startedB = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.openB() }
        }
        if engine == "B", phase == "initial", terminal, !requestedA {
            requestedA = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.expectedEngine = "A"
                self.bridgeA?.invokeMethod("load", arguments: "with_B")
            }
        }
        if engine == "A", phase == "with_B", terminal, !closedB {
            closedB = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.closeB() }
        }
        if engine == "A", phase == "after_B_detach", terminal, !completed {
            completed = true
            probeLog(foreignCallback ? "CALLBACK_ROUTING_FAIL" : "CALLBACK_ROUTING_PASS")
            let renderedAll = outcomes.count == 4 && outcomes.values.allSatisfy { $0 == "renderOk" }
            probeLog(renderedAll ? "RENDER_PASS" : "RENDER_INCOMPLETE \(outcomes)")
        }
    }

    private func openB() {
        expectedEngine = "B"
        let engine = FlutterEngine(name: "page_B_independent", project: nil, allowHeadlessExecution: true)
        engineB = engine
        engine.run(withEntrypoint: nil, initialRoute: "/B")
        bridgeB = makeBridge(messenger: engine.binaryMessenger)
        GeneratedPluginRegistrant.register(with: engine)
        let page = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        pageB = page
        navigation?.pushViewController(page, animated: false)
        probeLog("ENGINE_B \(ObjectIdentifier(engine))")
    }

    private func closeB() {
        bridgeB?.invokeMethod("disposeAds", arguments: nil) { _ in
            self.navigation?.popViewController(animated: false)
            self.pageB = nil
            self.engineB?.viewController = nil
            self.bridgeB?.setMethodCallHandler(nil)
            self.bridgeB = nil
            self.engineB?.destroyContext()
            self.engineB = nil
            probeLog("ENGINE_B_DESTROYED; A must remain functional")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.bridgeA?.invokeMethod("load", arguments: "after_B_detach")
            }
        }
    }
}
