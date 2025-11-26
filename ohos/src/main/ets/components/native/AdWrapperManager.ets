import {
  AMPSNativeAdWrapper
} from 'xyz.adscope.amps';

export class AdWrapperManager {
  // 静态私有实例，用于实现单例模式
  private static instance: AdWrapperManager;

  // 私有 Map，用于存储广告实例。
  // 键为 adId，值为 AMPSNativeAdWrapper 实例
  private adMap: Map<string, AMPSNativeAdWrapper>;

  // 私有构造函数，防止外部直接实例化
  private constructor() {
    this.adMap = new Map<string, AMPSNativeAdWrapper>();
  }

  // 公共静态方法，用于获取单例实例
  public static getInstance(): AdWrapperManager {
    if (!AdWrapperManager.instance) {
      AdWrapperManager.instance = new AdWrapperManager();
    }
    return AdWrapperManager.instance;
  }

  // --- 业务方法 ---

  /**
   * 将广告实例添加到 Map 中
   * @param ad 广告实例
   */
  public addAd(ad: AMPSNativeAdWrapper): void {
    if (ad && ad.adId) {
      this.adMap.set(ad.adId, ad);
    }
  }

  /**
   * 根据 adId 获取广告实例
   * @param adId 广告的唯一 ID
   * @returns 广告实例，如果不存在则返回 undefined
   */
  public getAd(adId: string): AMPSNativeAdWrapper | undefined {
    return this.adMap.get(adId);
  }

  /**
   * 根据 adId 删除广告实例
   * @param adId 广告的唯一 ID
   * @returns 是否成功删除
   */
  public removeAd(adId: string): boolean {
    return this.adMap.delete(adId);
  }

  /**
   * 清空所有广告实例
   */
  public clearAllAds(): void {
    this.adMap.clear();
  }
}
