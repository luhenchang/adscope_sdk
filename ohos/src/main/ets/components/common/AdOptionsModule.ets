import { Any } from '@ohos/flutter_ohos';
import { ampsAd } from 'xyz.adscope.amps';

// 定义键名常量，避免硬编码
const KEY_SPACE_ID = "spaceId"
const KEY_AD_COUNT = "adCount"
const KEY_S2S_IMPL = "s2sImpl"
const KEY_TIMEOUT_INTERVAL = "timeoutInterval"
const KEY_EXPRESS_SIZE = "expressSize"
const KEY_SPLASH_BOTTOM_HEIGHT = "splashAdBottomBuilderHeight"
const KEY_USER_ID = "userId"
const KEY_EXTRA = "extra"
const KEY_IP_ADDRESS = "ipAddress"

export class AdOptionsModule {
  /**
   * 从Map解析广告配置选项
   * @param map 包含广告配置的Map对象
   * @returns 解析后的广告配置对象
   */
  static getAdOptionFromMap(map: Map<string, Any>): ampsAd.AdOptions {
    // 严格类型检查与空值处理
    const spaceId = map.get(KEY_SPACE_ID) as string ?? ""
    // 解析可选参数并指定类型
    const adCount = map.has(KEY_AD_COUNT) ? map.get(KEY_AD_COUNT) as number : 1
    const s2sImpl = map.has(KEY_S2S_IMPL) ? map.get(KEY_S2S_IMPL) as string : undefined
    const timeoutInterval = map.has(KEY_TIMEOUT_INTERVAL) ? map.get(KEY_TIMEOUT_INTERVAL) as number : undefined
    const expressSize = map.has(KEY_EXPRESS_SIZE) ? map.get(KEY_EXPRESS_SIZE) as [number?, number?] : undefined
    const splashAdBottomBuilderHeight = map.has(KEY_SPLASH_BOTTOM_HEIGHT) ? map.get(KEY_SPLASH_BOTTOM_HEIGHT) as number : undefined
    const userId = map.has(KEY_USER_ID) ? map.get(KEY_USER_ID) as string : undefined
    const extra = map.has(KEY_EXTRA) ? map.get(KEY_EXTRA) as string : undefined
    const ipAddress = map.has(KEY_IP_ADDRESS) ? map.get(KEY_IP_ADDRESS) as string : undefined

    // 显式指定类型，符合ArkTS对象字面量规范
    const adOptions: ampsAd.AdOptions = {
      spaceId: spaceId,
      adCount: adCount,
      s2sImpl: s2sImpl,
      timeoutInterval: timeoutInterval,
      expressSize: expressSize,
      splashAdBottomBuilderHeight: splashAdBottomBuilderHeight,
      userId: userId,
      extra: extra,
      ipAddress: ipAddress
    }

    return adOptions
  }
}
