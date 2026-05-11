#!/usr/bin/env bash
#
# Local release build for the Flutter app.
#
# Usage:
#   ./scripts/release.sh [aab|apk|both]   (default: both)
#
# Requires either:
#   - flutter/android/key.properties (local dev), OR
#   - ANDROID_KEYSTORE_PASSWORD / ANDROID_KEY_PASSWORD / ANDROID_KEY_ALIAS /
#     ANDROID_KEYSTORE_PATH environment variables (CI / shared shells).

set -euo pipefail

target="${1:-both}"
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root/flutter"

echo "▶ flutter clean"
flutter clean
echo "▶ flutter pub get"
flutter pub get

case "$target" in
    aab)  flutter build appbundle --release ;;
    apk)  flutter build apk --release ;;
    both) flutter build appbundle --release && flutter build apk --release ;;
    *)
        echo "Unknown target: $target (expected aab|apk|both)" >&2
        exit 2
        ;;
esac

echo
echo "✅ Build outputs:"
find build/app/outputs/bundle/release  -name '*.aab' 2>/dev/null || true
find build/app/outputs/flutter-apk     -name '*.apk' 2>/dev/null || true
