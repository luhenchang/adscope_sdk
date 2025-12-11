# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
-ignorewarnings

-dontoptimize
-dontpreverify
-dontwarn android.app.**
-dontwarn android.support.**
-dontwarn sun.misc.**
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn android.support.**


-keep class sun.misc.**{*;}
-keep class android.support.** { *; }
-keep class android.app.**{*;}
-keep class **.R$* {*;}


# AdScope广告渠道聚合混淆
-dontwarn xyz.adscope.amps.**
-keep class xyz.adscope.amps.** {*; }
-dontwarn xyz.adscope.common.**
-keep class xyz.adscope.common.** {*; }

# AdScope广告渠道适配器混淆
-dontwarn xyz.adscope.amps.adapter.**
-keep class  xyz.adscope.amps.adapter.**{*;}

# 倍孜广告渠道混淆
-dontwarn com.beizi.fusion.**
-dontwarn com.beizi.ad.**
-keep class com.beizi.fusion.** {*; }
-keep class com.beizi.ad.** {*; }

#优加广告渠道混淆
-dontwarn xyz.adscope.ad.**
-keep class xyz.adscope.ad.** {*; }


# 广点通广告渠道混淆 不接入get sdk可以不引入
-keep class com.qq.e.** {
    public protected *;
}
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod
-dontwarn  org.apache.**

# 穿山甲-GroMore融合版本广告渠道混淆 不接入csj sdk可以不引入
-keep class bykvm*.**
-keep class com.bytedance.msdk.adapter.**{ public *; }
-keep class com.bytedance.msdk.api.** {
 public *;
}
-keep class com.bytedance.msdk.base.TTBaseAd{*;}
-keep class com.bytedance.msdk.adapter.TTAbsAdLoaderAdapter{
    public *;
    protected <fields>;
}

# 百度广告渠道混淆 不接入baidu sdk可以不引入
-ignorewarnings
-dontwarn com.baidu.mobads.sdk.api.**
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep class com.baidu.mobads.** { *; }
-keep class com.style.widget.** {*;}
-keep class com.component.** {*;}
-keep class com.baidu.ad.magic.flute.** {*;}
-keep class com.baidu.mobstat.forbes.** {*;}


# 快手广告渠道混淆 不接入ks sdk可以不引入
-keep class org.chromium.** {*;}
-keep class org.chromium.** { *; }
-keep class aegon.chrome.** { *; }
-keep class com.kwai.**{ *; }
-dontwarn com.kwai.**
-dontwarn com.kwad.**
-dontwarn com.ksad.**
-dontwarn aegon.chrome.**

#京东混淆 不接入jd sdk可以不引入
-keep class com.jd.ad.sdk.** { *; }


#Sigmob 混淆
-keep class com.sigmob.sdk.**{ *;}
-keep interface com.sigmob.sdk.**{ *;}
-keep class com.sigmob.windad.**{ *;}
-keep interface com.sigmob.windad.**{ *;}
-keep class com.czhj.**{ *;}
-keep interface com.czhj.**{ *;}
-keep class com.tan.mark.**{*;}

# miitmdid

-dontwarn com.bun.**
-keep class com.bun.** {*;}
-keep class a.**{*;}
-keep class XI.CA.XI.**{*;}
-keep class XI.K0.XI.**{*;}
-keep class XI.XI.K0.**{*;}
-keep class XI.vs.K0.**{*;}
-keep class XI.xo.XI.XI.**{*;}
-keep class com.asus.msa.SupplementaryDID.**{*;}
-keep class com.asus.msa.sdid.**{*;}
-keep class com.huawei.hms.ads.identifier.**{*;}
-keep class com.samsung.android.deviceidservice.**{*;}
-keep class com.zui.opendeviceidlibrary.**{*;}
-keep class org.json.**{*;}
-keep public class com.netease.nis.sdkwrapper.Utils {public <methods>;}


# 美数

# GSON
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.examples.android.model.** { <fields>; }
-keep class com.google.gson.examples.android.model.** { <fields>; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
@com.google.gson.annotations.SerializedName <fields>;
}

# msad
-keep class com.meishu.sdk.** { *; }


# 章鱼混淆
-dontwarn com.octopus.**
-keep class com.octopus.** {*;}

#vivo
-keep class com.vivo.*.** { *; }
-dontwarn com.vivo.secboxsdk.**
-keep class com.vivo.secboxsdk.SecBoxCipherException { *; }
-keep class com.vivo.secboxsdk.jni.SecBoxNative { *; }
-keep class com.vivo.secboxsdk.BuildConfig { *; }
-keep class com.vivo.advv.**{*;}

# oppo
-keep class com.opos.** { *;}
-keep class com.heytap.msp.mobad.** { *;}
-keep class com.heytap.openid.** {*;}
-keep class okio.**{ *; }
-keeppackagenames com.heytap.nearx.tapplugin



#枫岚sdk
-keep class com.maplehaze.** {*;}

# QY SDK ProGuard
-dontwarn com.hy.andlib.**
-keep class com.hy.andlib.** { *; }


#mimo sdk
-keep class com.miui.zeus.** { *; }

#YK sdk
-keep public class * extends java.io.Serializable{*;}
-dontwarn com.insightvision.openadsdk.**
-keep class com.insightvision.openadsdk.** { *; }

