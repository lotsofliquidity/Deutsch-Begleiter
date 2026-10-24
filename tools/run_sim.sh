#!/usr/bin/env bash
# Build and launch the app in the iOS Simulator.
#
#   tools/run_sim.sh                 # iPhone 17 Pro
#   tools/run_sim.sh "iPhone 17"     # any installed simulator
#
# Simulator builds need no signing, no provisioning profile and no device.
set -euo pipefail

DEVICE="${1:-iPhone 17 Pro}"
BUNDLE_ID="com.hayden.DeutschBegleiter"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED="$ROOT/app/build/sim"

cd "$ROOT/app"

echo "▸ building for $DEVICE"
xcodebuild \
  -project DeutschBegleiter.xcodeproj \
  -scheme DeutschBegleiter \
  -destination "platform=iOS Simulator,name=$DEVICE" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  build >/dev/null

APP="$DERIVED/Build/Products/Debug-iphonesimulator/DeutschBegleiter.app"
[ -d "$APP" ] || { echo "build produced no app at $APP"; exit 1; }

if ! xcrun simctl list devices booted | grep -q "$DEVICE"; then
  echo "▸ booting $DEVICE"
  xcrun simctl boot "$DEVICE" 2>/dev/null || true
fi

# the GUI is convenient but not required; headless boot is enough to run
open -a "$(xcode-select -p)/Applications/Simulator.app" 2>/dev/null || true

echo "▸ installing"
xcrun simctl install "$DEVICE" "$APP"

echo "▸ launching"
xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl launch "$DEVICE" "$BUNDLE_ID"
