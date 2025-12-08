import Flutter
import UIKit

public class AdscopeSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    AMPSEventManager.shared.regist(registrar)
    AMPSPlatformViewRegistry.shared.regist(registrar)
  }
}
