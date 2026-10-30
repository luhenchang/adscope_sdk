# iOS per-page FlutterEngine regression

The normal example AppDelegate is unchanged. `AppDelegate.swift` in this folder is a **test fixture**, not a production startup file. The script temporarily copies it into Runner, then restores the original file and normal CocoaPods dependencies on exit. Do not run two example builds at the same time.

## Simulator

The native mediation SDK is used unchanged. Some optional channel SDKs have no arm64 Simulator slice; `ADSCOPE_SIMULATOR_TEST=1` selects the core SDK plus the ASNP adapter for this regression only. Default Podfile installation still includes all normal channels. Simulator ad inventory may return `200500` (no fill); that is a real load-failure callback, not a successful render.

```sh
# From repository root; choose an installed simulator UDID as needed.
FLUTTER_BIN=/path/to/flutter/bin/flutter \
  example/ios/multi_engine_probe/run.sh D5F115BF-A194-4648-9725-2E26BF9002F7
```

Both independent Dart isolates create `AMPSNativeAd(instanceId: 'shared_initial')`. The host automatically runs:

1. A initializes and loads.
2. B starts a separate FlutterEngine, registers plugins and loads.
3. A destroys/recreates its own object with the **same** instance ID and loads while B is alive.
4. B disposes its ads; its page and engine are destroyed.
5. A destroys/recreates its own same-ID object and loads again.

Recreation is deliberate: some native SDK ad objects do not support loading again after a terminal result. This test verifies engine isolation, not changes to SDK reload semantics.

The app writes `Documents/multi_engine_probe.log` into its simulator container. `CALLBACK_ROUTING_PASS` requires all four phases to return through the expected engine; `RENDER_PASS` additionally requires all four to render successfully. `RENDER_INCOMPLETE` clearly distinguishes network/no-fill outcomes. Lack of a result is not a pass.

```sh
xcrun simctl get_app_container SIMULATOR_UDID xyz.adscope.adscopeSdkExample data
```

## XCTest (deterministic regressions)

```sh
cd example/ios
ADSCOPE_SIMULATOR_TEST=1 pod install
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Debug \
  -destination 'platform=iOS Simulator,id=SIMULATOR_UDID' \
  -parallel-testing-enabled NO -only-testing:RunnerTests \
  FLUTTER_BUILD_MODE=debug FLUTTER_TARGET=ios/multi_engine_probe/unit_test_main.dart \
  CODE_SIGNING_ALLOWED=NO test
# Restore the default device dependencies afterwards:
pod install
```

Tests exercise production plugin registration, independent managers and channels, same-ID callback routing, queued and late callbacks after selective detach, owning FlutterViewController lookup with real engines, real engine deallocation cleanup, and concurrent initialization/retry/stale-result handling. Optional third-party channel rendering is not mocked or claimed by those tests.

## Native SDK constraints

Each FlutterEngine must register the plugin. The underlying mediation SDK is still process-global: use the same app ID and compatible SDK/privacy configuration across engines. UI presentation requires the FlutterViewController belonging to that engine; headless engines do not borrow another engine's page.
