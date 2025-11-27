import {
  AMPSAdVideoPlayConfig
} from 'xyz.adscope.amps';

export class AdVdConfigWrapperManager {
  // 静态私有实例，用于实现单例模式
  private static instance: AdVdConfigWrapperManager;
  // 私有 Map，用于存储广告实例。
  // 键为 adId，值为 AMPSAdVideoPlayConfig 实例
  private videoCfgMap: Map<string, AMPSAdVideoPlayConfig>;

  // 私有构造函数，防止外部直接实例化
  private constructor() {
    this.videoCfgMap = new Map<string, AMPSAdVideoPlayConfig>();
  }

  // 公共静态方法，用于获取单例实例
  public static getInstance(): AdVdConfigWrapperManager {
    if (!AdVdConfigWrapperManager.instance) {
      AdVdConfigWrapperManager.instance = new AdVdConfigWrapperManager();
    }
    return AdVdConfigWrapperManager.instance;
  }

  // --- 业务方法 ---

  /**
   * 将广告实例添加到 Map 中
   * @param ad 广告实例
   */
  public addVdConfig(adId: string, videoConfig: AMPSAdVideoPlayConfig): void {
    if (videoConfig) {
      this.videoCfgMap.set(adId, videoConfig);
    }
  }

  /**
   * 根据 adId 获取广告实例
   * @param adId 广告的唯一 ID
   * @returns 广告实例，如果不存在则返回 undefined
   */
  public getVdConfig(adId: string): AMPSAdVideoPlayConfig | undefined {
    return this.videoCfgMap.get(adId);
  }

  /**
   * 根据 adId 删除广告实例
   * @param adId 广告的唯一 ID
   * @returns 是否成功删除
   */
  public removeVdConfig(adId: string): boolean {
    return this.videoCfgMap.delete(adId);
  }

  /**
   * 清空所有广告实例
   */
  public clearAllAdConfigs(): void {
    this.videoCfgMap.clear();
  }
}
