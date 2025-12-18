package xyz.adscope.adscope_sdk.manager

import android.view.View
import xyz.adscope.amps.ad.draw.inter.AMPSDrawAdExpressInfo
import xyz.adscope.amps.ad.nativead.inter.AMPSNativeAdExpressInfo
import java.util.concurrent.ConcurrentHashMap

class AdWrapperManager private constructor() {
    // 使用ConcurrentHashMap保证线程安全
    private val adViewMap: MutableMap<String, View> = ConcurrentHashMap()
    private val adItemMap: MutableMap<String, AMPSNativeAdExpressInfo> = ConcurrentHashMap()
    private val adDrawItemMap: MutableMap<String, AMPSDrawAdExpressInfo> = ConcurrentHashMap()

    companion object {
        // 单例实例，使用双重校验锁保证线程安全
        @Volatile
        private var instance: AdWrapperManager? = null

        fun getInstance(): AdWrapperManager {
            return instance ?: synchronized(this) {
                instance ?: AdWrapperManager().also { instance = it }
            }
        }
    }

    /**
     * 将View添加到Map中
     * @param adId 广告的唯一ID
     * @param view 要存储的View实例
     */
    fun addAdView(adId: String, view: View) {
        if (adId.isNotBlank()) {
            adViewMap[adId] = view
        }
    }

    fun addAdItem(adId: String, adItem: AMPSNativeAdExpressInfo) {
        if (adId.isNotBlank()) {
            adItemMap[adId] = adItem
        }
    }

    fun addDrawAdItem(adId: String, adItem: AMPSDrawAdExpressInfo) {
        if (adId.isNotBlank()) {
            adDrawItemMap[adId] = adItem
        }
    }

    fun removeDrawAdItem(adId: String) {
        if (adId.isNotBlank()) {
            adDrawItemMap.remove(adId)
        }
    }

    /**
     * 根据adId获取View实例
     * @param adId 广告的唯一ID
     * @return 对应的View实例，如果不存在则返回null
     */
    fun getAdView(adId: String): View? {
        return adViewMap[adId]
    }

    fun getAdItem(adId: String): AMPSNativeAdExpressInfo? {
        return adItemMap[adId]
    }

    fun getDrawAdItem(adId: String): AMPSDrawAdExpressInfo? {
        return adDrawItemMap[adId]
    }

    /**
     * 根据adId删除View实例
     * @param adId 广告的唯一ID
     * @return 是否成功删除
     */
    fun removeAdView(adId: String): Boolean {
        return adViewMap.remove(adId) != null
    }

    fun removeAdItem(adId: String): Boolean {
        return adItemMap.remove(adId) != null
    }

    /**
     * 清空所有存储的View实例
     */
    fun clearAllAdsView() {
        adViewMap.clear()
    }

    fun clearAllAdsItem() {
        adItemMap.clear()
    }

    /**
     * 检查是否存在指定adId的View
     * @param adId 广告的唯一ID
     * @return 如果存在返回true，否则返回false
     */
    fun containsAdView(adId: String): Boolean {
        return adViewMap.containsKey(adId)
    }

    fun containsAdItem(adId: String): Boolean {
        return adItemMap.containsKey(adId)
    }

    /**
     * 获取当前存储的View数量
     * @return View的数量
     */
    fun getAdViewCount(): Int {
        return adViewMap.size
    }

    fun getAdItemCount(): Int {
        return adItemMap.size
    }
}
    