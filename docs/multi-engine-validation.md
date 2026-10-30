# Flutter 多引擎支持与验证（2026-10-29～2026-10-30）

## 实现范围

iOS、Android 均改为每个 FlutterEngine 持有独立插件上下文，包含 MethodChannel、各广告类型管理器、实例字典、视图工厂与自渲染视图注册。Flutter 对外 API、通道名、方法名均不变。

同一个 `adInstanceId` 可以分别用于两个引擎；广告回调只发回创建它的引擎。引擎销毁时只清理自己的广告、视图、覆盖层及通道，排队/迟到回调不会发送到已销毁的通道。iOS 使用 Flutter 发布的插件实例接收 detach；Android 独立处理 Activity 绑定、配置变化和引擎销毁。

底层广告 SDK 仍为进程级单例。多个引擎并发初始化合并为一次底层调用，仅向仍有效的请求引擎回传结果；失败可以重试，旧请求完成不能结束新的初始化。Android SDK 初始化支持引擎绑定的 application Context；广告创建/展示仍要求该引擎自己的 Activity。iOS 展示控制器按 messenger 匹配，包含导航栈下层的 Flutter 页面，headless 引擎不会借用其他引擎页面。

所有引擎应使用同一个平台 App ID 和兼容的全局初始化/隐私配置；SDK 全局开关不因引擎隔离变成独立开关。

## 回归结果

| 验证 | 结果 | 实际覆盖 |
|---|---|---|
| iOS XCTest，iPhone 17 Pro / iOS 26.1 Simulator | **8/8 通过** | 独立通道和各类管理器、同名实例回调、选择性销毁、排队/迟到回调、真实双引擎页面归属、真实引擎释放触发插件清理、并发初始化和失败重试/旧结果隔离 |
| iOS 双引擎完整调用流程，14659 / 15354 | **CALLBACK_ROUTING_PASS** | A 初次加载 → B 初次加载 → B 存在时 A 同名重建加载 → 销毁 B → A 同名重建加载；所有失败回调均回到正确引擎 |
| iOS 广告实际渲染 | **未验证成功** | 模拟器的广告源返回 200500“所有广告源无填充”，日志明确为 RENDER_INCOMPLETE，不能宣称展示成功 |
| iOS 正常全渠道 Profile / iphoneos 编译 | **通过** | 使用原正常入口与正常依赖，禁用签名，仅编译，未部署真机 |
| Android JVM | **16/16 通过** | 通道、同名 ID、各类管理器/封装视图、Activity 变化、迟到回调、并发初始化、headless 初始化、开屏覆盖层归属及清理、Activity 缺失时展示方法明确返回失败 |
| Android 双引擎完整渲染，Pixel_9_Pro ARM64 / API 36.1 emulator，14657 / 15349 | **RENDER_PASS，4 次全部渲染** | 两个引擎均使用 shared_initial，A → B → A（B 仍存在）→ 销毁 B → A；零 ownerMatch=false |
| Android USB 真机，Lenovo L70081 / Android 11，14657 / 15349 | **2026-10-30 RENDER_PASS，4 次全部渲染** | 两个引擎均使用 shared_initial；A → B → A（B 仍存在）→ 销毁 B → A，零 ownerMatch=false |

Android 最终运行记录：A render 19:55:24.765，B render 19:55:29.405，A with B render 19:55:31.203，B Activity/engine destroy 19:55:33.256，A after B render 19:55:35.059。

两端的重载场景均销毁并以相同显式 ID 重建 SDK 广告对象。部分底层渠道的广告对象在加载失败/完成后不支持直接再次 load；本次不改变该原生 SDK 行为。Android JVM 另验证销毁 B 不会清除 A 已存在的同 ID SDK 对象。

## 复现入口

- [Android debug 多引擎宿主与步骤](../example/android/MULTI_ENGINE_TEST.md)
- [iOS Simulator 宿主与 XCTest 步骤](../example/ios/multi_engine_probe/README.md)
- [iOS XCTest](../example/ios/RunnerTests/RunnerTests.swift)
- [Android JVM 测试](../android/src/test/kotlin/xyz/adscope/adscope_sdk)

正常示例 AppDelegate、MainActivity、release manifest 均未被测试宿主替换。iOS 模拟器只临时选择具有可用架构的 core + ASNP 依赖，正常设备依赖已经恢复；修正了示例 Debug 误配置为 profile 的问题。

## 本地证据文件

- iOS XCTest：`/private/tmp/adscope-ios-engine-tests-final.xcresult`，摘要 `/private/tmp/adscope-ios-engine-tests-final-summary.json`
- iOS 双引擎：`/private/tmp/adscope-ios-simulator-multi-engine-result.log`
- iOS 正常编译：`/private/tmp/adscope-ios-production-profile-build.log`
- Android JVM：`/private/tmp/adscope-android-jvm-results.json`
- Android 最终运行：`/private/tmp/adscope-android-final.log`
- Android 销毁 B 后的 A 截图：`/private/tmp/adscope-android-engine-A-after-B-detach.png`

代码经独立只读复核，发现并修复了开屏覆盖层残留/共享 Activity 同名碰撞、Activity 解绑时展示调用悬挂、插件额外初始化超时可能误判成功等问题；最终复核无剩余 P1/P2。本报告记录提交前的验证结果。

## 2026-10-30 Android 真机补测

重新连接 Lenovo L70081 后，使用当前源代码对应的已验证 APK 完成全部四阶段，09:31:30.895 返回 `RENDER_PASS; allRendered=true`。日志中恰有 4 次 renderOk，没有 ownerMatch=false。B 的 Activity/engine 在 09:31:28.850 销毁，之后 A 再加载并成功展示，原生回调尺寸为 360 × 202。

- 日志：`/private/tmp/adscope-android-physical-multi-engine-20261030.log`
- 最终 A 页面截图：`/private/tmp/adscope-android-physical-multi-engine-20261030.png`

实体手机待测项已完成，未修改实现代码。

## 2026-10-30 合入 ohos 分支验证

将 main（3a08bea）的多引擎实现合入 ohos（原基点 7116c88）。保留原分支的 Dart OhosView 分支、示例依赖版本、HAR、签名及构建配置、自渲染图片逻辑、激励 setExtraData 更新逻辑和开屏底部配置。开屏冲突使用所属引擎的 context，并保留按实例保存底部配置及旧 show 参数兼容逻辑。

修复迁入代码的两处 ArkTS 编译问题：开屏 build 中的普通语句移至 aboutToAppear，并使用根 Column；多引擎示例的 peerState 使用显式接口类型。

- 使用项目 FVM 3.27.5-ohos-1.0.3，鸿蒙插件、示例和签名包编译成功。
- Android 多引擎 JVM 回归 16 项通过。使用临时工程及标准 Flutter 3.35.7/JDK 17，未改动项目的鸿蒙 FVM/local.properties。
- 鸿蒙真机 23E0223A12011278，应用 55819、原生模板位 124579，两引擎复用 ohos_shared_instance：A 初次、B 初次、B 存在时 A 重载、关闭 B 后 A 重载，四次均 renderOk；最终 routingPass=true、allRendered=true、unexpected=0。
- SDK 可先回调 renderSuccess 再回调 loadOk。临时探针等待两类回调齐全后再审计，避免将正常加载回调误判为串引擎。
- 本次真机验证范围为原生模板广告；其他广告类型未逐一做鸿蒙真机回归。

验证日志：`/private/tmp/adscope-ohos-merge-build-3.log`、`/private/tmp/adscope-ohos-merge-android-tests-isolated-3.log`、`/private/tmp/adscope-ohos-multi-engine-final.log`。真机截图：`/private/tmp/adscope-ohos-multi-engine-final.jpeg`。自动测试入口位于 `/private/tmp/adscope_ohos_multi_engine_probe.dart`，测试后恢复正常 lib/main.dart 入口。
