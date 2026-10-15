#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$PWD/.build/swift-cache"
BUILD_OPTIONS=(--cache-path "$PWD/.build/package-cache" -c release -debug-info-format none)
# Only opt out on build hosts that prohibit SwiftPM's nested sandbox.
if [[ "${SWIFTPM_DISABLE_SANDBOX:-0}" == "1" ]]; then
    BUILD_OPTIONS+=(--disable-sandbox)
fi
swift scripts/generate-icon.swift
swift build "${BUILD_OPTIONS[@]}"
BIN_DIR="$(swift build "${BUILD_OPTIONS[@]}" --show-bin-path)"
APP="dist/Window Snapper.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/WindowSnapper" "$APP/Contents/MacOS/WindowSnapper"
cp Resources/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon-Modern.icns"
rm -f "$APP/Contents/Resources/AppIcon.icns"
SIGNING_IDENTITY="${CODE_SIGN_IDENTITY:--}"
SIGNING_OPTIONS=(--force --sign "$SIGNING_IDENTITY" --options runtime --identifier com.windowsnapper.app)
if [[ "$SIGNING_IDENTITY" != "-" ]]; then
    SIGNING_OPTIONS+=(--timestamp)
fi
codesign "${SIGNING_OPTIONS[@]}" "$APP"
codesign --verify --strict --verbose=2 "$APP"
touch "$APP"
printf 'Built: %s/%s\n' "$PWD" "$APP"
