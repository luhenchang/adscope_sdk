import 'dart:async';
import 'dart:ui';
import 'package:adscope_sdk/adscope_sdk.dart';
import 'package:adscope_sdk/amps_sdk_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final engine = PlatformDispatcher.instance.defaultRouteName == '/B' ? 'B' : 'A';
  runApp(MaterialApp(initialRoute: '/', home: EngineProbe(engine)));
}

class EngineProbe extends StatefulWidget {
  final String engine;
  const EngineProbe(this.engine, {super.key});
  @override
  State<EngineProbe> createState() => _EngineProbeState();
}

class _EngineProbeState extends State<EngineProbe> {
  static const bridge = MethodChannel('adscope_multi_engine_probe');
  final ads = <String, AMPSNativeAd>{};
  final received = <String, int>{};
  final timers = <Timer>[];
  String status = 'Starting';
  String? visibleInstance;
  String? visibleAdId;

  Future<void> report(String event, [Map<String, dynamic> details = const {}]) async {
    final data = {'engine': widget.engine, 'event': event, ...details};
    debugPrint('MULTI_ENGINE $data');
    try { await bridge.invokeMethod('event', data); }
    catch (error) { debugPrint('MULTI_ENGINE bridgeError=$error'); }
  }

  @override
  void initState() {
    super.initState();
    bridge.setMethodCallHandler((call) async {
      if (call.method == 'load') {
        await load(call.arguments as String);
        return true;
      }
      if (call.method == 'reload') {
        final id = call.arguments as String;
        await report('reloadRequested', {'instanceId': id});
        // The native SDK makes failed/loaded requests one-shot. Recreate using
        // the same explicit ID to test collisions across independent engines.
        await ads.remove(id)?.destroy();
        await load(id);
        return true;
      }
      if (call.method == 'disposeAds') {
        for (final ad in ads.values) { await ad.destroy(); }
        ads.clear();
        await report('adsDisposed');
        return true;
      }
      return null;
    });
    AdscopeSdk.addMethodCallHandler('multi_engine_observer', (call) async {
      final args = call.arguments;
      if (args is! Map || args['adInstanceId'] == null) return;
      final id = args['adInstanceId'].toString();
      final own = ads.containsKey(id);
      if (own) received[id] = (received[id] ?? 0) + 1;
      await report('sdkEvent', {
        'method': call.method,
        'instanceId': id,
        'ownerMatch': own,
        'width': args['width'], 'height': args['height'],
      });
      if (own && call.method == 'AMPSNative_SizeUpdate') {
        await report('displayed', {'instanceId': id});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await report('ready');
      AMPSAdSDK.init(AMPSBuilder('14657').build(), AMPSIInitCallBack(
        initSuccess: initialized,
        alreadyInit: initialized,
        initFailed: (code, msg) => report('initFailed', {'code': code, 'message': msg}),
      ));
    });
  }

  void initialized() {
    if (ads.isNotEmpty) return;
    report('initOk');
    load('shared_initial');
  }

  Future<void> load(String id) async {
    if (!mounted) return;
    final ad = AMPSNativeAd(
      instanceId: id,
      config: AdOptions(spaceId: '15349', adCount: 1),
      mCallBack: AMPSNativeAdListener(
        loadOk: (ids) => report('loadOk', {'instanceId': id, 'adIds': ids}),
        loadFail: (code, msg) => report('loadFail', {'instanceId': id, 'code': code, 'message': msg}),
      ),
      mRenderCallBack: AMPSNativeRenderListener(
        renderSuccess: (adId) {
          if (!mounted) return;
          setState(() { visibleInstance = id; visibleAdId = adId; status = '$id rendered'; });
          report('renderOk', {'instanceId': id, 'adId': adId});
        },
        renderFailed: (adId, code, msg) => report('renderFail', {'instanceId': id, 'code': code, 'message': msg}),
      ),
    );
    ads[id] = ad;
    received[id] = 0;
    setState(() => status = '$id loading');
    await report('loadRequested', {'instanceId': id});
    try {
      final reply = await AdscopeSdk.invokeMethod('AMPSNative_load', {'adInstanceId': id, 'nativeType': 0});
      final version = await AMPSAdSDK.getSdkVersion();
      await report('requestReply', {'instanceId': id, 'reply': reply, 'sdkVersion': version});
    } catch (error) {
      await report('requestError', {'instanceId': id, 'error': error.toString()});
    }
    timers.add(Timer(const Duration(seconds: 12), () {
      if (!mounted) return;
      final count = received[id] ?? 0;
      report('callbackAudit', {'instanceId': id, 'received': count});
      if (count == 0) setState(() => status = '$id: NO CALLBACKS');
    }));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Independent FlutterEngine ${widget.engine}')),
    body: ListView(children: [
      Text(status),
      const Text('App 14657 / native 15349'),
      if (visibleAdId != null)
        Align(alignment: Alignment.topCenter,
          child: SizedBox(width: 343, child: FittedBox(fit: BoxFit.contain,
            child: NativeWidget(ads[visibleInstance], adId: visibleAdId!, key: ValueKey(visibleAdId))))),
      const Text('Multi-engine callback isolation test'),
    ]),
  );

  @override
  void dispose() {
    for (final timer in timers) { timer.cancel(); }
    for (final ad in ads.values) { ad.destroy(); }
    AdscopeSdk.removeMethodCallHandler('multi_engine_observer');
    super.dispose();
  }
}
