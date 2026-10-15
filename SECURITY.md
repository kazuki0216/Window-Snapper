# Security notes

Reviewed: 2026-10-15. Scope: the source and packaging scripts in this repository. This is a limited source review and build inspection, not a penetration test, independent audit, or certification of workplace suitability.

## Trust boundary

Window Snapper runs as the logged-in user. Accessibility is necessary to move other apps' windows, but macOS grants broad UI access rather than a window-resize-only capability. A compromised or malicious replacement could misuse that permission even if today's code only changes geometry. Local-only software can still read, alter, or disclose local data if its implementation changes or is compromised.

Apple advises granting Accessibility only to apps you trust: [Accessibility permissions](https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/mac).

## Current behavior and data

| Surface | Implementation |
| --- | --- |
| Global shortcuts | Carbon registers the listed combinations. The callback handles action identifiers; it does not record arbitrary typing. |
| Accessibility reads | Frontmost app PID, focused window reference, full-screen state, position, and size. No traversal of document content or UI text. |
| Accessibility writes | Focused window position and size, triggered by a shortcut or menu action. |
| Retained window data | At most 50 window references and previous rectangles, in process memory until quit. |
| Persistent app data | `hasLaunched` and `shortcutPreset` in UserDefaults under `com.windowsnapper.app`. |
| Login startup | SMAppService registration only when the user chooses Launch at Login. |
| Other app interactions | Opens the fixed macOS Accessibility settings URL and macOS Login Items settings. |
| Network, telemetry, uploads | No implementation in the app. No third-party dependencies in Package.swift. This is not an OS-enforced network prohibition. |
| Files, clipboard, shell, plugins | No runtime document/file reader, clipboard access, subprocess execution, downloaded code, plugin loader, or self-updater in the app source. |
| Diagnostics | No application telemetry/logger is implemented. macOS may independently create crash reports and other system diagnostics. |

Source of truth: [app](Sources/WindowSnapper/main.swift), [package](Package.swift), [metadata](Resources/Info.plist), [packaging](scripts/build-app.sh), and [icon generator](scripts/generate-icon.swift). Build scripts execute developer tools and write generated assets and bundles; the installed app does not run these scripts.

## Protections and limitations

- Hardened Runtime is enabled by the build script. No runtime exception entitlements, debugger entitlement, JIT, or library-validation exception is added. See [Apple's Hardened Runtime documentation](https://developer.apple.com/documentation/security/hardened-runtime).
- The app does not enable App Sandbox. Hardened Runtime is a separate protection, not filesystem or network confinement.
- The default signature is ad hoc. It supports local integrity verification but does not authenticate a publisher; someone able to replace the app can also ad hoc sign a different app. App bundle location and local account security matter.
- Accessibility values are checked for CF type, AX value subtype, finite coordinates, and positive dimensions before geometry is used. Calls have a 250 ms messaging timeout. Target apps can still reject or partially apply frame changes.
- There are no credentials, API keys, network endpoints, or third-party packages to manage in the current implementation. Future changes must be reviewed against this statement.
- SwiftPM's subprocess sandbox is retained by default. `SWIFTPM_DISABLE_SANDBOX=1` is a deliberate build-host workaround, not a recommended routine setting.
- There is no automatic update channel. Review revisions before executing their scripts; clone/build workflows execute code from the selected revision. Keep Apple's toolchain and macOS updated.

## Workplace distribution

Ask your organization's IT/security team to review this source and the requested Accessibility permission. Managed policy may forbid custom builds or user-approved Accessibility access. Do not bypass those restrictions.

For a publisher-authenticated build, provision a suitable certificate using your organization's approved process, then build with its exact identity:

```sh
CODE_SIGN_IDENTITY='Developer ID Application: Your Organization (TEAMID)' bash scripts/build-app.sh
```

This enables timestamped certificate signing. It can contact Apple's timestamp service and does **not** notarize the result. Default ad hoc signing does not use that timestamp service. Use Apple's [notarization workflow](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution) before sharing a downloadable workplace release, including ticket stapling and Gatekeeper validation. Notarization checks are not a guarantee of absence of vulnerabilities.

The downloadable Apple Silicon beta is locally ad hoc signed; it is not a Developer ID signed or notarized workplace release. No certificate, credentials, notarization submission, or managed deployment has been provisioned by this project. Stable certificate identity can also avoid the repeated privacy identity changes associated with ad hoc rebuilds.

## Inspect a build

```sh
codesign --verify --strict --verbose=2 "dist/Window Snapper.app"
codesign -dv --verbose=4 "dist/Window Snapper.app"
codesign -d --entitlements :- "dist/Window Snapper.app"
otool -L "dist/Window Snapper.app/Contents/MacOS/WindowSnapper"
```

Check that the flags include `runtime`, that no exception entitlements have been added, and that linked libraries are expected Apple system libraries. These checks do not establish that the binary matches reviewed source or that its behavior is harmless. For a downloadable certificate-signed release, also validate notarization and Gatekeeper acceptance through your organization's release checks.

## Reporting concerns

Do not post workplace data, credentials, or sensitive screenshots in public issues. This repository has no designated private vulnerability-reporting channel yet. Until one is established, report workplace incidents to your IT/security team and revoke the app's Accessibility permission if you suspect compromise.
