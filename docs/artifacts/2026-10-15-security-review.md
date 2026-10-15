# Security review and source installation

Status: Implemented; limited review, not independently audited
Updated: 2026-10-15

## Quick read

Reviewed the app and build sources for security-sensitive behavior. No network client, document reader, clipboard reader, shell runner, telemetry, arbitrary keystroke monitor, downloaded code, or third-party dependency was found. Accessibility remains a broad OS permission, and the app is not App Sandbox confined.

Enabled Hardened Runtime, retained SwiftPM's build sandbox by default, added optional certificate signing, and validated incoming window geometry. Added source installation and workplace security documentation. Next: obtain IT review and approved signing/notarization before workplace distribution. Source files must be committed and pushed before others can clone this implementation.

## Changed surface

| Surface | Details |
| --- | --- |
| Build hardening | [Packaging script](../../scripts/build-app.sh): Hardened Runtime, strict signature verification, optional timestamped identity, explicit sandbox opt-out |
| Input checks | [WindowMover](../../Sources/WindowSnapper/main.swift): AX subtype, finite coordinates, positive dimensions, explicit conversion errors |
| Installation | [README](../../README.md): prerequisites, actual repository URL, source build, architecture, install, permissions, update and uninstall |
| Risk inventory | [SECURITY](../../SECURITY.md): permission/data inventory, trust boundary, residual risks, workplace signing and reporting |

## Engineer details

### Decisions and flow

The existing shortcut → focused Accessibility window → frame calculation → geometry write flow is retained. Defensive checks reject invalid frame values before mutation. The app continues to use only Apple frameworks. Hardened Runtime adds code integrity protections without exception entitlements; it does not enforce a network or filesystem sandbox. Certificate signing is optional because no organizational identity is provisioned. No agents were delegated.

### Evidence

- Release packaging succeeded using `SWIFTPM_DISABLE_SANDBOX=1 bash scripts/build-app.sh`; the explicit workaround is needed for this restricted build host.
- `codesign --verify --strict --verbose=2` passed during packaging.
- Signature inspection on the hardened build showed `flags=0x10002(adhoc,runtime)`, no team identity, and no entitlements output.
- `otool -L` listed Apple system frameworks and system Swift libraries only.
- `bash -n scripts/build-app.sh` and `plutil -lint Resources/Info.plist` passed.
- Reviewed all source/build files, Package.swift, and Info.plist. A supplementary source search for common networking, shell, clipboard, event tap, logging, and URL patterns returned no matches in application/package/script sources. Search is supporting evidence, not proof of all possible behavior.
- `git log` and `git ls-tree HEAD` showed no local commit exists. No commit, push, or release publication was performed.

### Limits and follow-ups

No independent audit, penetration test, runtime network capture, multi-version/Intel validation, certificate-signing execution, notarization, Gatekeeper release acceptance, or managed workplace deployment was performed. The hardened app was built into `dist`; the installed Applications copy was not replaced. Hardened Runtime snapping has not been exercised in the UI. Replacing the installed app may require renewing Accessibility approval.

Accessibility cannot be scoped to window resizing through the current APIs. Local-only code does not by itself establish workplace safety. IT approval, trusted source revisions/toolchains, signing identity, notarization, secure distribution, and future change review remain necessary organizational decisions.

## Source publication preparation

The README now includes the app icon, a feature overview, install routes, and the simplest local ZIP-sharing instructions. It distinguishes source ZIPs from prebuilt apps and states that no Homebrew cask or public binary release is provided. Build products, logs, local environment files, and signing material are excluded through `.gitignore`.

Reviewed the staged source/documentation and generated icon assets. A staged-file scan for private keys, common provider tokens, assigned credentials, and personal machine paths passed. Markdown local links and `git diff --cached --check` passed. The scan is a heuristic check, not a guarantee that every possible secret format is detected. The generated PNG contains color/format metadata; no user-supplied images or screenshots are included. Publication is source-only to the configured GitHub origin; app signing/notarization remains a separate follow-up.
