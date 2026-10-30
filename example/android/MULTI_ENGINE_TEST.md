# Android multi-engine native-ad probe

This debug-only Activity creates two normal FlutterActivities, each owning its own
FlutterEngine, messenger, and SDK plugin instance. Both isolates use the explicit
ad instance ID `shared_initial`, exercising ID collisions across engines.

From `example/`, build the probe and install it on an Android device:

```sh
flutter build apk --debug --target android/multi_engine_probe.dart
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb logcat -c
adb shell am start -n xyz.adscope.adscope_sdk_example/.MultiEngineProbeActivity
adb logcat -s MultiEngineProbe flutter
```

The host advances after rendering or a terminal SDK failure: A loads, B opens and loads,
A destroys/recreates `shared_initial` while B's engine is alive, B finishes
and destroys its engine, then A destroys/recreates that same ID again. The native
SDK makes failed/loaded requests one-shot, so reusing a failed SDK object does
not issue another request. Look for
`RENDER_PASS` when all four stages render. If the ad service returns failure,
`CALLBACK_ROUTING_PASS` confirms all four requests still received SDK callbacks
without proving ad rendering. SDK event reports with `ownerMatch=false`
indicate a callback crossed to the wrong isolate. Each request also reports a
12-second callback audit. Android sample credentials are app `14657`, native
placement `15349`; fill/no-fill and network access depend on the ad service.

The ordinary example entry point and release manifest are unaffected. For JVM
ownership, detach, Activity, SDK initialization and late-callback regressions:

```sh
cd android
JAVA_HOME="$(/usr/libexec/java_home -v 17)" ./gradlew :adscope_sdk:testDebugUnitTest
```

SDK initialization uses the engine's `FlutterPluginBinding.applicationContext`,
so cached/headless engines can initialize before attaching an Activity. Ad
creation and full-screen showing require that engine's own attached Activity;
a detached engine returns an explicit error and never uses a sibling Activity.

The underlying AMPS SDK is process-wide: all engines in one application must use
the same SDK app ID/configuration. Concurrent init callers share one pending
native initialization and receive their own completion; detaching one engine
removes only its waiter. Log/privacy/personalization settings also belong to the
native SDK process. Ads, Dart instance IDs, platform views and callbacks belong
to each Flutter engine.

JVM regressions use JDK 17. The pinned Mockito-inline/Byte Buddy test runtime does not support JDK 21; this requirement does not change the SDK runtime on Android devices.
