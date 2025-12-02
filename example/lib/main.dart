import 'dart:collection';
import 'package:adscope_sdk_example/data/common.dart';
import 'package:adscope_sdk_example/interstitial_show_page.dart';
import 'package:adscope_sdk_example/reward_video_page.dart';
import 'package:adscope_sdk_example/splash_show_page.dart';
import 'package:adscope_sdk_example/widgets/blurred_background.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk_example/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/init_data.dart';
import 'interstitial_page.dart';
import 'native_page.dart';
import 'native_unified_page.dart';
import 'splash_widget_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       initialRoute: 'SplashPage',
       routes: {
         'SplashPage':(context)=>const SplashPage(title: '开屏组件页面'),
         'SplashShowPage':(context)=>const SplashShowPage(title: '开屏show页面'),
         'SplashWidgetPage':(context)=>const SplashWidgetPage(title: '开屏页面'),
         'InterstitialShowPage':(context)=> const InterstitialShowPage(title: '插屏show页面'),
         'InterstitialPage':(context)=> const InterstitialPage(title: '插屏组件页面'),
         'NativePage':(context)=> const NativePage(title: '原生页面'),
         'NativeUnifiedPage':(context)=> const NativeUnifiedPage(title: '原生自渲染页面'),
         'RewardVideoPage':(context)=> const RewardVideoPage(title: '激励视频页面')
       },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.title});

  final String title;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late AMPSIInitCallBack _callBack;
  InitStatus initStatus = InitStatus.normal;
  late AMPSInitConfig sdkConfig;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    _callBack = AMPSIInitCallBack(
        initSuccess: () {
          debugPrint("adk is initSuccess");
          setState(() {
            initStatus = InitStatus.success;
          });
        },
        initializing: () {
          debugPrint("adk is initializing");
        },
        alreadyInit: () {
          debugPrint("adk is alreadyInit");
          setState(() {
            initStatus = InitStatus.alreadyInit;
          });
        },
        initFailed: (code, msg) {
          initStatus = InitStatus.failed;
          debugPrint("adk is initFailed");
          debugPrint("result callBack=code$code;message=$msg");
        });
    HashMap<String, dynamic> optionFields = HashMap();
    optionFields["crashCollectSwitch"] = true;
    optionFields["lightColor"] = "#FFFF0000";
    optionFields["darkColor"] = "#0000FF00";
    HashMap<String, dynamic> ksSdkEx = HashMap();
    ksSdkEx["crashLog"] = true;
    ksSdkEx["ks_sdk_roller"] = "roller_click";
    ksSdkEx["ks_sdk_location"] = "baidu";
    sdkConfig = AMPSBuilder(appId)
        .setCity("北京")
        .setRegion("朝阳区双井")
        .setCurrency(CurrencyType.currencyTypeUsd)
        .setCountryCN(CountryType.countryTypeChinaMainland)
        .setDebugSetting(true)
        .setIsMediation(true)
        //.setIsTestAd(false)
        //.setGAID("")
        .setLandStatusBarHeight(true)
        .setOptionFields(optionFields)
        .setProvince("北京市")
        .setUiModel(UiModel.uiModelDark)
        //.setUseHttps(true)
        //.setUserId("12345656")
        .setExtensionParamItems("KuaiShouSDK", ksSdkEx)
        .setAppName("Flutter测试APP")
        .setAdapterNames(["ampskuaishouAdapter", "ampsJdSplashAdapter"])
        .setAdCustomController(AMPSCustomController(
            param: AMPSCustomControllerParam(
                isCanUsePhoneState: true,
                isCanUseSensor: true,
                isSupportPersonalized: true,
                isLocationEnabled: true,
                getUnderageTag: UnderageTag.underage,
                userAgent:
                    "Mozilla/5.0 (Phone; OpenHarmony 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36  ArkWeb/4.1.6.1 Mobile",
                location: AMPSLocation(
                    latitude: 39.959836,
                    longitude: 116.31985,
                    timeStamp: 1113939393,
                    coordinate: CoordinateType.baidu)))) //个性化，传感器等外部设置
        // .setIsMediation(false)
        .setUiModel(UiModel.uiModelAuto)
        .build();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const BlurredBackground(),
        Column(children: [
          const SizedBox(height: 100,width: 0),
          ButtonWidget(
              buttonText: getInitResult(initStatus),
              backgroundColor: getInitColor(initStatus),
              callBack: () {
                //AMPSAdSDK.testModel = true;
                AMPSAdSDK().init(sdkConfig, _callBack);
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '开屏show案例页面',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'SplashShowPage');
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '开屏组件案例页面',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'SplashWidgetPage');
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '插屏show案例页面',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'InterstitialShowPage');
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '插屏组件案例页面',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'InterstitialPage');
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '点击跳转原生页面',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'NativePage');
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '点击跳转自渲染页面',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'NativeUnifiedPage');
              }
          ),
          const SizedBox(height: 20,width: 0),
          ButtonWidget(
              buttonText: '点击跳转激励视频',
              callBack: () {
                // 使用命名路由跳转
                Navigator.pushNamed(context, 'RewardVideoPage');
              }
          )
        ],),
      ],
    ));
  }

  String getInitResult(InitStatus status) {
    switch (status) {
      case InitStatus.normal:
        return '点击初始化SDK';
      case InitStatus.initialing:
        return '初始化中';
      case InitStatus.alreadyInit:
        return '已初始化';
      case InitStatus.success:
        return '初始化成功';
      case InitStatus.failed:
        return '初始化失败';
      }
  }

  Color? getInitColor(InitStatus initStatus) {
    switch (initStatus) {
      case InitStatus.normal:
        return Colors.blue;
      case InitStatus.initialing:
        return Colors.grey;
      case InitStatus.alreadyInit:
        return Colors.green;
      case InitStatus.success:
        return Colors.green;
      case InitStatus.failed:
        return Colors.red;
    }
  }
}
