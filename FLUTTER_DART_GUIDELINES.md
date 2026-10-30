# Flutter 代码规范（Dart）

> 适用于 Flutter 应用及插件的 Dart 层。强制规则保证正确性；建议规则允许按模块规模调整。
> 仓库尚未提供 `00-通用总纲.md`，本文暂独立使用；接入总纲时应核对冲突。
> 增量应用于新增及修改代码，不为风格批量改名、移动文件、改变公开 API 或引入新框架。

## 一、命名规范

### 类与组件

- 类、枚举、typedef、具名扩展使用 `UpperCamelCase`；Widget 以语义命名，私有标识符以 `_` 开头。Dart 私有范围为 library，匿名扩展无需命名。
- 不加冗余后缀：`_CloseButton` 而非 `_CloseButtonWidget`；除非与 SDK 组件重名冲突。

```text
// 正例
// 仅展示命名，不是完整 Widget 实现。
SplashAdView
_AdLoadingIndicator

// 反例
SplashAdViewWidget // 冗余后缀
```

### 方法与变量

- 方法、变量、参数小驼峰；布尔值使用清晰的正向语义，如 `isLoading`、`hasAd`、`canShow`、`enableLog`。避免双重否定；`notReady` 是单次否定，但通常优先用 `isReady`。
- 同一模块统一 `load`、`preload`、`show`、`request`、`fetch` 的含义；名称不决定异步实现，结果交付方式由签名和文档说明。既有公开 SDK 名称保持兼容。
- 新回调优先 `on` + 事件，如 `onAdLoaded`、`onAdFailed`；成功、失败可以使用独立回调，不强制所有回调都采用“数据、错误”参数形式。
- 常量小驼峰，如 `const maxRetryCount = 3;`；就近放在所属模块，跨模块共享时再集中管理。
- 多个同类型参数、布尔开关及可选配置优先命名参数；必填命名参数用 `required`。不为参数数量强改既有公开签名。

## 二、目录与文件组织

- 文件名小写下划线：`splash_ad_view.dart`、`reward_ad_controller.dart`。
- 应用按 feature 分目录；插件可按 controller、model、platform、widget 等职责组织，沿用现有结构。`lib/` 根可保留公开入口及小型库文件，不为规范批量搬迁。
- 一文件围绕一个职责组织；紧密相关的模型、枚举、Widget 及私有辅助类型可同文件，不强制“一文件一公开类”。
- import 顺序：`dart:` → `package:` → 相对 URI，组间空行，组内按字母排序。Flutter、第三方及本包的 package 导入属于同一组。
- 同包 `lib/` 内优先相对导入；从 `test/`、`example/` 等访问包的公开库时用 `package:`。既有模块统一 package 导入时可沿用，不混用不同 URI 导入同一库，不通过 `../lib/` 跨越边界。
- 业务职责与 UI 分离：复杂状态、重复逻辑、异步编排适合抽 Controller/Service；简单局部状态可留在 State。行数仅作为评审信号，不作为强制拆分类的依据。

## 三、注释规范

- 公开 API 使用 `///` 说明用途及必要的参数约束、单位、返回值、错误、资源所有权和生命周期；不机械重复签名。
- 明确 Future 表示“平台调用完成”还是“广告加载完成”；每次 load 的终态成功/失败应互斥，展示、点击等事件可多次发生。
- 说明重复加载是拒绝、合并、排队还是并发，及销毁后是否停止回调；不要把原生线程与 Dart isolate 混为一谈，只承诺实现能够保证的行为。
- 复杂逻辑（时序、竞态、workaround）实现处写中文 `//` 注释解释 why。

```dart
/// 读取并校验广告位 ID；返回空值或类型错误时抛出 [FormatException]。
///
/// 不使用空字符串掩盖无效配置。
String readPlacementId(Map<String, dynamic> json) {
  final value = json['placementId'];
  if (value is! String || value.isEmpty) {
    throw const FormatException('placementId must be a non-empty string');
  }
  return value;
}
```

## 四、格式化规范

- 缩进：2 空格，禁止 Tab；**提交前必须过 `dart format`**，格式争议以 format 输出为准。
- 默认以 80 列为格式化目标，不机械限制每行必须小于 80；换行、尾随逗号及可配置行宽以项目锁定 SDK 的 formatter 为准。
- 可行时使用 `const` 构造及不可变字段，减少重复创建及不必要的子树更新，不承诺 const 能消除所有 rebuild。
- 使用新语法、API、lint 前核对最低版本及 CI/鸿蒙工具链。当前插件声明 Dart `>=2.19.0 <4.0.0`、Flutter `>=3.7.0`，example 声明 Dart `>=3.4.0`；示例可用的新语法不能直接下放到插件 `lib/`。

## 五、对外接口规范

- 对外维护明确的 export 入口，可按模块提供多个入口。本仓库已有 `adscope_sdk.dart`、`amps_sdk_export.dart` 等入口，保持兼容；新内部实现优先放 `lib/src/`。
- 使用方不得导入其他包的 `lib/src/`；`implementation_imports` 检查跨包内部导入，同包实现及测试可访问自己的 src。公开签名所需类型应从公开入口可访问。
- 一次性异步操作优先 Future，连续事件按既有架构使用回调或 Stream；区分请求终态和生命周期事件，不强制同一套回调次数。
- 异步方法优先返回 `Future<void>`，避免 `void async` 使调用方无法等待和捕获错误；框架固定 void 回调可调用独立 Future 方法，并安排错误处理。
- 平台通道集中在基础设施层，允许按职责拆分服务；不泄漏到业务 Widget 或公开签名，不强制所有功能塞入一个服务类。
- 通道名称、方法、字段集中维护，明确数字类型、尺寸单位、错误码及跨平台差异；多实例回调必须按实例路由，避免覆盖其他实例监听。
- 修改协议和生命周期时检查 Android、iOS、HarmonyOS；不支持的平台明确报错，不静默成功。
- 废弃 API 使用 `@Deprecated('替代方法')` 并提供迁移说明，按版本兼容策略移除。

```dart
// 接口声明示意，具体实现遵循相同的废弃及迁移契约。
abstract class RewardAdLoader {
  @Deprecated('使用 preloadRewardAd 替代；移除计划见迁移文档')
  Future<void> loadRewardAd(String placementId);

  Future<void> preloadRewardAd({required String placementId});
}
```

```dart
// 反例：业务方直接依赖内部实现
import 'package:amps_ad_sdk/src/internal/splash_controller.dart';
```

## 六、集合与空安全（强制）

- 不对未经验证的 JSON、平台返回值或生命周期对象用 `!`。仅在有明确不变量且无法合理建模时使用并说明依据；编译器已证明非空时通常无需 `!`。
- 不可信字段先检查类型；`as String? ?? ''` 不能处理数字等错误类型。默认值只用于允许缺省的字段，必要字段错误必须显式失败。
- 随机下标访问需保证 `index >= 0 && index < list.length`；集合非空不代表任意下标合法。常规遍历优先 `for-in`，固定长度数据需校验最小长度。
- 空集合检查用 `isEmpty` / `isNotEmpty`；对象为 null 与集合为空是不同状态，nullable 集合先处理 null。
- 通常以空集合表示“成功但无数据”，不得掩盖请求失败；null 若表达“未加载”等独立含义需明确建模或说明。
- 不暴露内部可变集合；需要不可修改的独立快照时用 `List.unmodifiable`，需要实时只读视图时明确其会随底层数据变化。
- JSON/通道字段在 `fromJson`、`fromMap` 等边界统一校验、处理缺省值，避免每个使用点重复修补。

```dart
// 正例
T? elementAtOrNull<T>(List<T> items, int index) {
  if (index < 0 || index >= items.length) return null;
  return items[index];
}

// 反例：未经校验的类型强转和下标访问
final name = json['name'] as String;
final ad = ads[index];
```

## 七、禁止事项（高频坑位）

| # | 规则 | 原因 |
|---|------|------|
| 1 | build 本身不得发请求、调用 setState、修改业务状态或反复创建长期资源；onPressed 等事件回调可响应用户操作 | 构建无副作用，避免重建循环 |
| 2 | 跨 await 后，访问 State/更新 UI 前检查 mounted；使用局部或外部传入的 context 时检查该 context 的 mounted。mounted 不能替代取消、解绑或旧请求结果过滤 | 防止销毁后更新及旧结果覆盖新状态 |
| 3 | Future/Stream 错误在能够恢复、转换或展示的边界处理，允许向上传播；禁止空 catch。主动不等待的 Future 也必须安排错误处理 | 避免未处理异常或吞错，不机械给每个 await 加 catch |
| 4 | Column 内 ListView 需 Expanded/Flexible 或明确高度；长列表惰性构建，不为消除报错滥用 shrinkWrap | 保证约束和滚动性能 |
| 5 | 列表使用稳定业务 ID 作为 Key；GlobalKey 用于框架确需的身份、State 访问或跨父节点迁移，不在 build 中反复创建 | 保持状态身份，避免冲突 |
| 6 | 平台通道按职责封装于基础设施层，禁止 Widget 拼协议；通道名/方法名集中管理 | 隔离平台细节，避免巨型服务类 |
| 7 | 通道边界允许 codec 支持的 Map/List/基础类型；复杂或重复结构用类型化模型统一转换、校验，不为单个 ID 强建模型或强制转 JSON 字符串 | 校验边界，避免无益封装 |
| 8 | 创建者负责释放 Controller、订阅、FocusNode、Timer 和监听；外部传入/共享资源按所有权处理。State.dispose 保持同步，异步清理需处理错误且不能更新 UI | 避免泄漏及误销毁共享资源 |
| 9 | 统一项目日志工具和等级开关；临时 debugPrint 也需受调试开关约束，不输出密钥、设备标识等敏感数据 | 控制日志和敏感信息暴露 |
| 10 | 同一业务状态保持单一可信来源，新模块跟随既有方案；不同职责可同时使用局部 setState 和共享状态方案 | 避免状态源冲突，不强推架构重构 |
| 11 | setState 回调保持同步，只包含状态变更，异步工作放在回调外 | 避免生命周期和更新时序不明确 |
| 12 | 广告 SDK 对象与单条广告资源分开管理；重载是否替换旧广告按实现和底层 SDK 契约判断，不能以新本地 adId 推断素材必然不同 | 避免加载和销毁时序错误 |

## 八、检查与落地

- Markdown 不会自动启用 lint。新增规则需显式修改对应 `analysis_options.yaml`，确认当前 SDK 支持，并逐步处理存量问题；本文不代表已完成全仓整改。
- 通道转换、实例路由、请求竞态优先单元测试；Widget 测试覆盖状态及销毁。平台 SDK 的加载和展示需集成测试或真机验证。
- 插件与 example 是两个 package，分别在各自根目录运行依赖、分析和相关测试，按改动选择检查项：

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

- 格式命令仅传入实际存在的目录。仅文档变更检查内容、链接和 diff，无需构建 App。
- 涉及平台交互时记录验证平台、SDK 版本、成功/失败路径及未覆盖项，不以 Dart 静态检查代替真机验证。

## 参考

- [Effective Dart：风格](https://dart.dev/effective-dart/style)
- [Effective Dart：用法](https://dart.dev/effective-dart/usage)
- [implementation_imports 的适用范围](https://dart.dev/tools/linter-rules/implementation_imports)
- [Flutter setState 生命周期与任务取消](https://api.flutter.dev/flutter/widgets/State/setState.html)
