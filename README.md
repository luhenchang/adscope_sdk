# adscope_sdk

A new Flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## [0.2.9] - 2026-11-05

## [0.2.8] - 2026-10-30

## [0.2.7] - 2026-10-09

## [0.2.6] - 2026-09-21

## [0.2.5] - 2026-09-01

## [0.2.4] - 2026-08-20

## [0.2.3] - 2026-08-20

## [0.2.2] - 2026-07-14

## [0.2.1] - 2026-07-08

## [0.2.0] - 2026-07-06

## [0.1.9] - 2026-07-06

## [0.1.8] - 2026-06-09

## [0.1.7] - 2026-06-04

## [0.1.6] - 2026-05-28

## [0.1.5] - 2026-05-15

## [0.1.4] - 2026-05-14

## [0.1.3] - 2026-05-13

## [0.1.0] - 2026-04-17

## [0.1.0] - 2026-03-27

## [0.0.9] - 2026-03-24

## [0.0.8] - 2026-03-20

## [0.0.7] - 2026-02-11


## [0.0.6] - 2026-02-06

## [0.0.4] - 2026-01-19

###  official release

## [0.0.3] - 2025-01-16

### Second official release

## [0.0.2] - 2025-12-24

### Second official release
- The initial release of the software.

## [0.0.1] - 2025-12-23

### First official release
- The initial release of the software.

## 穿山甲商城（Android / iOS）

完整说明见 [Flutter 商城接入文档](docs/flutter-mall-integration.md)，包含五种方式、配置、参数、生命周期与测试广告位。

商城金刚位直接复用现有插屏、激励视频广告，入口由业务方开发。
商城激励任务通过创建激励视频时的统一配置传入：

```dart
import 'package:adscope_sdk/amps_sdk_export.dart';

final ad = AMPSRewardVideoAd(
  config: AdOptions(
    spaceId: '商城激励广告位 ID',
    mallReward: const AMPSGMMallRewardConfig(
      gold: '20',      // ec_reward_gold：任务奖励金币数
      duration: '10',  // ec_reward_duration：浏览时长，单位秒
    ),
  ),
  adCallBack: RewardVideoCallBack(
    onLoadSuccess: () { /* 加载成功后调用 ad.showAd() */ },
    onAdReward: () { /* 沿用现有激励回调 */ },
  ),
);
ad.load();
```

- 两个字段均可选，去除首尾空白后忽略空值；全部为空时退化为普通广告请求。
- 插件生成标准 JSON 数组。Android 合并到
  `extraDataMap[AMPSConstants.AMPS_ADN_GM_SHOP_EXTRA_DATA]`；iOS 合并到
  `customExtraDict["GM"]["userData"]`。显式商城配置覆盖同名商城键，其他扩展字段保留。
- 使用支持商城的 AMPS SDK 和穿山甲 / GroMore 适配器及对应广告位。
  插件编译包和 Android 示例已更新为核心/common `5.1.3.6`，示例 GM/CSJ
  适配器为 `5.1.7814.1`、穿山甲为 `7.8.1.4`。插件使用 compileOnly，宿主仍需包含这些依赖。
  插件运行时读取新版 SDK 的公开常量，缺失时由 `onLoadFailure` 报告
  `-1` 和包含 `MALL_UNSUPPORTED` 的错误信息；未设置失败回调时，
  `await ad.load()` / `await ad.preLoad()` 抛出 `PlatformException`。
- 配置在激励实例创建时生效；更改任务需销毁旧实例并创建新实例。
  Android 的 `setExtraDataMap` 仍会整体覆盖扩展 Map，请勿用它更新商城任务。
- `mallReward` 用于 Android / iOS 商城激励和已开通任务的商城频道；普通插屏及鸿蒙端不使用该参数。
- 示例激励视频页面提供商城任务开关，只影响随后创建的实例。
- 示例入口为「首页 → 商城测试入口 → 商城激励测试」。填写广告位、金币和浏览时长后，
  点击「加载并展示商城激励」；页面保留本次参数、胜出渠道及回调日志。

iOS 示例的 SDK / 适配器版本固定在
[`example/ios/Podfile`](example/ios/Podfile)。已验证 AMPSAdSDK `5.1.3.8`
和 AMPSGMAdapter `5.1.7805.1`：商城 JSON 经 SDK 配置和真实 GM 激励适配器
传入 `BUAdSlot.userData`，并保留其他扩展字段。该参数链路有模拟器测试覆盖，
测试拦截广告构造，不请求广告库存；实际展示仍需有效商城广告位。

接口依据：[穿山甲商城页设计文档](https://alidocs.dingtalk.com/i/nodes/Qnp9zOoBVBLbxLEAHe7ra3LB81DK0g6l)。

## Android / iOS 嵌入式商城

除普通插屏/激励视频金刚位入口外，支持将商城直接挂载到 Flutter 页面：

```dart
final mall = AMPSMallAd(
  config: AdOptions(
    spaceId: '商城自渲染广告位 ID',
    mallQuery: '手机', // 可选；高商词搜索结果页必传
    // mallReward: AMPSGMMallRewardConfig(gold: '20', duration: '10'), // 可选频道任务
  ),
  onLoad: AMPSNativeAdListener(
    loadOk: (adIds) { /* 保存 adIds.first，用于创建 AMPSMallView */ },
    loadFail: (code, message) { /* 显示失败提示 */ },
  ),
  onEvent: (adId, code, info) { /* 原始商城渠道事件 */ },
);
await mall.load();

// 加载成功后，在有明确宽高的布局中使用：
// SizedBox(height: 500, child: AMPSMallView(ad: mall, adId: adId));
// 读取商品扩展字段：await mall.getMallInfo(adId);
// 页面退出时：await mall.destroy();
```

- Android 使用核心/common `5.1.3.6` 与 GM/CSJ `5.1.7814.1`；iOS 使用核心
  `5.1.3.8` 与 GM `5.1.7805.1`。使用相应商城广告位与后台配置。
- 加载与信息查询不获取商城视图；`AMPSMallView` 挂载时才取视图，支持预加载。
- 使用 SDK 的商城 `nativeExpressAdView`，不混用普通模板 `nativeExpressView`。
  胜出渠道不支持商城或未提供视图时明确回调失败。
- 同一个 adId 同时只挂载一个 `AMPSMallView`，组件自动处理 App 前后台暂停恢复。
  路由遮挡或 Tab 切换时，业务应设置 `visible: false`，恢复时设为 `true`。
- `getMallInfo` 返回 `supportsMall`、`viewCreated`、`isValid`、`extras`。Android 无独立商城能力查询，
  `supportsMall` 在视图创建前为 false，此时不代表广告不支持商城；读取 `extras` 不触发视图创建。
  原始事件由 `onEvent` 透传，
  当前 iOS 的 `SendFeedReward` 和 Android 7.8.1.4 的 `AD_EVENT_FEED_REWARD` 均为 `2`，
  Flutter 使用 `code == AMPSMallEventCode.feedReward` 验证浏览任务奖励事件，其他事件不作为奖励成功。实际金币入账由业务处理。
  完整验证步骤见 [商城接入文档](docs/flutter-mall-integration.md#验证浏览金币任务的奖励事件)。
- 示例首页的「商城测试入口」进入二级页，提供商城激励、金刚位插屏、商城频道、
  高商词多商品、高商词单商品五个测试入口。
- 频道和搜索结果页使用同一个嵌入接口，后台广告位及 query 决定内容；频道任务参数需开通对应能力。
- 金刚位无需新增桥接，示例只复用现有插屏/普通激励视频方法。


## 高商词单商品（Android / iOS）

单商品使用普通自渲染广告位（后台不勾选商城页），不创建 `AMPSMallView`：

```dart
// NativeType 定义于 package:adscope_sdk/common.dart
final product = AMPSNativeAd(
  nativeType: NativeType.unified,
  config: AdOptions(spaceId: '单商品自渲染广告位 ID', mallQuery: '手机', adCount: 1),
  mCallBack: AMPSNativeAdListener(loadOk: (ids) { /* 使用普通 UnifiedWidget 渲染 */ }),
);
await product.load();
// 加载成功后：await product.getUnifiedExtras(adId); // 商品/价格等渠道原始字段
// 页面退出：await product.destroy();
```

`getUnifiedExtras(adId)` 返回该条广告的 Map，按实例隔离，不与请求级 `getMediaExtraInfo()` 混用。
字段允许为空；具体字段以渠道返回为准。示例首页的「高商词单商品测试」提供关键词、
普通自渲染布局、商品字段展示和销毁。金币、时长和 query 统一编码为 name/value JSON；
显式 `mallQuery`/`mallReward` 覆盖同名扩展项，其余扩展字段保留。

对照 [AMPS 商城页设计文档](https://alidocs.dingtalk.com/i/nodes/Qnp9zOoBVBLbxLEAHe7ra3LB81DK0g6l)
与 [穿山甲商城接入文档](https://bytedance.larkoffice.com/docx/EUs9dAKIhoAEpjxhCX5cS58dnrb)：

| 方式 | Flutter 接口 |
| --- | --- |
| 金刚位 | 现有插屏/普通激励；仅业务入口 |
| 激励任务 | `AMPSRewardVideoAd` + `AdOptions.mallReward` |
| 商城频道 | `AMPSMallAd` + `AMPSMallView`；支持频道任务、显隐、原始事件 |
| 高商词搜索结果页 | 嵌入式商城 + `mallQuery` |
| 高商词单商品 | 普通 unified + `mallQuery` + `getUnifiedExtras(adId)` |

原生 SDK 未公开独立默认商城兜底页接口，加载失败时由业务展示本地占位。
AMPS 当前未提供独立竞价引流流程，不提供对应 Flutter 接口。
自动化测试不请求真实广告库存，真机展示和奖励仍需有效广告位联调。


### Android 商城真机联调

当前示例 `example/android/gradle.properties` 设置 `adscopeGroMoreOnly=true`，
APK 只包含 AMPS 核心/common、GroMore 适配器及穿山甲融合 SDK，其他渠道 AAR 保留在本地但不打包。
改为 `false` 可恢复全部本地渠道；需使用同一发行包中的配套渠道版本。

本次启动联调曾发现旧 ASNP 5.5.0.5 与 common 5.1.3.6 不兼容：缺少
`AesUtil.IAESConfig`。示例 ASNP/BZ/YT 已同步为用户 5.1.3.6 包中的配套版本，
在 GroMore 单渠道模式下均不打包。

iOS 商城联调当前也默认仅接入 GroMore，使用 AMPSAdSDK `5.1.3.8`、AMPSGMAdapter `5.1.7805.1`。
在 `example/ios` 执行 `ADSCOPE_GROMORE_ONLY=0 pod install` 可恢复完整渠道组合；
切换渠道后应清理旧 iOS App 产物，避免已移除渠道的动态框架残留。
