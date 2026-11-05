# 商城参数键通过 SDK 公开常量读取，避免旧 SDK 在编译期缺少该字段。
-keepclassmembers class xyz.adscope.amps.common.AMPSConstants {
    public static java.lang.String AMPS_ADN_GM_SHOP_EXTRA_DATA;
}
