import Foundation

/// 仅覆盖商城 userData，保留 GM 其他字段及其他广告渠道配置。
enum AMPSGMMallRewardParameters {
    static func merge(_ extra: [String: Any]?, userData: String?) -> [String: Any] {
        var merged = extra ?? [:]
        guard let userData = userData, !userData.isEmpty else { return merged }
        var gm = merged["GM"] as? [String: Any] ?? [:]
        gm["userData"] = userData
        merged["GM"] = gm
        return merged
    }
}
