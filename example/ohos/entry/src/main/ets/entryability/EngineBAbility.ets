import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { MultiEngineLabHost } from './MultiEngineLabHost';

/** Second FlutterEngine. Started with route /engine-b. */
export default class EngineBAbility extends FlutterAbility {
  pagePath(): string {
    return 'pages/EngineB'
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    MultiEngineLabHost.attach('B', flutterEngine, this.context)
  }

  onDestroy(): void {
    MultiEngineLabHost.detach('B')
    super.onDestroy()
  }
}
