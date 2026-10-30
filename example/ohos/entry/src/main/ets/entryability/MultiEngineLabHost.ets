import { FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { common, Want } from '@kit.AbilityKit';

const LAB_CHANNEL = 'adscope_example_multi_engine';

/** Relays lab events between the two example engines and opens engine B. */
export class MultiEngineLabHost {
  private static channels: Map<string, MethodChannel> = new Map<string, MethodChannel>()
  private static contexts: Map<string, common.UIAbilityContext> = new Map<string, common.UIAbilityContext>()
  private static openingB: boolean = false

  static attach(name: string, flutterEngine: FlutterEngine, context: common.UIAbilityContext): void {
    const channel = new MethodChannel(flutterEngine.getDartExecutor(), LAB_CHANNEL)
    MultiEngineLabHost.channels.set(name, channel)
    MultiEngineLabHost.contexts.set(name, context)
    if (name === 'B') {
      MultiEngineLabHost.openingB = false
    }
    channel.setMethodCallHandler({
      onMethodCall(call: MethodCall, result: MethodResult) {
        if (call.method === 'openEngineB') {
          if (name !== 'A' || MultiEngineLabHost.contexts.has('B') || MultiEngineLabHost.openingB) {
            result.success(false)
            return
          }
          MultiEngineLabHost.openingB = true
          const want: Want = {
            bundleName: context.abilityInfo.bundleName,
            abilityName: 'EngineBAbility',
            parameters: { 'route': '/engine-b' }
          }
          context.startAbility(want).then(() => {
            result.success(true)
          }).catch((error: Error) => {
            MultiEngineLabHost.openingB = false
            result.error('OPEN_FAILED', error.message, undefined)
          })
          return
        }
        if (call.method === 'closeEngineB') {
          const engineB = MultiEngineLabHost.contexts.get('B')
          if (engineB) {
            engineB.terminateSelf()
          }
          result.success(true)
          return
        }
        if (call.method === 'publish') {
          const peerName = name === 'A' ? 'B' : 'A'
          MultiEngineLabHost.channels.get(peerName)?.invokeMethod('peer', call.args as ESObject)
          result.success(null)
          return
        }
        result.notImplemented()
      }
    })
    MultiEngineLabHost.notifyPeer()
  }

  static detach(name: string): void {
    MultiEngineLabHost.channels.get(name)?.setMethodCallHandler(null)
    MultiEngineLabHost.channels.delete(name)
    MultiEngineLabHost.contexts.delete(name)
    if (name === 'B') {
      MultiEngineLabHost.openingB = false
    }
    MultiEngineLabHost.notifyPeer()
  }

  private static notifyPeer(): void {
    const payload = { opened: MultiEngineLabHost.contexts.has('B') } as ESObject
    MultiEngineLabHost.channels.get('A')?.invokeMethod('peerState', payload)
    MultiEngineLabHost.channels.get('B')?.invokeMethod('peerState', payload)
  }
}
