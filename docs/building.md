[← Overview](../README.md)

# Building from source

## Requirements

- macOS 13 or newer.
- Apple's Xcode Command Line Tools, including **Swift 6.0 or newer**. A Mac that can run the app may still need a newer macOS/toolchain to build it. Full Xcode also works.
- Git, included with the Command Line Tools.
- Permission from your employer to run a custom app with Accessibility access on a managed Mac.

Install Apple's tools if needed:

```sh
xcode-select --install
```

After installation, check `swift --version`. If Swift is older than 6.0, install a compatible newer Apple toolchain before continuing.

## Build

Review the source and scripts before running them, then:

```sh
git clone https://github.com/kazuki0216/Window-Snapper.git
cd Window-Snapper
bash scripts/build-app.sh
```

The script compiles a release binary, generates the icon, packages **`dist/Window Snapper.app`**, signs it locally with Hardened Runtime, and verifies its signature. It builds for the host Mac's architecture. An Apple Silicon build is not a universal binary for Intel Macs; build on each target architecture or use a separately prepared universal release.

The package has no third-party dependencies. Git cloning and installing Apple tools require network access; the local default app build does not intentionally download dependencies or submit the app anywhere.

After building, move `dist/Window Snapper.app` into Applications, then follow [permissions and first use](installation.md#permissions-and-first-use). An administrator may need to authorize installation on a managed Mac.

## Build troubleshooting

If an automated or restricted build host rejects SwiftPM's nested build sandbox, this explicit workaround is available:

```sh
SWIFTPM_DISABLE_SANDBOX=1 bash scripts/build-app.sh
```

This disables **SwiftPM's build subprocess sandbox for that invocation**, not a security setting on the installed app. Use the default command when it works.

## App icon

The charcoal icon with ivory placement guides and a coral snapped pane is drawn with AppKit from [editable Swift artwork](../scripts/generate-icon.swift). The build script generates every macOS icon size and packages `Resources/AppIcon.icns`. A full-size preview is saved as [AppIcon.png](../Resources/AppIcon.png).

## Engineering notes

- [Implementation summary](artifacts/2026-10-15-window-snapper.md)
- [Security review](artifacts/2026-10-15-security-review.md)
- [License and repository governance](artifacts/2026-10-15-license-and-governance.md)
- [Initial beta packaging](artifacts/2026-10-15-prebuilt-release.md)
