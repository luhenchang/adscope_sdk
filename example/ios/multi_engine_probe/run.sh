#!/bin/bash
set -euo pipefail
# Run from any directory. Default is the simulator used by the regression suite.
probe_dir="$(cd "$(dirname "$0")" && pwd)"
example_dir="$(cd "$probe_dir/../.." && pwd)"
probe_device="${1:-D5F115BF-A194-4648-9725-2E26BF9002F7}"
probe_backup="$(mktemp -d)"
cp "$example_dir/ios/Runner/AppDelegate.swift" "$probe_backup/AppDelegate.swift"
cp "$example_dir/ios/Podfile.lock" "$probe_backup/Podfile.lock"
restore_host() {
  if cmp -s "$example_dir/ios/Runner/AppDelegate.swift" "$probe_dir/AppDelegate.swift"; then
    cp "$probe_backup/AppDelegate.swift" "$example_dir/ios/Runner/AppDelegate.swift"
  else
    echo "Host source changed during probe; original preserved at $probe_backup/AppDelegate.swift" >&2
  fi
  cp "$probe_backup/Podfile.lock" "$example_dir/ios/Podfile.lock"
  (cd "$example_dir/ios" && env -u ADSCOPE_SIMULATOR_TEST pod install) || echo "Run pod install in example/ios before the next device build." >&2
}
trap restore_host EXIT
cp "$probe_dir/AppDelegate.swift" "$example_dir/ios/Runner/AppDelegate.swift"
(cd "$example_dir/ios" && ADSCOPE_SIMULATOR_TEST=1 pod install)
cd "$example_dir"
ADSCOPE_SIMULATOR_TEST=1 "${FLUTTER_BIN:-flutter}" run --debug --device-id "$probe_device" --target ios/multi_engine_probe/main.dart
