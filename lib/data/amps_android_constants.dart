/// Defines constants used throughout the AMPS SDK.
class AmpsAndroidConstants {
  AmpsAndroidConstants._();

  static const String ampsLogTag = 'amps_log_tag';
  static const String ampsLogTagReport = 'amps_log_report';
  static const String resourceHead = 'amps';
  static const String adapterNamePre = 'xyz.adscope.amps.adapter';
  static const String ampsGlobalconfig = 'amps_global_config';
  static const String ampsCrashReasonKey = 'amps_crash_reason_key';
  static const String ampsCrashRequestSdkPackagename = 'crash_request_sdk';
  static const String ampsCrashReportKey = 'ampsCrashReport';
  static const String ampsAppid = '${AmpsAndroidConstants.resourceHead}_appid';
  static const String acceptEncrypt = 'Accept-Encrypt';
  static const String acceptEncryptDefault = '101,1001';
  static const String ampsConfigUrl =
      'aHR0cDovL3Nkay1hcGkuYmVpemkuYml6L3YxL2FwaS9zZGsvY2Zn';
  static const String ampsConfigUrlTransferProtocol =
      'aHR0cHM6Ly9zZGstYXBpLmJlaXppLmJpei92MS9hcGkvc2RrL2NmZw==';

  // Channel Log Tags
  static const String ampsChannelLogTagAsnp = 'ASNPSDK';
  static const String ampsChannelLogTagBz = 'BZSDK';
  static const String ampsChannelLogTagBd = 'BDSDK';
  static const String ampsChannelLogTagCsj = 'CSJSDK';
  static const String ampsChannelLogTagGm = 'GMSDK';
  static const String ampsChannelLogTagGdt = 'GDTSDK';
  static const String ampsChannelLogTagKs = 'KSSDK';
  static const String ampsChannelLogTagHw = 'HWSDK';
  static const String ampsChannelLogTagQm = 'QMSDK';
  static const String ampsChannelLogTagJd = 'JDSDK';
  static const String ampsChannelLogTagSigmob = 'SigmobSDK';
  static const String ampsChannelLogTagOct = 'OCTSDK';
  static const String ampsChannelLogTagMs = 'MeiShu';
  static const String ampsChannelLogTagVivo = 'VIVOSDK';
  static const String ampsChannelLogTagMimo = 'MIMOSDK';
  static const String ampsChannelLogTagIqy = 'IQY';
  static const String ampsChannelLogTagOppo = 'OPPOSDK';
  static const String ampsChannelLogTagFl = 'FengLan';
  static const String ampsChannelLogTagYouku = 'YOUKUSDK';
  static const String ampsChannelLogTagQy = 'QingYun';

  // Channel Network Names
  static const String ampsChannelNetworkNameAsnp = 'ASNP';
  static const String ampsChannelNetworkNameBz = 'BZ';
  static const String ampsChannelNetworkNameBd = 'BD';
  static const String ampsChannelNetworkNameCsj = 'CSJ';
  static const String ampsChannelNetworkNameGm = 'GM';
  static const String ampsChannelNetworkNameGdt = 'GDT';
  static const String ampsChannelNetworkNameKs = 'KS';
  static const String ampsChannelNetworkNameHw = 'HW';
  static const String ampsChannelNetworkNameQm = 'QM';
  static const String ampsChannelNetworkNameJd = 'JD';
  static const String ampsChannelNetworkNameSigmob = 'SigMob';
  static const String ampsChannelNetworkNameMs = 'MeiShu';
  static const String ampsChannelNetworkNameOct = 'OCT';
  static const String ampsChannelNetworkNameIqy = 'IQY';
  static const String ampsChannelNetworkNameOppo = 'OPPO';
  static const String ampsChannelNetworkNameVivo = 'VIVO';
  static const String ampsChannelNetworkNameFl = 'FengLan';
  static const String ampsChannelNetworkNameMimo = 'MIMO';
  static const String ampsChannelNetworkNameYouku = 'YOUKU';
  static const String ampsChannelNetworkNameQy = 'QingYun';

  // Channel SDK Classnames
  static const String channelSdkAsnpClassname = 'biz.beizi.adn.ad.publish.ASNPAdSDK';
  static const String channelSdkBaiduClassname = 'com.baidu.mobads.sdk.api.BDAdConfig';
  static const String channelSdkBzClassname = 'com.beizi.fusion.BeiZis';
  static const String channelSdkCsjClassname = 'com.bytedance.sdk.openadsdk.TTAdSdk';
  static const String channelSdkGdtClassname = 'com.qq.e.comm.managers.GDTAdSdk';
  static const String channelSdkGmClassname = 'com.bytedance.sdk.openadsdk.TTAdSdk';
  static const String channelSdkOctClassname = 'com.octopus.ad.OctopusProvider';
  static const String channelSdkHwClassname = 'com.huawei.hms.ads.HwAds';
  static const String channelSdkKsClassname = 'com.kwad.sdk.api.KsAdSDK';
  static const String channelSdkQmClassname = 'com.qumeng.advlib.api.AiClkAdManager';
  static const String channelSdkSigmobClassname = 'com.sigmob.windad.WindAds';
  static const String channelSdkIqyClassname = 'com.mcto.sspsdk.QySdk';
  static const String channelSdkOppoClassname = 'com.heytap.msp.mobad.api.InitParams';
  static const String channelSdkMimoClassname = 'com.miui.zeus.mimo.sdk.MimoSdk';
  static const String channelSdkYkClassname = 'com.insightvision.openadsdk.api.FanTiAdSdk';
  static const String channelSdkMsClassname = 'com.meishu.sdk.core.AdSdk';
  static const String channelSdkFlClassname = 'com.maplehaze.adsdk.MaplehazeSDK';
  static const String channelSdkQyClassname = 'com.hy.andlib.ads.HYAdSdk';

  // Channel Adapter Init Classnames
  static const String channelAdapterInitClassnameAsnp =
      'xyz.adscope.amps.adapter.asnp.ASNPInitMediation';
  static const String channelAdapterInitClassnameBd =
      'xyz.adscope.amps.adapter.bd.ASNPInitMediation';
  static const String channelAdapterInitClassnameBz =
      'xyz.adscope.amps.adapter.bz.ASNPInitMediation';
  static const String channelAdapterInitClassnameCsj =
      'xyz.adscope.amps.adapter.csj.ASNPInitMediation';
  static const String channelAdapterInitClassnameGdt =
      'xyz.adscope.amps.adapter.gdt.ASNPInitMediation';
  static const String channelAdapterInitClassnameGm =
      'xyz.adscope.amps.adapter.gm.ASNPInitMediation';
  static const String channelAdapterInitClassnameKs =
      'xyz.adscope.amps.adapter.ks.ASNPInitMediation';
  static const String channelAdapterInitClassnameHw =
      'xyz.adscope.amps.adapter.hw.ASNPInitMediation';
  static const String channelAdapterInitClassnameQm =
      'xyz.adscope.amps.adapter.qm.ASNPInitMediation';
  static const String channelAdapterInitClassnameIqy =
      'xyz.adscope.amps.adapter.iqy.ASNPInitMediation';

  // Bid Data Type
  static const int ampsSendBidDataType0 = 0;
  static const int ampsSendBidDataType1 = 1;

  // Local Extra Data
  static const String ampsLocalExtraDataCsj = 'csjLocalExtraData';
  static const String ampsLocalExtraDataKs = 'ksLocalExtraData';
  static const String ampsLocalExtraDataBd = 'bdLocalExtraData';
  static const String ampsLocalExtraDataGdt = 'gdtLocalExtraData';
  static const String ampsLocalExtraDataAsnp = 'asnpLocalExtraData';
  static const String ampsLocalExtraDataSigmob = 'sigmobLocalExtraData';
  static const String ampsLocalExtraDataVivo = 'vivoLocalExtraData';

  // CSJ Local Extra
  static const String csjLocalExtraData = 'csjUserExtraData';
  static const String csjLocalExtraKeyPaid = 'paid';
  static const String csjLocalExtraKeyKeywords = 'keywords';
  static const String csjLocalExtraKeyTitleBarTheme = 'titleBarTheme';
  static const String csjLocalExtraKeyAllowShowNotify = 'allowShowNotify';
  static const String csjLocalExtraKeyDirectDownloadNetworkType =
      'directDownloadNetworkType';
  static const String csjLocalExtraKeyAgeGroup = 'ageGroup';
  static const String csjLocalExtraKeyThemeStatus = 'themeStatus';
  static const String csjLocalExtraKeyPublisherDid = 'publisherDid';
  static const String csjLocalExtraKeyOpenSdkVer = 'openSdkVer';
  static const String csjLocalExtraKeyWxInstalled = 'wxInstalled';
  static const String csjLocalExtraKeySupportH265 = 'supportH265';
  static const String csjLocalExtraKeySupportSplashZoomOut = 'SupportSplashZoomOut';
  static const String csjLocalExtraKeyWxAppId = 'wxAppId';
  static const String csjLocalExtraKeyUserPrivacyConfig = 'userPrivacyConfig';

  // KS Local Extra
  static const String ksLocalExtraKeyShowNotification = 'showNotification';

  // BD Local Extra
  static const String bdLocalExtraKeyDlDialogType = 'dlDialogType';
  static const String bdLocalExtraKeyDlDialogAnimStyle = 'dlDialogAnimStyle';
  static const String bdLocalExtraKeyWxAppId = 'wxAppId';
  static const String bdLocalExtraKeyUseHttps = 'useHttps';
  static const String bdLocalExtraKeyVideoCacheCapacityMb = 'videoCacheCapacityMb';
  static const String bdLocalExtraKeyExtraParams = 'extraParams';

  // GDT Local Extra
  static const String gdtLocalExtraKeyConvOptimizeInfo = 'ConvOptimizeInfo';
}

/// Ad types.
class AdType {
  AdType._();
  static const String splash = 'splash';
  static const String native = 'native';
  static const String punchline = '9';
}

/// Ad space request status.
class SpaceAdStatus {
  SpaceAdStatus._();
  static const int normal = 0;
  static const int loadSuccess = 1;
  static const int show = 2;
  static const int fail = 3;
}

/// Bidding types.
class BiddingType {
  BiddingType._();
  static const String s2s = 'S2S';
  static const String c2s = 'C2S';
  static const String wf = 'WF';
  static const String other = 'other';
}

/// Ad request types.
class AdRequestType {
  AdRequestType._();
  static const int parallel = 0;
  static const int serial = 1;
  static const int samePrice = 2;
}

/// Ad resource status.
class AdResourceStatus {
  AdResourceStatus._();
  static const int normal = 0;
  static const int dispatch = 1;
  static const int bidding = 2;
  static const int biddingSuccess = 3;
  static const int loading = 4;
  static const int loadingSuccess = 5;
  static const int fail = 6;
}

/// Ad source floor types.
class AdSourceFloorType {
  AdSourceFloorType._();
  static const int normal = 0;
  static const int floor = 1;
}

/// Ad source compare price status.
class AdSourceComparePriceStatus {
  AdSourceComparePriceStatus._();
  static const int normal = 0;
  static const int wait = 1;
  static const int biddingWin = 2;
  static const int loadWin = 3;
  static const int loss = 4;
}

/// Frequency event types.
class FrequencyEventType {
  FrequencyEventType._();
  static const String request = 'request';
  static const String show = 'show';
  static const String click = 'click';
}

/// Bidding loss reasons.
class BiddingLossReason {
  BiddingLossReason._();
  static const int lowPrice = 1;
  static const int noPrice = 2;
  static const int timeOut = 3;
  static const int other = 4;
}

/// Bidding winner sources.
class BiddingWinnerSource {
  BiddingWinnerSource._();
  static const int otherNotBiddingAd = 1;
  static const int otherTheThirdAdn = 2;
  static const int otherSelfSaleAd = 3;
  static const int otherBiddingAd = 4;
}

/// Ad load status.
class AdLoadStatus {
  AdLoadStatus._();
  static const int normal = 0;
  static const int loading = 1;
  static const int success = 2;
  static const int fail = 3;
}

/// Ad load types.
class AdLoadType {
  AdLoadType._();
  static const int normal = 0;
  static const int preload = 1;
  static const int autoRefresh = 2;
}

/// Ad auto-refresh switch status.
class AdAutoRefreshSwitchStatus {
  AdAutoRefreshSwitchStatus._();
  static const int close = 0;
  static const int open = 1;
}

/// Punch-line switch status.
class IsPunchLineSwitchStatus {
  IsPunchLineSwitchStatus._();
  static const int close = 0;
  static const int open = 1;
}

/// Ad same-price type.
class AdSamePriceType {
  AdSamePriceType._();
  static const int normal = 0;
  static const int open = 1;
}

/// Accelerator type.
class IsAcceleratorType {
  IsAcceleratorType._();
  static const int normal = 0;
  static const int open = 1;
}

/// Priority type.
class IsPriorityType {
  IsPriorityType._();
  static const int normal = 0;
  static const int open = 1;
}

/// Same price type.
class IsSamePriceType {
  IsSamePriceType._();
  static const int normal = 0;
  static const int open = 1;
}

/// Floor cache type.
class IsFloorCache {
  IsFloorCache._();
  static const int normal = 0;
  static const int open = 1;
}

/// Ad source types.
class AdSourceType {
  AdSourceType._();
  static const String rewardVideo = '1';
  static const String splash = '2';
  static const String interstitial = '3';
  static const String banner = '4';
  static const String nativeUnified = '7';
  static const String nativeExpress = '7';
  static const String draw = '8';
}

/// Channel names.
class ChannelName {
  ChannelName._();
  static const String asnp = '8888';
  static const String bz = '6666';
  static const String gdt = '1012';
  static const String csj = '1013';
  static const String bd = '1018';
  static const String ks = '1019';
  static const String hw = '1020';
  static const String jd = '1021';
  static const String gm = '1022';
  static const String qm = '1030';
  static const String sigmob = '1031';
  static const String other = '9999';
}
