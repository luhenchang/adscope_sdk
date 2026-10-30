import Flutter
import UIKit
import XCTest
@testable import adscope_sdk

/// Exercise the production channel owners without depending on ad inventory or network timing.
final class RunnerTests: XCTestCase {
  func testRegistrationsOwnDifferentChannelsAndAdManagers() throws {
    let a = ProbeRegistrar()
    let b = ProbeRegistrar()
    AdscopeSdkPlugin.register(with: a)
    AdscopeSdkPlugin.register(with: b)
    let pluginA = try XCTUnwrap(a.published as? AdscopeSdkPlugin)
    let pluginB = try XCTUnwrap(b.published as? AdscopeSdkPlugin)
    XCTAssertFalse(pluginA.events === pluginB.events)
    XCTAssertFalse(pluginA.events.nativeManager === pluginB.events.nativeManager)
    XCTAssertFalse(pluginA.events.bannerManager === pluginB.events.bannerManager)
    XCTAssertFalse(pluginA.events.drawManager === pluginB.events.drawManager)
    XCTAssertFalse(pluginA.events.splashManager === pluginB.events.splashManager)
    XCTAssertFalse(pluginA.events.interstitialManager === pluginB.events.interstitialManager)
    XCTAssertFalse(pluginA.events.rewardManager === pluginB.events.rewardManager)
    XCTAssertEqual(a.factories.count, 4)
    XCTAssertEqual(b.factories.count, 4)
    pluginA.detachFromEngine(for: a)
    pluginB.detachFromEngine(for: b)
  }

  func testSameDartInstanceIdCallbacksStayOnTheirOriginMessenger() throws {
    let a = ProbeRegistrar()
    let b = ProbeRegistrar()
    AdscopeSdkPlugin.register(with: a)
    AdscopeSdkPlugin.register(with: b)
    let pluginA = try XCTUnwrap(a.published as? AdscopeSdkPlugin)
    let pluginB = try XCTUnwrap(b.published as? AdscopeSdkPlugin)
    pluginA.events.sendToFlutter("loadOk", arg: ["adInstanceId": "same", "source": "A"])
    pluginB.events.sendToFlutter("loadOk", arg: ["adInstanceId": "same", "source": "B"])
    drainMainQueue()
    XCTAssertEqual(a.messengerObject.outgoing.count, 1)
    XCTAssertEqual(b.messengerObject.outgoing.count, 1)
    XCTAssertEqual((a.messengerObject.outgoing.first?.arguments as? [String: String])?["source"], "A")
    XCTAssertEqual((b.messengerObject.outgoing.first?.arguments as? [String: String])?["source"], "B")
    pluginA.detachFromEngine(for: a)
    pluginB.detachFromEngine(for: b)
  }

  func testDetachingOneEngineDropsQueuedAndLateCallbacksOnlyForThatEngine() throws {
    let a = ProbeRegistrar()
    let b = ProbeRegistrar()
    AdscopeSdkPlugin.register(with: a)
    AdscopeSdkPlugin.register(with: b)
    let pluginA = try XCTUnwrap(a.published as? AdscopeSdkPlugin)
    let pluginB = try XCTUnwrap(b.published as? AdscopeSdkPlugin)
    pluginB.events.sendToFlutter("queuedBeforeDetach")
    pluginB.detachFromEngine(for: b)
    pluginB.events.sendToFlutter("lateAfterDetach")
    pluginA.events.sendToFlutter("stillAlive")
    drainMainQueue()
    XCTAssertEqual(a.messengerObject.outgoing.map { $0.method }, ["stillAlive"])
    XCTAssertTrue(b.messengerObject.outgoing.isEmpty)
    XCTAssertNotNil(a.messengerObject.handlers["adscope_sdk"])
    XCTAssertNil(b.messengerObject.handlers["adscope_sdk"])
    XCTAssertTrue(pluginA.events.isActive)
    XCTAssertFalse(pluginB.events.isActive)
    pluginB.detachFromEngine(for: b) // A repeated detach is harmless.
    pluginA.detachFromEngine(for: a)
  }

  func testPresenterMatchesOwningEngineEvenBelowAnotherPage() throws {
    let engineA = FlutterEngine(name: "presenter_A")
    let engineB = FlutterEngine(name: "presenter_B")
    XCTAssertTrue(engineA.run())
    XCTAssertTrue(engineB.run())
    let registrarA = try XCTUnwrap(engineA.registrar(forPlugin: "AdscopeSdkPlugin"))
    let registrarB = try XCTUnwrap(engineB.registrar(forPlugin: "AdscopeSdkPlugin"))
    AdscopeSdkPlugin.register(with: registrarA)
    AdscopeSdkPlugin.register(with: registrarB)
    let pluginA = try XCTUnwrap(engineA.valuePublished(byPlugin: "AdscopeSdkPlugin") as? AdscopeSdkPlugin)
    let pluginB = try XCTUnwrap(engineB.valuePublished(byPlugin: "AdscopeSdkPlugin") as? AdscopeSdkPlugin)
    let pageA = FlutterViewController(engine: engineA, nibName: nil, bundle: nil)
    let pageB = FlutterViewController(engine: engineB, nibName: nil, bundle: nil)
    let previousWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
    let window = UIWindow(frame: UIScreen.main.bounds)
    let navigation = UINavigationController(rootViewController: pageA)
    navigation.setViewControllers([pageA, pageB], animated: false)
    window.rootViewController = navigation
    window.makeKeyAndVisible()
    defer {
      pluginA.detachFromEngine(for: registrarA)
      pluginB.detachFromEngine(for: registrarB)
      window.isHidden = true
      window.rootViewController = nil
      engineA.viewController = nil
      engineB.viewController = nil
      engineA.destroyContext()
      engineB.destroyContext()
      previousWindow?.makeKeyAndVisible()
    }
    XCTAssertTrue(pluginA.events.viewController === pageA)
    XCTAssertTrue(pluginB.events.viewController === pageB)
  }

  func testPublishedOwnerIsDetachedWhenRealEngineIsDestroyed() throws {
    var owner: AMPSEventManager?
    autoreleasepool {
      var engine: FlutterEngine? = FlutterEngine(name: "detach_lifecycle")
      XCTAssertTrue(engine!.run())
      let registrar = engine!.registrar(forPlugin: "AdscopeSdkPlugin")!
      AdscopeSdkPlugin.register(with: registrar)
      owner = (engine!.valuePublished(byPlugin: "AdscopeSdkPlugin") as? AdscopeSdkPlugin)?.events
      XCTAssertEqual(owner?.isActive, true)
      engine?.destroyContext()
      engine = nil
    }
    drainMainQueue()
    XCTAssertEqual(owner?.isActive, false)
  }

  private func drainMainQueue() {
    let drained = expectation(description: "queued channel sends completed")
    DispatchQueue.main.async { drained.fulfill() }
    wait(for: [drained], timeout: 2)
  }
}

private final class ProbeMessenger: NSObject, FlutterBinaryMessenger {
  var handlers = [String: FlutterBinaryMessageHandler]()
  var outgoing = [FlutterMethodCall]()
  private var connection: Int64 = 0
  private var connections = [Int64: String]()
  private var activeConnections = [String: Int64]()

  func send(onChannel channel: String, message: Data?) {
    send(onChannel: channel, message: message, binaryReply: nil)
  }
  func send(onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply?) {
    if channel == "adscope_sdk", let message = message {
      outgoing.append(FlutterStandardMethodCodec.sharedInstance().decodeMethodCall(message))
    }
    callback?(FlutterStandardMethodCodec.sharedInstance().encodeSuccessEnvelope(nil))
  }
  func setMessageHandlerOnChannel(_ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler?) -> FlutterBinaryMessengerConnection {
    handlers[channel] = handler
    connection += 1
    connections[connection] = channel
    activeConnections[channel] = connection
    return connection
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {
    guard let channel = connections.removeValue(forKey: connection), activeConnections[channel] == connection else { return }
    handlers.removeValue(forKey: channel)
    activeConnections.removeValue(forKey: channel)
  }
}

private final class ProbeTextures: NSObject, FlutterTextureRegistry {
  func register(_ texture: FlutterTexture) -> Int64 { 1 }
  func textureFrameAvailable(_ textureId: Int64) {}
  func unregisterTexture(_ textureId: Int64) {}
}

private final class ProbeRegistrar: NSObject, FlutterPluginRegistrar {
  let messengerObject = ProbeMessenger()
  let textureObject = ProbeTextures()
  var published: NSObject?
  var factories = [String: FlutterPlatformViewFactory]()
  func messenger() -> FlutterBinaryMessenger { messengerObject }
  func textures() -> FlutterTextureRegistry { textureObject }
  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String) { factories[factoryId] = factory }
  func register(_ factory: FlutterPlatformViewFactory, withId factoryId: String, gestureRecognizersBlockingPolicy: FlutterPlatformViewGestureRecognizersBlockingPolicy) { factories[factoryId] = factory }
  func publish(_ value: NSObject) { published = value }
  func addMethodCallDelegate(_ delegate: FlutterPlugin, channel: FlutterMethodChannel) {}
  func addApplicationDelegate(_ delegate: FlutterPlugin) {}
  func lookupKey(forAsset asset: String) -> String { asset }
  func lookupKey(forAsset asset: String, fromPackage package: String) -> String { "packages/\(package)/\(asset)" }
}

final class InitializationCoordinatorTests: XCTestCase {
  func testNextEngineJoinsTheInFlightInitializationAfterTheLastWaiterDetaches() {
    let coordinator = AMPSInitializationCoordinator()
    var starts = 0
    var finish: ((Int) -> Void)?
    var first = [Int]()
    var second = [Int]()
    let firstId = UUID()
    coordinator.initialize(requester: firstId, currentStatus: { 0 }, start: { callback in
      starts += 1
      finish = callback
    }) { first.append($0) }
    coordinator.cancel(requester: firstId)
    coordinator.initialize(requester: UUID(), currentStatus: { 0 }, start: { _ in
      starts += 1
    }) { second.append($0) }
    XCTAssertEqual(starts, 1)
    finish?(2)
    XCTAssertEqual(first, [])
    XCTAssertEqual(second, [1, 2])
  }

  func testCompletedInitializationIgnoresThePreviousCallback() {
    let coordinator = AMPSInitializationCoordinator()
    let id = UUID()
    var oldFinish: ((Int) -> Void)?
    var newFinish: ((Int) -> Void)?
    var results = [Int]()
    coordinator.initialize(requester: id, currentStatus: { 0 }, start: { oldFinish = $0 }) { _ in }
    coordinator.cancel(requester: id)
    oldFinish?(2)
    coordinator.initialize(requester: id, currentStatus: { 0 }, start: { newFinish = $0 }) { results.append($0) }
    oldFinish?(2)
    XCTAssertTrue(results.isEmpty)
    newFinish?(2)
    XCTAssertEqual(results, [2])
  }

  func testConcurrentRequestersShareOneNativeInitialization() {
    let coordinator = AMPSInitializationCoordinator()
    var nativeStatus = 0
    var starts = 0
    var finish: ((Int) -> Void)?
    var a = [Int]()
    var b = [Int]()
    let start: (@escaping (Int) -> Void) -> Void = { callback in
      starts += 1
      nativeStatus = 1
      finish = callback
    }
    coordinator.initialize(requester: UUID(), currentStatus: { nativeStatus }, start: start) { a.append($0) }
    coordinator.initialize(requester: UUID(), currentStatus: { nativeStatus }, start: start) { b.append($0) }
    XCTAssertEqual(starts, 1)
    nativeStatus = 2
    finish?(2)
    XCTAssertEqual(a, [2])
    XCTAssertEqual(b, [1, 2])
  }

  func testDetachDropsOnlyItsInitCompletionAndFailureCanRetry() {
    let coordinator = AMPSInitializationCoordinator()
    let a = UUID()
    let b = UUID()
    var finish: ((Int) -> Void)?
    var aEvents = [Int]()
    var bEvents = [Int]()
    coordinator.initialize(requester: a, currentStatus: { 0 }, start: { finish = $0 }) { aEvents.append($0) }
    coordinator.initialize(requester: b, currentStatus: { 1 }, start: { _ in XCTFail("duplicate native init") }) { bEvents.append($0) }
    coordinator.cancel(requester: b)
    finish?(3)
    XCTAssertEqual(aEvents, [3])
    XCTAssertEqual(bEvents, [1])
    var retried = false
    coordinator.initialize(requester: a, currentStatus: { 3 }, start: { callback in
      retried = true
      callback(2)
    }) { aEvents.append($0) }
    XCTAssertTrue(retried)
    XCTAssertEqual(aEvents, [3, 2])
  }
}
