import {
  AMPSNativeAdWrapper
} from 'xyz.adscope.amps';

export class AdWrapperManager {
  private adMap: Map<string, AMPSNativeAdWrapper>;

  constructor() {
    this.adMap = new Map<string, AMPSNativeAdWrapper>();
  }

  // --- 业务方法 ---

  /**
   * 将广告实例添加到 Map 中
   * @param adId Flutter 侧回传并用于平台视图查找的广告 ID
   * @param ad 广告实例
   */
  public addAd(adId: string, ad: AMPSNativeAdWrapper): void {
    if (adId && ad) {
      this.adMap.set(adId, ad);
    }
  }

  public allItem():AMPSNativeAdWrapper[]{
    return Array.from(this.adMap.values())
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
