#!/bin/bash
set -euo pipefail
umask 077
cd "$(dirname "$0")/.."

: "${CODE_SIGN_IDENTITY:?Set CODE_SIGN_IDENTITY to your Developer ID Application certificate name}"
: "${NOTARY_PROFILE:?Set NOTARY_PROFILE to your local notarytool Keychain profile name}"
case "$CODE_SIGN_IDENTITY" in
    "Developer ID Application:"*) ;;
    *) printf 'Use a Developer ID Application identity, not Apple Distribution or ad hoc signing.\n' >&2; exit 1 ;;
esac
export CODE_SIGN_IDENTITY

# Validate local Keychain authentication before building or uploading anything.
xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" --output-format json > /dev/null
bash scripts/build-app.sh
APP="dist/Window Snapper.app"

mkdir -p .build/notarization
WORK_DIR=$(mktemp -d "$PWD/.build/notarization/run.XXXXXX")
SUBMISSION="$WORK_DIR/submission.zip"
RESULT="$WORK_DIR/result.plist"
ditto --norsrc --noextattr --noacl -c -k --keepParent "$APP" "$SUBMISSION"

printf 'Submitting to Apple. Local result directory: %s\n' "$WORK_DIR"
if ! xcrun notarytool submit "$SUBMISSION" --keychain-profile "$NOTARY_PROFILE" \
    --wait --timeout 30m --output-format plist > "$RESULT"; then
    printf 'Submission failed or timed out. Inspect %s before retrying; Apple may still be processing it.\n' "$RESULT" >&2
    exit 1
fi
STATUS=$(/usr/libexec/PlistBuddy -c 'Print :status' "$RESULT")
if [[ "$STATUS" != "Accepted" ]]; then
    printf 'Notarization status: %s. Inspect %s and retrieve the Apple submission log. No final package was created.\n' "$STATUS" "$RESULT" >&2
    exit 1
fi

# ZIPs cannot be stapled: attach the ticket to the app, then archive it again.
xcrun stapler staple "$APP"
bash scripts/package-release.sh --notarized
printf 'Notarization and extracted-package validation passed. Nothing was published to GitHub.\n'
