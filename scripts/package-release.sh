#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

bash scripts/build-app.sh
APP="dist/Window Snapper.app"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")
ARCHS=$(lipo -archs "$APP/Contents/MacOS/WindowSnapper")
case "$ARCHS" in
    arm64) ARCH_LABEL="arm64" ;;
    x86_64) ARCH_LABEL="x86_64" ;;
    "x86_64 arm64"|"arm64 x86_64") ARCH_LABEL="universal" ;;
    *) printf 'Unsupported architecture: %s\n' "$ARCHS" >&2; exit 1 ;;
esac

ARCHIVE="dist/Window-Snapper-$VERSION-$ARCH_LABEL.zip"
# Keep the app directory and executable permissions, without local extended attributes.
ditto --norsrc --noextattr --noacl -c -k --keepParent "$APP" "$ARCHIVE"

# Check exactly what recipients will extract before publishing the archive.
VERIFY_DIR=$(mktemp -d "$PWD/.build/release-check.XXXXXX")
trap 'rm -rf "$VERIFY_DIR"' EXIT
ditto -x -k "$ARCHIVE" "$VERIFY_DIR"
codesign --verify --strict --verbose=2 "$VERIFY_DIR/Window Snapper.app"
test -x "$VERIFY_DIR/Window Snapper.app/Contents/MacOS/WindowSnapper"
cmp LICENSE "$VERIFY_DIR/Window Snapper.app/Contents/Resources/LICENSE"
cmp DISCLAIMER.md "$VERIFY_DIR/Window Snapper.app/Contents/Resources/DISCLAIMER.md"
cmp SECURITY.md "$VERIFY_DIR/Window Snapper.app/Contents/Resources/SECURITY.md"

ARCHIVE_NAME=$(basename "$ARCHIVE")
(cd dist && shasum -a 256 "$ARCHIVE_NAME" > "$ARCHIVE_NAME.sha256")
printf 'Ready to upload:\n  %s\n  %s.sha256\n' "$ARCHIVE" "$ARCHIVE"
