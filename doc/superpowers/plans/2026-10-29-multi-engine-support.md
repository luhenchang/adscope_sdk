# Flutter multi-engine support implementation plan

**Goal:** Support a separate FlutterEngine per page on iOS and Android without changing Dart APIs or channel names.

**Architecture:** Each plugin registration owns its channel, ad managers, platform-view factories and lifecycle. Ad managers/slots retain a weak reference to their engine event owner; no callback is broadcast or routed through a process-global latest channel. The underlying advertising SDK remains process-global; its asynchronous initialization result is delivered to the requesting engine. Destroying an engine disposes only its owned ads and suppresses late callbacks.

**Tech stack:** Swift, Kotlin, Flutter method channels, XCTest, JVM tests, iOS Simulator and Android device.

## Regression evidence

The unmodified iOS plugin was exercised on two real FlutterEngines: A initially displayed, B initially displayed, A requested again, B received A's load/render callbacks, A received zero callbacks; after B destruction A still received none within 12 seconds. Evidence: `/private/tmp/adscope-ios-multi-engine-result.log`.

## Tasks

- [x] iOS: Replace shared event/ad manager instances with one `AMPSEventManager` per `AdscopeSdkPlugin`; publish plugin for Flutter detach lifecycle.
- [x] iOS: Inject owner into native/unified/banner/draw view factories and slots; look up ads only within that owner's manager.
- [x] iOS: Clear all delegates, ad stores, native views and channel on owner release. Resolve presenters by matching FlutterViewController.binaryMessenger to the owner's messenger.
- [x] iOS: Replace stale RunnerTests with callback-isolation tests covering equal Dart instance IDs, two registered channels, selective detach, queued late callbacks and registration of platform views.
- [x] Android: Implement equivalent per-engine managers, wrapper stores, Activity handling and selective detach; add JVM regression tests (independent Android implementation agent).
- [x] Add reproducible native dual-engine test hosts and Dart probes under the example testing directory without changing normal app startup.
- [x] Run iOS Simulator tests. First use current Podfile; if a third-party framework lacks the simulator architecture, record the limitation and use a simulator-only dependency selection that leaves the normal Podfile dependencies unchanged.
- [x] Run Android JVM checks and existing Android emulator scenario: A loads, B loads, A reloads with B alive, B is destroyed, A reloads again. Use the same explicit instance ID in both engines to test isolation.
- [x] Review both implementations for remaining global engine state, cleanup cycles and unsupported fallbacks; repair findings and rerun affected checks.
- [x] Record exact commands, results and remaining third-party SDK limitations in a test report. Do not publish or commit automatically.

## Acceptance checks

`A` and `B` each receive only their own init/ad callbacks. Reusing an explicit instance ID in two engines does not overwrite either manager's instance. Closing `B` does not unregister `A`, discard `A` ads, or change `A`'s activity/presenter. Detached channels do not receive queued or later native callbacks. Single-engine calls and platform-view registration remain compatible.

- [x] Android physical-device rerun completed 2026-10-30 on Lenovo L70081 / Android 11: all four phases rendered using shared_initial in both engines, B destroyed before the last A request, zero crossed callbacks; RENDER_PASS. Evidence: /private/tmp/adscope-android-physical-multi-engine-20261030.log.
