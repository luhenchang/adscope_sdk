import 'dart:async';
import 'dart:ui';
import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Paired with the native host fixture; both engines intentionally reuse this ID.
const instanceId = 'shared_initial';
const bridge = MethodChannel('adscope_multi_engine_probe');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final label = PlatformDispatcher.instance.defaultRouteName == '/B' ? 'B' : 'A';
  runApp(MaterialApp(initialRoute: '/', home: EngineProbe(label)));
}

class EngineProbe extends StatefulWidget {
  final String engine;
  const EngineProbe(this.engine, {super.key});
  @override
  State<EngineProbe> createState() => _EngineProbeState();
}

class _EngineProbeState extends State<EngineProbe> {
  AMPSNativeAd? ad;
  String? adId;
  String phase = 'initial';
  String status = 'Starting';

  Future<void> report(String event, [Map<String, dynamic> data = const {}]) async {
    final payload = {'engine': widget.engine, 'phase': phase, 'event': event, ...data};
    debugPrint('MULTI_ENGINE $payload');
    await bridge.invokeMethod('event', payload);
  }

  @override
  void initState() {
    super.initState();
    bridge.setMethodCallHandler((call) async {
      if (call.method == 'load') {
        await load(call.arguments as String);
        return true;
      }
      if (call.method == 'disposeAds') {
        await ad?.destroy();
        ad = null;
        await report('adsDisposed');
        return true;
      }
      return null;
    });
    AdscopeSdk.addMethodCallHandler('multi_engine_observer', (call) async {
      final args = call.arguments;
      if (args is Map && args['adInstanceId'] != null) {
        await report('sdkEvent', {
          'method': call.method,
          'instanceId': args['adInstanceId'],
          'width': args['width'], 'height': args['height'],
        });
        if (call.method == 'AMPSNative_SizeUpdate') await report('displayed');
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AMPSAdSDK.init(AMPSBuilder('14659').build(), AMPSIInitCallBack(
        initSuccess: initialized,
        alreadyInit: initialized,
        initFailed: (code, message) => report('initFailed', {'code': code, 'message': message}),
      ));
    });
  }

  void initialized() {
    if (ad != null) return;
    report('initOk');
    load('initial');
  }

  Future<void> load(String nextPhase) async {
    phase = nextPhase;
    if (mounted) setState(() { adId = null; status = '$phase loading'; });
    // A failed/completed native SDK ad object cannot always load twice. Recreate
    // the object while reusing the SAME Dart instance ID to check engine isolation.
    await ad?.destroy();
    ad = AMPSNativeAd(
      instanceId: instanceId,
      config: AdOptions(spaceId: '15354', adCount: 1),
      mCallBack: AMPSNativeAdListener(
        loadOk: (ids) => report('loadOk', {'adIds': ids}),
        loadFail: (code, message) {
          if (mounted) setState(() => status = '$phase loadFail: $code');
          report('loadFail', {'code': code, 'message': message});
        },
      ),
      mRenderCallBack: AMPSNativeRenderListener(
        renderSuccess: (id) {
          if (!mounted) return;
          setState(() { adId = id; status = '$phase rendered'; });
          report('renderOk', {'adId': id});
        },
        renderFailed: (id, code, message) => report('renderFail', {'code': code, 'message': message}),
      ),
    );
    await report('loadRequested', {'instanceId': instanceId});
    final reply = await AdscopeSdk.invokeMethod('AMPSNative_load', {'adInstanceId': instanceId, 'nativeType': 0});
    await report('requestReply', {'reply': reply, 'sdkVersion': await AMPSAdSDK.getSdkVersion()});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('FlutterEngine ${widget.engine} / $phase')),
    body: ListView(children: [
      Text(status),
      const Text('Both engines use instanceId=shared_initial'),
      if (adId != null)
        Align(alignment: Alignment.topCenter,
          child: SizedBox(width: 343, child: FittedBox(fit: BoxFit.contain,
            child: NativeWidget(ad, adId: adId!, key: ValueKey(adId))))),
    ]),
  );

  @override
  void dispose() {
    ad?.destroy();
    AdscopeSdk.removeMethodCallHandler('multi_engine_observer');
    super.dispose();
  }
}
