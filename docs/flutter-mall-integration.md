# Flutter 穿山甲商城接入文档

更新日期：2026-11-05

适用平台：Android、iOS；适用代码：本仓库当前商城实现。

本文将[钉钉《穿山甲商城页设计文档》](https://alidocs.dingtalk.com/i/nodes/Qnp9zOoBVBLbxLEAHe7ra3LB81DK0g6l)中的金刚位、激励任务接入方式转换为 Flutter 用法，并补充当前插件提供的商城频道、高商词多商品和单商品能力。后面三种方式依据当前插件与原生 SDK 接口整理，不代表钉钉原文包含这些章节。

## 1. 选择接入方式

| 业务场景 | Flutter 接口 | 广告位要求 |
| --- | --- | --- |
| 金刚位入口 | `AMPSInterstitialAd`，或现有 `AMPSRewardVideoAd` | 对应类型的商城广告位；入口图标和按钮由业务绘制 |
| 商城激励任务 | `AMPSRewardVideoAd` + `AdOptions.mallReward` | 开通商城任务的激励广告位 |
| 商城频道 | `AMPSMallAd` + `AMPSMallView` | 支持商城页面的自渲染广告位 |
| 高商词多商品（搜索结果页） | `AMPSMallAd` + `mallQuery` + `AMPSMallView` | 多商品商城广告位 |
| 高商词单商品 | `AMPSNativeAd`，`NativeType.unified` + `mallQuery` + `UnifiedWidget` | 普通单商品自渲染广告位，后台不勾选商城页 |

多商品结果页由 SDK 商城视图展示。单商品走普通自渲染布局，两者应使用各自广告位。

## 2. SDK 和工程准备

### Android

当前示例使用以下配套版本：

| 依赖 | 版本 |
| --- | --- |
| AMPS 核心 / common | `5.1.3.6` |
| AMPSGroMoreAdapter | `5.1.7814.1` |
| 穿山甲 SDK | `7.8.1.4` |

插件对 AMPS AAR 使用 `compileOnly`，宿主工程需要打包对应核心、common、GroMore 适配器和渠道 SDK。可参考 [Android 示例依赖](../example/android/app/build.gradle)及其 `libs` 目录，避免同时引入重复或不配套的 AAR。

本仓库示例通过 `example/android/gradle.properties` 中的 `adscopeGroMoreOnly=true` 仅打包 GroMore 相关依赖，方便商城联调；该配置属于示例工程。

### iOS

在宿主 `ios/Podfile` 的应用 target 中配置：

```ruby
pod 'AMPSAdSDK', '5.1.3.8'
pod 'AMPSGMAdapter', '5.1.7805.1'
```

渠道 SDK 及基础库由 Pod 依赖解析，具体解析版本以 `Podfile.lock` 为准。项目示例最低系统为 iOS 13.0。

```sh
flutter pub get
cd ios
pod install
open Runner.xcworkspace
```

使用 `.xcworkspace` 打开 Xcode。遇到 `The sandbox is not in sync with the Podfile.lock`，先检查 `Pods/Manifest.lock` 是否存在，并重新执行 `pod install`。

当前 [iOS 示例 Podfile](../example/ios/Podfile)默认只启用 GroMore。需要恢复示例中的其他渠道时，执行 `ADSCOPE_GROMORE_ONLY=0 pod install`；商城广告位本身仍需配置可返回商城的渠道。

### Flutter 初始化

```dart
import 'package:adscope_sdk/amps_sdk_export.dart';

void initializeAds(String appId) {
  AMPSAdSDK.init(
    AMPSBuilder(appId).build(),
    AMPSIInitCallBack(
      initSuccess: () { /* SDK 就绪，可以请求广告 */ },
      alreadyInit: () { /* SDK 已初始化，可以请求广告 */ },
      initializing: () { /* 等待初始化结束 */ },
      initFailed: (code, message) { /* 显示失败原因，不继续请求广告 */ },
    ),
  );
}
```

先完成 SDK 初始化，再创建和加载广告。App ID、广告位 ID 必须对应正确的平台和应用。

## 3. 金刚位入口

钉钉文档中的金刚位复用现有插屏或激励广告接入，入口由媒体自行开发。Flutter 不需要额外的商城入口原生接口。

以下为插屏入口的最小调用流程；页面中需保留 `ad` 引用，退出时销毁：

```dart
import 'package:adscope_sdk/amps_sdk_export.dart';

Future<AMPSInterstitialAd> loadMallEntry(String spaceId) async {
  late final AMPSInterstitialAd ad;
  ad = AMPSInterstitialAd(
    config: AdOptions(spaceId: spaceId),
    mCallBack: AdCallBack(
      onRenderOk: () async {
        try {
          await ad.showAd();
        } catch (error) {
          // 提示展示失败，恢复入口按钮。
        }
      },
      onLoadFailure: (code, message) { /* 恢复入口按钮 */ },
      onRenderFailure: () { /* 恢复入口按钮 */ },
      onAdShowError: (code, message) { /* 恢复入口按钮 */ },
      onAdClosed: () { /* 商城关闭，恢复页面操作 */ },
    ),
  );
  await ad.load();
  return ad;
}
```

业务图标点击后调用此流程即可。普通金刚位接入不需要设置 `mallReward`；若业务需要金币和浏览时长任务，使用下一节的商城激励流程。

完整入口与防重复点击处理见 [gm_mall_entry_page.dart](../example/lib/gm_mall_entry_page.dart)。

## 4. 商城激励任务

商城任务参数在创建激励实例时设置，加载、展示和奖励回调沿用激励视频接口。

```dart
import 'package:adscope_sdk/amps_sdk_export.dart';

Future<AMPSRewardVideoAd> loadMallReward(String spaceId) async {
  late final AMPSRewardVideoAd ad;
  ad = AMPSRewardVideoAd(
    config: AdOptions(
      spaceId: spaceId,
      mallReward: const AMPSGMMallRewardConfig(
        gold: '20',
        duration: '10',
      ),
    ),
    adCallBack: RewardVideoCallBack(
      onLoadSuccess: () async {
        try {
          if (await ad.isReadyAd()) await ad.showAd();
        } catch (error) {
          // 提示展示失败，允许重试。
        }
      },
      onLoadFailure: (code, message) { /* 处理加载失败 */ },
      onAdReward: () { /* 根据业务规则处理激励奖励 */ },
      onServerRewardFailed: (code, message) { /* 处理服务端奖励失败 */ },
      onVideoPlayError: (code, message) { /* 处理播放失败 */ },
      onAdClosed: () { /* 恢复页面操作 */ },
    ),
  );
  await ad.load();
  return ad;
}
```

| Flutter 字段 | 原生 name | 类型 / 含义 |
| --- | --- | --- |
| `mallReward.gold` | `ec_reward_gold` | `String?`，任务奖励金币数 |
| `mallReward.duration` | `ec_reward_duration` | `String?`，任务浏览时长，单位秒 |

字段会去除首尾空白，空值忽略；全部为空时不附加商城任务。有效数值和任务资格由渠道及后台配置决定。

插件自动组装标准 `name/value` JSON 数组，业务无需自行拼接：

```json
[
  {"name": "ec_reward_gold", "value": "20"},
  {"name": "ec_reward_duration", "value": "10"}
]
```

与钉钉原生用法的对应关系：Android 写入 `extraDataMap[AMPSConstants.AMPS_ADN_GM_SHOP_EXTRA_DATA]`；iOS 写入 `customExtraDict["GM"]["userData"]`。

任务参数在实例创建时生效。更换任务参数时，销毁旧广告并重新创建，不要通过 Android 的 `setExtraDataMap()` 动态修改商城任务，该方法会整体覆盖扩展 Map。

`await ad.load()` 返回表示加载调用已发出，广告是否加载完成应以 `onLoadSuccess` / `onLoadFailure` 为准。页面退出时调用 `await ad.destroy()`；未使用的预加载实例也需要释放。

完整页面见 [gm_mall_reward_page.dart](../example/lib/gm_mall_reward_page.dart)：单按钮加载并展示，保留参数、胜出渠道和回调日志。

## 5. 商城频道和高商词多商品

两种场景共用嵌入式商城接口：频道使用频道广告位；高商词多商品使用专用广告位并设置 `mallQuery`。

### 创建、加载和挂载

```dart
import 'package:adscope_sdk/amps_sdk_export.dart';

AMPSMallAd createMall({
  required String spaceId,
  String? query,
  required void Function(String adId) onLoaded,
  required void Function(int code, String message) onFailure,
}) {
  return AMPSMallAd(
    config: AdOptions(
      spaceId: spaceId,
      mallQuery: query,
      // 频道奖励任务需开通对应能力后再设置：
      // mallReward: const AMPSGMMallRewardConfig(gold: '20', duration: '10'),
    ),
    onLoad: AMPSNativeAdListener(
      loadOk: (ids) {
        if (ids.isEmpty) {
          onFailure(-1, '未返回广告');
        } else {
          onLoaded(ids.first);
        }
      },
      loadFail: onFailure,
    ),
    onEvent: (adId, code, info) {
      // 接收渠道原始事件；按平台、渠道定义解释 code 和 info。
    },
  );
}
```

创建后调用 `await mall.load()`。在 `loadOk` 中保存返回的 `adId`，并使用 `setState` 更新页面。加载商城频道时可不传 `query`；加载高商词多商品时传入非空搜索词，例如 `手机`。

在 Widget 的 `build` 中挂载：

```dart
// mall 为上面创建的 AMPSMallAd，adId 为 loadOk 返回值。
// visible 为业务维护的页面可见状态。
SizedBox(
  width: double.infinity,
  height: 500,
  child: AMPSMallView(ad: mall, adId: adId, visible: visible),
)
```

- 父布局必须提供有限宽高，同一 `adId` 同时只挂载一个商城组件。
- 广告加载成功和商城视图创建成功是两个阶段。组件挂载时才向 SDK 获取视图；SDK 未返回商城视图时仍可能触发失败回调，业务应移除组件并显示失败状态。
- 预加载期间只加载广告，不提前创建商城视图；查询信息也不会创建视图。
- 组件自动处理 App 前后台。路由覆盖、Tab 切换等业务遮挡需设置 `visible: false`，恢复后设为 `true`。
- 页面退出时移除组件并销毁广告：`await mall.destroy()`。异步回调更新 UI 前应检查 `mounted`，重新请求时应忽略旧实例回调。

完整 State、显示隐藏和释放流程见 [gm_mall_page.dart](../example/lib/gm_mall_page.dart)。其中 `GMMallPage()` 为频道模式，`GMMallPage(searchMode: true)` 为高商词多商品模式。

### 读取商城信息

```dart
final Map<String, dynamic> info = await mall.getMallInfo(adId);
final extras = info['extras'];
```

| 返回字段 | 含义 |
| --- | --- |
| `supportsMall` | 当前广告的商城能力标识；Android 首次创建视图前为 false，不能据此提前判定不支持 |
| `viewCreated` | 插件是否已经取得商城视图 |
| `isValid` | 原生广告 / 商城视图的有效性状态，按平台 SDK 返回 |
| `extras` | SDK 返回的扩展 Map，允许为空，字段结构以实际渠道为准 |

该接口用于读取状态和渠道扩展字段，不承诺返回商城内全部商品，也不保证包含价格、图片等指定字段。多商品列表由商城视图自身展示。示例的“读取商城信息”按钮会弹窗展示原始结果，`extras` 为空时给出提示。

`onEvent` 透传原始渠道事件。iOS 当前渠道中的事件码 `2` 对应 `SendFeedReward`；Android 事件码按 Android 渠道定义解释，不应跨平台直接套用。业务依据对应事件、任务规则及校验结果处理奖励。

## 6. 高商词单商品

使用普通自渲染接口，设置 `NativeType.unified` 与 `mallQuery`，不使用 `AMPSMallAd` 或 `AMPSMallView`。

```dart
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:adscope_sdk/common.dart';

AMPSNativeAd createProduct({
  required String spaceId,
  required String query,
  required void Function(String adId) onLoaded,
}) {
  return AMPSNativeAd(
    nativeType: NativeType.unified,
    config: AdOptions(spaceId: spaceId, mallQuery: query, adCount: 1),
    mCallBack: AMPSNativeAdListener(
      loadOk: (ids) {
        if (ids.isNotEmpty) onLoaded(ids.first);
      },
      loadFail: (code, message) { /* 展示失败原因 */ },
    ),
  );
}
```

创建后调用 `await product.load()`。加载成功后，使用普通 `UnifiedWidget` 和 `NativeUnifiedWidget` 布局，通过原生自渲染组件绑定标题、图片或视频、按钮等内容，保留曝光与点击处理。

```dart
final extras = await product.getUnifiedExtras(adId);
final pattern = await product.getUnifiedPattern(adId);
final images = await product.getUnifiedImages(adId);
```

`getUnifiedExtras(adId)` 返回指定实例内该条广告的扩展字段，允许为空；不要与请求级 `getMediaExtraInfo()` 混用。字段以渠道实际返回为准，不预设固定商品数据结构。

页面退出时销毁实例。收到 `onCarouselAdLoad` 时，用当前 `adId` 重新读取素材并刷新布局。可直接参考完整实现 [gm_mall_product_page.dart](../example/lib/gm_mall_product_page.dart)。

## 7. 扩展参数兼容

建议使用 `mallQuery`、`mallReward` 显式字段。插件也兼容现有 `customExtraMap['GM']['userData']`，以及 Android 商城专用 `extraDataMap` 中的原始配置。

插件合并时保留其他扩展字段；显式 `mallQuery` / `mallReward` 覆盖同名 `query` / 金币 / 时长项。避免在多个位置重复配置同一业务参数。

## 8. 测试 App ID 与广告位

以下为本项目联调配置；正式接入请替换为业务自己的 App ID 与广告位，不要混用平台。

| 项目 | Android | iOS |
| --- | --- | --- |
| App ID | `62720` | `74663` |
| 商城激励 | `165828` | `165691` |
| 金刚位插屏 | `165839` | `165690` |
| 商城频道 | `165835` | `165689` |
| 高商词多商品 | `165836` | `165692` |
| 高商词单商品 | `165837` | `165838` |

配置来源：[example/lib/data/common.dart](../example/lib/data/common.dart)。

示例入口：**首页 → 商城测试入口**，二级页包含上述五种测试按钮。高商词默认 `手机`，可修改；商城激励默认金币 `10`、浏览时长 `2` 秒，可修改。

接入时依次确认：初始化成功、广告加载成功、商城挂载或广告展示成功、曝光点击及关闭回调正常；激励场景还需验证任务完成后的奖励回调。单元测试通过不等于真实商城展示和奖励链路已完成联调。

## 9. 常见问题

| 现象 | 检查方式 |
| --- | --- |
| `MALL_UNSUPPORTED` | Android 运行时 SDK 缺少商城常量，核对实际打包的核心、common 和适配器版本 |
| `Winner has no embedded mall view` / `Refreshed ad has no embedded mall capability` | 胜出广告未提供商城能力，检查广告位类型、后台配置和渠道 |
| `Mall placement returned no embedded view` / 未返回商城视图 | 加载成功但 SDK 未提供可挂载视图，检查商城专用广告位和渠道能力 |
| `210401` 或“未发现任何广告源” | 核对 App ID、广告位归属及后台广告源配置 |
| 点“读取商城信息”没有商品明细 | 查看 `extras`；渠道可能不返回字段，商品列表以 SDK 页面展示为准 |
| Tab 不可见时商城还在运行 | 业务切换时设置 `AMPSMallView.visible=false` |
| 修改金币或时长未生效 | 销毁并重新创建广告实例后再请求 |
| Xcode 提示 Podfile.lock 不同步 | 在宿主 `ios` 目录执行 `pod install`，使用 `.xcworkspace` 运行 |

当前 AMPS 未提供独立竞价引流流程的 Flutter 接口。原生 SDK 也未公开可独立调用的默认商城兜底页接口，加载失败时由业务提供占位或重试入口。
