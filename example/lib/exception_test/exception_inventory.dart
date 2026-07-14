/// 异常清单：SDK 插件链路上所有可能出现的异常/错误，以及当前的兜底行为。
/// 页面内通过底部弹层完整展示，与测试用例一一对应。
class ExceptionInventoryItem {
  /// 异常名称 / 错误码
  final String name;

  /// 触发来源（什么情况下会发生）
  final String source;

  /// 当前兜底行为（Flutter 端如何感知）
  final String behavior;

  const ExceptionInventoryItem({
    required this.name,
    required this.source,
    required this.behavior,
  });
}

class ExceptionInventoryLayer {
  final String title;
  final String description;
  final List<ExceptionInventoryItem> items;

  const ExceptionInventoryLayer({
    required this.title,
    required this.description,
    required this.items,
  });
}

const List<ExceptionInventoryLayer> kExceptionInventory = [
  ExceptionInventoryLayer(
    title: '① Dart → 原生调用异常（PlatformException）',
    description: '控制器 invokeMethod 时原生端 result.error 返回，'
        '所有控制器均已 try/catch 并转发到失败回调，不再静默。',
    items: [
      ExceptionInventoryItem(
        name: 'LOAD_FAILED',
        source: '实例不存在（create 失败/已销毁）、Activity 不可用、adInstanceId 缺失',
        behavior: '转发 onLoadFailure/loadFail(-1, message)',
      ),
      ExceptionInventoryItem(
        name: 'PRELOAD_FAILED',
        source: 'preLoad 时原生实例不存在',
        behavior: '转发 onLoadFailure(-1, message)',
      ),
      ExceptionInventoryItem(
        name: 'LOAD_EXCEPTION',
        source: '原生 loadAd 执行过程抛出异常',
        behavior: '转发 onLoadFailure(-1, message)',
      ),
      ExceptionInventoryItem(
        name: 'INVALID_ARGS',
        source: '开屏调用缺少 splashInstanceId 参数',
        behavior: '转发 onLoadFailure(-1, message)',
      ),
      ExceptionInventoryItem(
        name: 'SPLASH/INTERSTITIAL/REWARD/NATIVE/BANNER/DRAW_EXCEPTION',
        source: '原生 handleMethodCall 顶层兜底捕获的任何未知异常',
        behavior: '按调用阶段转发 onLoadFailure / onAdShowError / onVideoPlayError',
      ),
      ExceptionInventoryItem(
        name: 'show 阶段错误',
        source: 'showAd 时实例不存在或原生抛异常',
        behavior: '开屏/插屏 → onAdShowError；激励视频 → onVideoPlayError',
      ),
      ExceptionInventoryItem(
        name: 'MissingPluginException',
        source: '方法名不存在或插件未注册（一般仅开发期出现）',
        behavior: '由调用方感知；查询类接口不受影响（返回安全默认值前提是 PlatformException）',
      ),
      ExceptionInventoryItem(
        name: '原生未回调 result（Future 挂起）',
        source: '原生代码路径遗漏 result.success/error 调用',
        behavior: '已通过原生全路径兜底消除；测试用超时检测验证',
      ),
    ],
  ),
  ExceptionInventoryLayer(
    title: '② SDK 业务失败（原生 → Flutter 失败回调）',
    description: '广告 SDK 正常返回的业务失败，经 MethodChannel 回调到 Flutter。',
    items: [
      ExceptionInventoryItem(
        name: '加载失败 onLoadFailure / loadFail',
        source: '无效广告位、无填充、网络异常、SDK 未初始化',
        behavior: '各类型路由分发到对应实例回调，code 安全转换',
      ),
      ExceptionInventoryItem(
        name: '渲染失败 onRenderFail / renderFailed',
        source: '模板渲染异常（原生/自渲染/Draw）',
        behavior: '带 adId 分发，adId 为空时兜底为空字符串',
      ),
      ExceptionInventoryItem(
        name: '展示错误 onAdShowError',
        source: '开屏/插屏展示阶段 SDK 报错',
        behavior: '分发到实例回调，code/message 安全转换',
      ),
      ExceptionInventoryItem(
        name: '视频播放错误 onVideoPlayError / onVideoError',
        source: '视频素材播放失败',
        behavior: '分发到实例回调（含视频组件按 adId 分发）',
      ),
      ExceptionInventoryItem(
        name: '服务端奖励校验失败 onServerRewardDidFail',
        source: '激励视频服务端验证失败',
        behavior: '分发到 onServerRewardFailed，code/message 安全转换',
      ),
    ],
  ),
  ExceptionInventoryLayer(
    title: '③ 回调参数畸形（原生 → Flutter 数据异常）',
    description: '原生传参类型与 Dart 回调签名不符时，'
        '此前会抛类型错误并被 handler 循环吞掉导致回调丢失；现已全部安全转换。',
    items: [
      ExceptionInventoryItem(
        name: 'code = null',
        source: '原生错误码缺失',
        behavior: '转换为 -1，回调正常送达',
      ),
      ExceptionInventoryItem(
        name: 'code = 数字字符串（"90001"）',
        source: '原生按字符串传错误码',
        behavior: 'int.tryParse 成功解析为 90001',
      ),
      ExceptionInventoryItem(
        name: 'code = 非法字符串（"abc"）',
        source: '原生传了不可解析的错误码',
        behavior: '转换为 -1，回调正常送达',
      ),
      ExceptionInventoryItem(
        name: 'code = 浮点数（90011.7）',
        source: 'iOS/鸿蒙侧 NSNumber/number 类型精度问题',
        behavior: 'toInt() 截断为 90011',
      ),
      ExceptionInventoryItem(
        name: 'message = null',
        source: '原生错误描述缺失',
        behavior: "转换为 'unknown error'",
      ),
      ExceptionInventoryItem(
        name: 'arguments 非 Map（如字符串/null）',
        source: '原生参数封装错误',
        behavior: '按空 Map 处理，不崩溃、不抛错',
      ),
      ExceptionInventoryItem(
        name: 'adId = null',
        source: '渲染/视频回调缺失广告 id',
        behavior: "兜底为空字符串 ''",
      ),
      ExceptionInventoryItem(
        name: 'current / duration = null',
        source: 'Draw 播放进度回调参数缺失',
        behavior: '兜底为 0',
      ),
      ExceptionInventoryItem(
        name: 'playDurationMs = null',
        source: 'onVideoSkipToEnd 时长缺失',
        behavior: '回调签名本身可空，透传 null 不崩溃',
      ),
    ],
  ),
  ExceptionInventoryLayer(
    title: '④ 查询类接口的安全默认值',
    description: '实例已销毁/不存在时，查询类接口不抛错、不挂起，返回安全默认值。',
    items: [
      ExceptionInventoryItem(
        name: 'isReadyAd',
        source: '实例已销毁或原生返回错误',
        behavior: '返回 false',
      ),
      ExceptionInventoryItem(
        name: 'getECPM',
        source: '实例已销毁或原生返回错误',
        behavior: '返回 0',
      ),
      ExceptionInventoryItem(
        name: 'getSeatId',
        source: '实例已销毁或原生返回错误',
        behavior: '返回 null',
      ),
      ExceptionInventoryItem(
        name: 'getMediaExtraInfo / destroy / addPreLoadAdInfo',
        source: '实例已销毁或原生返回错误',
        behavior: '返回 null / 静默完成，不抛未捕获异常',
      ),
      ExceptionInventoryItem(
        name: 'Dart handler 内部异常',
        source: '某个回调 handler 处理时抛错',
        behavior: 'AdscopeSdk 捕获并打印，不影响其他 handler（已通过安全转换避免触发）',
      ),
    ],
  ),
];
