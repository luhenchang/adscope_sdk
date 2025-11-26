package xyz.adscope.adscope_sdk.data

import xyz.adscope.amps.config.AMPSPrivacyConfig
import xyz.adscope.amps.config.model.AMPSLocation
import xyz.adscope.amps.init.AMPSInitConfig
import kotlin.collections.get

object UiModelConstant {
    const val AUTO = "uiModelAuto"
    const val DARK = "uiModelDark"
    const val LIGHT = "uiModelLight"
}

object CoordinateConstant {
    const val BAIDU = "BAIDU"
    const val WGS84 = "WGS84"
    const val GCJ02 = "GCJ02"
}

object ParamsKey {
    // Core Parameters
    const val TEST_MODEL = "testModel"
    const val APP_ID = "appId"
    const val IS_DEBUG_SETTING = "_isDebugSetting"
    const val IS_USE_HTTPS = "_isUseHttps"
    const val IS_USES_PLASH_PUNCHLINE = "setIsUseSplashPunchLine"
    const val IS_TEST_AD = "isTestAd"

    // Basic Information Parameters
    const val CURRENCY = "currency"
    const val CUSTOM_UA = "customUA"
    const val COUNTRY_CN = "countryCN"
    const val USER_ID = "userId"
    const val ANDROID_ID = "AndroidID"
    const val APP_NAME = "appName"
    const val OPTION_INFO = "optionInfo"
    const val PROVINCE = "province"
    const val CITY = "city"
    const val REGION = "region"
    const val GAID = "gaId"

    // Mediation and UI Parameters
    const val IS_MEDIATION = "isMediation"
    const val IS_MEDIATION_STATIC = "isMediationStatic"
    const val UI_MODEL = "uiModel"
    const val ADAPTER_NAMES = "adapterNames"

    // Extension and Configuration Parameters
    const val EXTENSION_PARAM = "extensionParam"
    const val OPTION_FIELDS = "optionFields"
    const val AD_CONTROLLER = "adController"
    const val ADAPTER_STATUS_BAR_HEIGHT = "adapterStatusBarHeight"
}

object AdControllerPropKey {
    const val IS_CAN_USE_PHONE_STATE = "isCanUsePhoneState"
    const val OAID = "OAID"
    const val IS_SUPPORT_PERSONALIZED = "isSupportPersonalized"
    const val IS_CAN_GATHER_OAID = "isCanGatherOAID"
    const val GET_UNDERAGE_TAG = "getUnderageTag"
    const val USER_AGENT = "userAgent"
    const val IS_CAN_USE_SENSOR = "isCanUseSensor"
    const val IS_LOCATION_ENABLED = "isLocationEnabled"
    const val IS_CAN_USE_ANDROID_ID = "isCanUseAndroidID"
    const val LOCATION = "location"
}

object LocationPropKey {
    const val LATITUDE = "latitude"
    const val LONGITUDE = "longitude"
    const val TIME_STAMP = "timeStamp"
    const val COORDINATE = "coordinate"
}


class AMPSInitConfigConverter {
    companion object {
        @JvmField // Makes it accessible like a static field from Java if needed
        var testModel: Boolean = false
    }

    fun convert(flutterParams: Map<String, Any>?): AMPSInitConfig? {
        if (flutterParams == null) {
            println("AMPSInitConfigConverter: flutterParams are null.")
            return null
        }

        val mAppId = flutterParams[ParamsKey.APP_ID] as? String
        if (mAppId.isNullOrEmpty()) {
            println("AMPSInitConfigConverter: App ID is missing or empty.")
            return null
        }
        val ampsInitConfigBuilder = AMPSInitConfig.Builder()
        ampsInitConfigBuilder.setAppId(mAppId)
        (flutterParams[ParamsKey.TEST_MODEL] as? Boolean)?.let {
            testModel = it
        }
        (flutterParams[ParamsKey.IS_DEBUG_SETTING] as? Boolean)?.let {
            ampsInitConfigBuilder.openDebugLog(it)
        }
        (flutterParams[ParamsKey.IS_USE_HTTPS] as? Boolean)?.let {
            ampsInitConfigBuilder.setIsUseHttps(it)
        }
        (flutterParams[ParamsKey.IS_USES_PLASH_PUNCHLINE] as? Boolean)?.let {
            ampsInitConfigBuilder.setIsUseSplashPunchLine(it)
        }
        (flutterParams[ParamsKey.APP_NAME] as? String)?.let { ampsInitConfigBuilder.setAppName(it) }
        (flutterParams[ParamsKey.OPTION_INFO] as? String)?.let { ampsInitConfigBuilder.setOptionInfoMap(it) }
        (flutterParams[ParamsKey.USER_ID] as? String)?.let { ampsInitConfigBuilder.setUserId(it) }
        //(flutterParams[ParamsKey.ANDROID_ID] as? String)?.let { ampsInitConfigBuilder.setCustomAndroidID(it) }
        (flutterParams[ParamsKey.GAID] as? String)?.let { ampsInitConfigBuilder.setCustomGAID(it) }

        //TODO Android目前未对外提供，等后期适配
        (flutterParams[ParamsKey.UI_MODEL] as? String)?.let { uiModelValue ->
            when (uiModelValue) {
//                UiModelConstant.AUTO -> ampsInitConfigBuilder.setUiModel(ASNPConstants.UiModel.UI_MODEL_AUTO)
//                UiModelConstant.DARK -> ampsInitConfigBuilder.setUiModel(ASNPConstants.UiModel.UI_MODEL_DARK)
//                UiModelConstant.LIGHT -> ampsInitConfigBuilder.setUiModel(ASNPConstants.UiModel.UI_MODEL_LIGHT)
            }
        }

        (flutterParams[ParamsKey.ADAPTER_NAMES] as? List<*>)?.let { names ->
            val stringAdapterNames = names.mapNotNull { it as? String }
            if (stringAdapterNames.isNotEmpty()) {
                //TODO 目前Android对外不开放此接口
                //ampsInitConfigBuilder.setAdapterNameList(stringAdapterNames)
            }
        }

        (flutterParams[ParamsKey.OPTION_FIELDS] as? Map<String, Any>)?.let { optionFieldsMap ->
            (optionFieldsMap["crashCollectSwitch"] as? Boolean).let { crash ->
                crash?.let {
                    val crashMap = mapOf("forbid_collect_crash" to crash)
                    ampsInitConfigBuilder.setLocalExtraMap(crashMap as Map<String?, Map<String?, Any?>?>?)
                }
            }
            //TODO Android端公共接口没有setOptionFields,但是publish下面是通过这个获取的。等后期android有了添加
            (optionFieldsMap["lightColor"] as? String).let { lightColor ->
                val uIMap: MutableMap<String, String?> = mutableMapOf("lightColor" to lightColor)
                (optionFieldsMap["darkColor"] as? String).let { darkColor ->
                    uIMap["darkColor"] = darkColor
                }
                val safeStringMap = uIMap.toMap()
                // ampsInitConfigBuilder.setOptionFields(safeStringMap)
            }
        }

        (flutterParams[ParamsKey.AD_CONTROLLER] as? Map<*, *>)?.let { adControllerMap ->
            //(adControllerMap[AdControllerPropKey.OAID] as? String)?.let { ampsInitConfigBuilder.setCustomOAID(it) }
            val privacyConfig = object : AMPSPrivacyConfig() {
                override fun isCanUseLocation(): Boolean {
                    val isCanUpdateLocation =
                        adControllerMap[AdControllerPropKey.IS_LOCATION_ENABLED] as? Boolean
                    return isCanUpdateLocation ?: true
                }

                override fun isCanUseShakeAd(): Boolean {
                    val isCanUseSensor =
                        adControllerMap[AdControllerPropKey.IS_CAN_USE_SENSOR] as? Boolean
                    return isCanUseSensor ?: true
                }

                override fun isSupportPersonalized(): Boolean {
                    val isSupportPersonalized =
                        adControllerMap[AdControllerPropKey.IS_SUPPORT_PERSONALIZED] as? Boolean
                    return isSupportPersonalized ?: true
                }

                override fun getLocation(): AMPSLocation? {
                    val locationMap = adControllerMap[AdControllerPropKey.LOCATION] as? Map<*, *> ?: return null
                    val location = AMPSLocation()
                    val latitude = (locationMap[LocationPropKey.LATITUDE] as? Number)?.toDouble()
                    location.latitude = latitude ?: 0.0
                    val longitude = (locationMap[LocationPropKey.LONGITUDE] as? Number)?.toDouble()
                    location.longitude = longitude ?: 0.0
                    (locationMap[LocationPropKey.COORDINATE] as? String)?.let { coordinateValue ->
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
            }
            ampsInitConfigBuilder.setAMPSPrivacyConfig(privacyConfig)
        }
        return ampsInitConfigBuilder.build()
    }
}
