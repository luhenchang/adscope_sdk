package xyz.adscope.adscope_sdk.data

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import xyz.adscope.amps.config.AMPSPrivacyConfig
import xyz.adscope.amps.config.model.AMPSLocation
import xyz.adscope.amps.init.AMPSInitConfig
import kotlin.collections.get
object CoordinateConstant {
    const val BAIDU = "BAIDU"
    const val WGS84 = "WGS84"
    const val GCJ02 = "GCJ02"
}

object AMPSInitConfigKey {
    /** 测试模式 */
    const val TEST_MODEL = "testModel"

    /** 对应 appId 的序列化键 */
    const val APP_ID = "appId"

    /** 对应 _isDebugSetting 的序列化键 */
    const val IS_DEBUG_SETTING = "_isDebugSetting"

    /** 对应 _isUseHttps 的序列化键 */
    const val IS_USE_HTTPS = "_isUseHttps"

    /** 对应 isTestAd 的序列化键 */
    const val IS_TEST_AD = "isTestAd"

    /** 对应 currency 的序列化键 */
    const val CURRENCY = "currency"

    /** 对应 countryCN 的序列化键 */
    const val COUNTRY_CN = "countryCN"

    /** 对应 appName 的序列化键 */
    const val APP_NAME = "appName"

    /** 对应 customUA 的序列化键 */
    const val CUSTOM_UA = "customUA"

    /** AndroidID 序列化键 */
    const val ANDROID_ID = "AndroidID"

    /** 自定义 GAID 序列化键 */
    const val CUSTOM_GAID = "customGAID"

    /** 可选信息序列化键 */
    const val OPTION_INFO = "optionInfo"

    /** 对应 userId 的序列化键 */
    const val USER_ID = "userId"

    /** 对应 province 的序列化键 */
    const val PROVINCE = "province"

    /** 对应 adapterStatusBarHeight 的序列化键 */
    const val ADAPTER_STATUS_BAR_HEIGHT = "adapterStatusBarHeight"

    /** 对应 city 的序列化键 */
    const val CITY = "city"

    /** 对应 region 的序列化键 */
    const val REGION = "region"

    /** 对应 isMediation 的序列化键 */
    const val IS_MEDIATION = "isMediation"

    /** 对应 uiModel 的序列化键 */
    const val UI_MODEL = "uiModel"

    /** 对应 adapterNames 的序列化键 */
    const val ADAPTER_NAMES = "adapterNames"

    /** 对应 extensionParam 的序列化键 */
    const val EXTENSION_PARAM = "extensionParam"

    /** 对应 optionFields 的序列化键 */
    const val OPTION_FIELDS = "optionFields"

    /** 对应 adController 的序列化键 */
    const val AD_CONTROLLER = "adController"

    /** 对应 isUseSplashPunchLine 的序列化键 */
    const val IS_USE_SPLASH_PUNCH_LINE = "isUseSplashPunchLine"
}

object AdControllerPropKey {
    // 原有字段
    const val IS_CAN_USE_PHONE_STATE = "isCanUsePhoneState"
    const val IS_SUPPORT_PERSONALIZED = "isSupportPersonalized"
    const val IS_LOCATION_ENABLED = "isLocationEnabled"
    const val IS_CAN_USE_ANDROID_ID = "isCanUseAndroidId"
    const val LOCATION = "location"

    // 新增 Flutter 端字段（按 Flutter 顺序排列，命名规范统一）
    const val IS_CAN_USE_WIFI_STATE = "isCanUseWifiState"
    const val IS_CAN_USE_OAID = "isCanUseOaid"
    const val DEV_OAID = "devOaid"
    const val IS_CAN_USE_APP_LIST = "isCanUseAppList"
    const val GET_APP_LIST = "getAppList"
    const val ANDROID_ID = "androidId"
    const val IS_CAN_USE_MAC_ADDRESS = "isCanUseMacAddress"
    const val MAC_ADDRESS = "macAddress"
    const val IS_CAN_USE_WRITE_EXTERNAL = "isCanUseWriteExternal"
    const val IS_CAN_USE_SHAKE_AD = "isCanUseShakeAd"
    const val DEV_IMEI = "devImei"
    const val DEV_IMEI_LIST = "devImeiList"
    const val IS_CAN_USE_RECORD_AUDIO = "isCanUseRecordAudio"
    const val IS_CAN_USE_IP = "isCanUseIP"
    const val IP = "ip"
    const val IS_CAN_USE_SIM_OPERATOR = "isCanUseSimOperator"
    const val DEV_SIM_OPERATOR_CODE = "devSimOperatorCode"
    const val DEV_SIM_OPERATOR_NAME = "devSimOperatorName"
}

object AMPSLocationKey {
    /// 对应纬度（latitude）的序列化键
    const val LATITUDE = "latitude"

    /// 对应经度（longitude）的序列化键
    const val LONGITUDE = "longitude"

    /// 对应时间戳（timeStamp）的序列化键
    const val TIME_STAMP = "timeStamp"

    /// 对应坐标系类型（coordinate）的序列化键
    const val COORDINATE = "coordinate"
}


class AMPSInitConfigConverter {
    companion object {
        @JvmField // Makes it accessible like a static field from Java if needed
        var testModel: Boolean = false
    }
    // 注意：需要在当前类中持有 PackageManager 实例（例如通过 Context 获取）
    private lateinit var packageManager: PackageManager
    fun convert(flutterParams: Map<String, Any>?): AMPSInitConfig? {
        if (flutterParams == null) {
            println("AMPSInitConfigConverter: flutterParams are null.")
            return null
        }

        val mAppId = flutterParams[AMPSInitConfigKey.APP_ID] as? String ?:""
        val ampsInitConfigBuilder = AMPSInitConfig.Builder()
        ampsInitConfigBuilder.setAppId(mAppId)
        (flutterParams[AMPSInitConfigKey.APP_NAME] as? String)?.let { ampsInitConfigBuilder.setAppName(it) }
        (flutterParams[AMPSInitConfigKey.IS_DEBUG_SETTING] as? Boolean)?.let {
            ampsInitConfigBuilder.openDebugLog(it)
        }
        (flutterParams[AMPSInitConfigKey.ADAPTER_NAMES] as? List<*>)?.let { names ->
            val stringAdapterNames = names.mapNotNull { it as? String }
            if (stringAdapterNames.isNotEmpty()) {
                ampsInitConfigBuilder.setAdapterNameList(stringAdapterNames)
            }
        }
        (flutterParams[AMPSInitConfigKey.OPTION_INFO] as? String)?.let { ampsInitConfigBuilder.setOptionInfoMap(it) }
        (flutterParams[AMPSInitConfigKey.PROVINCE] as? String)?.let {
            ampsInitConfigBuilder.setProvince(it)
        }
        (flutterParams[AMPSInitConfigKey.CITY] as? String)?.let {
            ampsInitConfigBuilder.setCity(it)
        }
        (flutterParams[AMPSInitConfigKey.REGION] as? String)?.let {
            ampsInitConfigBuilder.setRegion(it)
        }
        (flutterParams[AMPSInitConfigKey.USER_ID] as? String)?.let { ampsInitConfigBuilder.setUserId(it) }

        (flutterParams[AMPSInitConfigKey.CUSTOM_GAID] as? String)?.let { ampsInitConfigBuilder.setCustomGAID(it) }
        (flutterParams[AMPSInitConfigKey.IS_USE_HTTPS] as? Boolean)?.let {
            ampsInitConfigBuilder.setIsUseHttps(it)
        }

        (flutterParams[AMPSInitConfigKey.IS_USE_SPLASH_PUNCH_LINE] as? Boolean)?.let {
            ampsInitConfigBuilder.setIsUseSplashPunchLine(it)
        }

        (flutterParams[AMPSInitConfigKey.EXTENSION_PARAM] as? Map<String, Map<String, Any?>>)?.let {
            ampsInitConfigBuilder.setLocalExtraMap(it)
        }


        (flutterParams[AMPSInitConfigKey.TEST_MODEL] as? Boolean)?.let {
            testModel = it
        }



        (flutterParams[AMPSInitConfigKey.AD_CONTROLLER] as? Map<*, *>)?.let { adControllerMap ->
            val privacyConfig = object : AMPSPrivacyConfig() {
                override fun isCanUseLocation(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_LOCATION_ENABLED] as? Boolean ?: super.isCanUseLocation()
                }

                override fun isCanUseShakeAd(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_SHAKE_AD] as? Boolean ?: super.isCanUseShakeAd()
                }

                override fun isSupportPersonalized(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_SUPPORT_PERSONALIZED] as? Boolean ?: super.isSupportPersonalized()
                }

                override fun getLocation(): AMPSLocation? {
                    val locationMap = adControllerMap[AdControllerPropKey.LOCATION] as? Map<*, *> ?: return super.getLocation()
                    val location = AMPSLocation()
                    val latitude = (locationMap[AMPSLocationKey.LATITUDE] as? Number)?.toDouble()
                    location.latitude = latitude ?: 0.0
                    val longitude = (locationMap[AMPSLocationKey.LONGITUDE] as? Number)?.toDouble()
                    location.longitude = longitude ?: 0.0
                    (locationMap[AMPSLocationKey.COORDINATE] as? String)?.let { coordinateValue ->
                        val type = when (coordinateValue) {
                            CoordinateConstant.BAIDU -> 2
                            CoordinateConstant.WGS84 -> 1
                            CoordinateConstant.GCJ02 -> 0
                            else -> 0
                        }
                        location.type = type
                    }
                    return location
                }

                override fun getAndroidId(): String? {
                    return adControllerMap[AdControllerPropKey.ANDROID_ID] as? String ?: super.getAndroidId()
                }

                override fun getAppList(): List<PackageInfo>? {
                    // 1. 从 adControllerMap 中获取 Flutter 传递的 List<Map>（核心修复：原代码误将 List 转 Map）
                    val appListFromMap = adControllerMap[AdControllerPropKey.GET_APP_LIST] as? List<*>
                    if (appListFromMap.isNullOrEmpty()) {
                        // 无数据时返回父类默认实现（符合原逻辑）
                        return super.getAppList()
                    }

                    // 2. 遍历列表，转换为系统 PackageInfo 列表（修复类型转换逻辑）
                    return appListFromMap.mapNotNull { item ->
                        try {
                            // 将列表项转换为 Map（Flutter 传递的单个 PackageInfo 对应的 Map）
                            val packageInfoMap = item as? Map<*, *> ?: return@mapNotNull null
                            // 3. 提取字段（修复：单个字段为空时跳过当前对象，而非整个方法返回 null）
                            val packageName = packageInfoMap["packageName"] as? String ?: return@mapNotNull null
                            val versionName = packageInfoMap["versionName"] as? String ?: return@mapNotNull null
                            val versionCodeInt = packageInfoMap["versionCode"] as? Int ?: 0
                            val firstInstallTime = (packageInfoMap["firstInstallTime"] as? Number)?.toLong() ?: 0L
                            val lastUpdateTime = (packageInfoMap["lastUpdateTime"] as? Number)?.toLong() ?: 0L
                            // 4. 创建系统 PackageInfo 实例（核心修复：系统 PackageInfo 不能直接 new，需适配版本）
                            val packageInfo = PackageInfo()
                            // 5. 给 PackageInfo 赋值（适配 versionCode 高低版本差异）
                            packageInfo.apply {
                                this.versionName = versionName
                                this.firstInstallTime = firstInstallTime
                                this.lastUpdateTime = lastUpdateTime
                                this.packageName = packageName

                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                                    // API ≥28：使用 longVersionCode（替代过时的 versionCode）
                                    this.longVersionCode = versionCodeInt.toLong()
                                } else {
                                    // API <28：使用旧版 versionCode
                                    @Suppress("DEPRECATION")
                                    this.versionCode = versionCodeInt
                                }
                            }
                        } catch (e: Exception) {
                            // 解析单个对象失败：打印日志并跳过（不影响其他对象解析）
                            e.printStackTrace()
                            null
                        }
                    }.takeIf { it.isNotEmpty() } ?: super.getAppList()
                }


                override fun getDevImei(): String? {
                    return adControllerMap[AdControllerPropKey.DEV_IMEI] as? String ?: super.getDevImei()
                }

                override fun getDevImeiList(): Array<out String?>? {
                    val imeiList = adControllerMap[AdControllerPropKey.DEV_IMEI_LIST] as? List<*>
                    return imeiList?.map { it as? String }?.toTypedArray() ?: super.getDevImeiList()
                }

                override fun getDevOaid(): String? {
                    // 注意：有两个与OAID相关的Key: OAID 和 devOaid，根据新规范使用 devOaid
                    return adControllerMap[AdControllerPropKey.DEV_OAID] as? String ?: super.getDevOaid()
                }

                override fun getDevSimOperatorCode(): String? {
                    return adControllerMap[AdControllerPropKey.DEV_SIM_OPERATOR_CODE] as? String ?: super.getDevSimOperatorCode()
                }

                override fun getDevSimOperatorName(): String? {
                    return adControllerMap[AdControllerPropKey.DEV_SIM_OPERATOR_NAME] as? String ?: super.getDevSimOperatorName()
                }

                override fun getIP(): String? {
                    return adControllerMap[AdControllerPropKey.IP] as? String ?: super.getIP()
                }

                override fun getMacAddress(): String? {
                    return adControllerMap[AdControllerPropKey.MAC_ADDRESS] as? String ?: super.getMacAddress()
                }


                override fun isCanUseAndroidId(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_ANDROID_ID] as? Boolean ?: super.isCanUseAndroidId()
                }

                override fun isCanUseAppList(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_APP_LIST] as? Boolean ?: super.isCanUseAppList()
                }

                override fun isCanUseIP(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_IP] as? Boolean ?: super.isCanUseIP()
                }

                override fun isCanUseMacAddress(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_MAC_ADDRESS] as? Boolean ?: super.isCanUseMacAddress()
                }

                override fun isCanUsePhoneState(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_PHONE_STATE] as? Boolean ?: super.isCanUsePhoneState()
                }

                override fun isCanUseRecordAudio(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_RECORD_AUDIO] as? Boolean ?: super.isCanUseRecordAudio()
                }

                override fun isCanUseOaid(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_OAID] as? Boolean ?: super.isCanUseOaid()
                }

                override fun isCanUseSimOperator(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_SIM_OPERATOR] as? Boolean ?: super.isCanUseSimOperator()
                }

                override fun isCanUseWifiState(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_WIFI_STATE] as? Boolean ?: super.isCanUseWifiState()
                }

                override fun isCanUseWriteExternal(): Boolean {
                    return adControllerMap[AdControllerPropKey.IS_CAN_USE_WRITE_EXTERNAL] as? Boolean ?: super.isCanUseWriteExternal()
                }
            }
            ampsInitConfigBuilder.setAMPSPrivacyConfig(privacyConfig)
        }

        return ampsInitConfigBuilder.build()
    }
}
