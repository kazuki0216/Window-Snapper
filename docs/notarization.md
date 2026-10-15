[← Overview](../README.md) · [Packaging and releases](releases.md)

# Developer ID signing and notarization

The currently published beta is ad hoc signed, not notarized. This workflow prepares future verified downloads; adding the scripts does not change existing releases.

## One-time account setup

An active Apple Developer Program membership can be used for both iOS development and Mac distribution. A free development account alone is insufficient. Downloadable Mac apps use a **Developer ID Application** certificate rather than the Apple Distribution certificate typically used for iOS releases.

1. As the team's Account Holder, create a **Developer ID Application** certificate using Xcode's account certificate management or [Apple's developer portal instructions](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/). Install it with its private key in the release Mac's Keychain. Do not revoke or replace your iOS certificates.
2. Confirm the identity appears in `security find-identity -v -p codesigning` with the Developer ID Application prefix.
3. Create an app-specific password through your Apple Account if using Apple ID authentication. Do not use your primary account password for notarization.
4. In your own Terminal, save the notarization credentials interactively:

   ```sh
   xcrun notarytool store-credentials "window-snapper-notary"
   ```

   Supply the Apple ID, matching Team ID, and app-specific password when prompted. The password is stored in Keychain, not the repository. Do not paste credentials into chat, add them to shell command arguments, commit them, or export private keys to share here. Use the developer team that owns the signing certificate. The profile name is just a local label, not a secret.

If Xcode offers only a Personal Team, verify membership before proceeding. Account agreements or role restrictions may require action by the Account Holder. You do not need to create an App Store listing or reuse Youki's app identifier for this distribution.

## Prepare a verified release

Review and commit the intended source revision, and increment the bundle version for a new release. Then run:

```sh
CODE_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
NOTARY_PROFILE='window-snapper-notary' \
bash scripts/notarize-release.sh
```

Use the exact certificate name shown on your Mac. If the build host requires the explicit SwiftPM sandbox workaround, prefix the same command with `SWIFTPM_DISABLE_SANDBOX=1`; see the [build guide](building.md#build-troubleshooting).

This command contacts Apple's services: it validates Keychain authentication, timestamp-signs the hardened app, uploads an intermediate ZIP for notarization, and waits up to 30 minutes. The installed app itself does not acquire networking code or store those credentials. The build may ask you to authorize codesign's use of your signing key through macOS.

Only an **Accepted** result proceeds. The script staples Apple's ticket to the app, repackages it without rebuilding, and checks the extracted app's signature, ticket, Gatekeeper assessment, executable permission, and bundled notices. It also writes a checksum. Results stay in ignored `.build/notarization/` and `dist/` directories; they must not be committed.

The command does not publish anything to GitHub. After it succeeds, test the download and first launch on a clean Mac and follow the [release guide](releases.md). Use a new release tag; do not replace an existing ad hoc beta's assets silently. Update public signing/compatibility statements only after actual validation succeeds.

## Rejections and timeouts

Inspect the result plist in the directory printed by the script. A timeout does not cancel Apple's processing. Use the submission ID and the same local profile to query status or download a log:

```sh
xcrun notarytool info 'SUBMISSION-ID' --keychain-profile 'window-snapper-notary'
xcrun notarytool log 'SUBMISSION-ID' --keychain-profile 'window-snapper-notary' .build/notarization/notary-log.json
```

Treat logs as local diagnostic material and review them before sharing. Once Apple reports Accepted, an interrupted run can be finished with `xcrun stapler staple "dist/Window Snapper.app"` followed by `bash scripts/package-release.sh --notarized`, provided the app has not been rebuilt or altered since submission. Otherwise submit the new signed build.

Notarization is Apple's automated malware/signing check, not an independent security audit or guaranteed employer approval. See [Apple's workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow) and this project's [security notes](../SECURITY.md).
