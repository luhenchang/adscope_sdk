


import 'dart:io';

var appId = Platform.isAndroid ? "14657" :  Platform.isIOS ? "14659" : "55819";
var splashSpaceId = Platform.isAndroid ? '15341' : Platform.isIOS ? "15351" : "124388";
var interstitialSpaceId = Platform.isAndroid ? '15347' : Platform.isIOS ? "15352" : "124578";
var nativeSpaceId = Platform.isAndroid ? '15349' : Platform.isIOS ? "15354" : "124579";
var unifiedSpaceId = Platform.isAndroid ? '117723' : Platform.isIOS ? "117907" : "124580";
var rewardVideoSpaceId = Platform.isAndroid ? '15350': Platform.isIOS ? "15355" : "124581";
var bannerSpaceId = Platform.isAndroid ? '15348': Platform.isIOS ? "15353" : "124583";
var drawSpaceId = Platform.isAndroid ? '116123': Platform.isIOS ? "116122" : "124582";

var timeOut = 5000;//广告请求超时时长，建议5000毫秒,该参数单位为ms