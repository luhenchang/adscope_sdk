import Flutter
import UIKit

public class AdscopeSdkPlugin: NSObject, FlutterPlugin {
  let events = AMPSEventManager()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = AdscopeSdkPlugin()
    plugin.events.regist(registrar)
    AMPSPlatformViewRegistry().regist(registrar, eventManager: plugin.events)
    // Flutter only sends detachFromEngine to the published plugin instance.
    registrar.publish(plugin)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    events.release()
  }
}
