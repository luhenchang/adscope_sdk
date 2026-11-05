import AMPSAdSDK
import Flutter
import UIKit

final class AMPSMallViewFactory: NSObject, FlutterPlatformViewFactory {
    private let eventManager: AMPSEventManager
    init(eventManager: AMPSEventManager) { self.eventManager = eventManager }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol { FlutterStandardMessageCodec.sharedInstance() }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let container = AMPSMallContainer(frame: frame)
        guard let args = args as? [String: Any],
              let instanceId = args[ArgumentKeys.adInstanceId] as? String,
              let adId = args["adId"] as? String,
              let (ad, mall) = eventManager.nativeManager.mallEntry(instanceId: instanceId, adId: adId) else {
            container.showError("商城视图不可用，请重新加载商城广告位")
            return container
        }
        guard mall.superview == nil else {
            container.showError("同一个商城广告不能同时挂载到多个组件")
            return container
        }
        container.attach(ad: ad, mall: mall, visible: args["visible"] as? Bool ?? true)
        return container
    }
}

final class AMPSMallContainer: UIView, FlutterPlatformView {
    private weak var ad: AMPSUnifiedNativeAd?
    private weak var mall: AMPSNativeExpressView?
    func view() -> UIView { self }
    func attach(ad: AMPSUnifiedNativeAd, mall: AMPSNativeExpressView, visible: Bool) {
        self.ad?.setMallViewVisible(false)
        self.mall?.removeFromSuperview()
        self.ad = ad
        self.mall = mall
        mall.frame = bounds
        mall.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mall.isHidden = !visible
        addSubview(mall)
        ad.setMallViewVisible(visible && window != nil && UIApplication.shared.applicationState == .active)
    }
    func showError(_ message: String) {
        let label = UILabel(frame: bounds)
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        ad?.setMallViewVisible(window != nil && mall?.isHidden == false && UIApplication.shared.applicationState == .active)
    }
    deinit {
        ad?.setMallViewVisible(false)
        mall?.removeFromSuperview()
    }
}
