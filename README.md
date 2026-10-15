<div align="center">
  <img src="Resources/AppIcon.png" width="128" height="128" alt="Window Snapper: a coral pane inside ivory placement guides on a charcoal tile">
  <h1>Window Snapper</h1>
  <p><strong>A shortcut. A snap. Back to work.</strong></p>
  <p>A small native macOS menu bar app for putting windows where you want them.</p>
  <p><strong>Swift</strong> · <strong>Apple frameworks only</strong> · <strong>No third-party dependencies</strong></p>
  <p><a href="#get-started">Get started</a> · <a href="#shortcuts">Shortcuts</a> · <a href="SECURITY.md">Security</a></p>
</div>

---

## Made for the keyboard

| Arrange | Move | Stay out of the way |
| --- | --- | --- |
| Halves, quarters, maximize, and center | Move to the next display or restore a previous frame | Menu bar controls, global shortcuts, and optional launch at login |

Snapping responds directly to keyboard events, with no animation timers or continuous polling. Actual speed depends on the app being resized; latency has not been benchmarked.

## Get started

**Already have `Window Snapper.app`?** Move it to Applications, open it, and grant Accessibility permission. You do not need Swift, Xcode, Homebrew, or additional libraries to run a compatible prebuilt app.

**Only have this repository?** Follow [Build from source](#build-from-source). GitHub's **Download ZIP** downloads the source, not a ready-to-run app.

| Route | What to download | Available now? |
| --- | --- | --- |
| Build from source | This repository and Apple's developer tools with Swift 6+ | Yes |
| Install a prebuilt app | Only the app ZIP for your Mac's architecture | No published release yet |
| Homebrew | Homebrew and a Window Snapper cask | No cask yet |

### Simplest way to share a local build

1. Build once using the instructions below.
2. In Finder, right-click `dist/Window Snapper.app` and choose **Compress**.
3. Give the resulting ZIP to the recipient through an approved channel.
4. The recipient unzips it, moves the app into Applications, opens it, and grants Accessibility access.

The recipient needs no developer tools. Share a compatible build: the default build targets the builder's architecture, so an Apple Silicon build does not support Intel Macs. The declared minimum is macOS 13; cross-version compatibility has not yet been validated.

Local builds are ad hoc signed, not publisher-authenticated or notarized. For work or wider distribution, use IT-approved Developer ID signing and notarization. A downloaded ZIP may be blocked by macOS or managed policy. Do not disable security protections to install it. See [SECURITY.md](SECURITY.md).

## Build from source

### Requirements

- macOS 13 or newer.
- Apple's Xcode Command Line Tools, including **Swift 6.0 or newer**. A Mac that can run the app may still need a newer macOS/toolchain to build it. Full Xcode also works.
- Git, included with the Command Line Tools.
- Permission from your employer to run a custom app with Accessibility access on a managed Mac.

Install Apple's tools if needed:

```sh
xcode-select --install
```

After installation, check `swift --version`. If Swift is older than 6.0, install a compatible newer Apple toolchain before continuing.

### Build

Review the source and scripts before running them, then:

```sh
git clone https://github.com/kazuki0216/Window-Snapper.git
cd Window-Snapper
bash scripts/build-app.sh
```

The script compiles a release binary, generates the icon, packages **`dist/Window Snapper.app`**, signs it locally with Hardened Runtime, and verifies its signature. It builds for the host Mac's architecture. An Apple Silicon build is not a universal binary for Intel Macs; build on each target architecture or use a separately prepared universal release.

The package has no third-party dependencies. Git cloning and installing Apple tools require network access; the local default app build does not intentionally download dependencies or submit the app anywhere.

### Install and enable

1. Quit any running copy of Window Snapper.
2. In Finder, move `dist/Window Snapper.app` into **Applications**. Replace an older copy if updating. An administrator may need to authorize this on a managed Mac.
3. Open **Window Snapper from Applications**.
4. Grant **System Settings → Privacy & Security → Accessibility → Window Snapper**. If it is absent, use the + button to add the Applications copy. The permission label can vary with macOS version.
5. Focus a normal, non-full-screen window and press **Control + Option + Left Arrow**.

Click its window symbol in the menu bar for settings and actions. There is no Dock icon. Input Monitoring, Screen Recording, Full Disk Access, and administrator privileges are not needed by the app. Disable conflicting shortcuts in Rectangle before using both apps.

If macOS or your employer blocks an unverified app, use your organization's approved distribution process. Do not disable Gatekeeper, SIP, or endpoint protection. A locally ad hoc signed build is not a substitute for a Developer ID signed, notarized workplace release.

### Build troubleshooting

If an automated or restricted build host rejects SwiftPM's nested build sandbox, this explicit workaround is available:

```sh
SWIFTPM_DISABLE_SANDBOX=1 bash scripts/build-app.sh
```

This disables **SwiftPM's build subprocess sandbox for that invocation**, not a security setting on the installed app. Use the default command when it works.

### Updates and removal

Updates are manual: review a new revision, build it, quit the installed app, and replace it. There is no automatic updater or background download. Rebuilt ad hoc signatures can invalidate Accessibility approval; follow the steps below if necessary.

To uninstall, disable Launch at Login in the menu if enabled, quit the app, remove its Accessibility entry, and move the app to Trash. The app stores its small preferences under the `com.windowsnapper.app` UserDefaults domain; deleting the app does not necessarily remove these preferences.

## Shortcuts

Hold **Control + Option** with the following keys:

| Key | Action |
| --- | --- |
| ← / → | Left / right half |
| ↑ / ↓ | Top / bottom half |
| U / I | Top left / top right quarter |
| J / K | Bottom left / bottom right quarter |
| Return | Maximize within the usable screen |
| C | Center, retaining the size when it fits |
| Delete | Restore the previous frame; press again to toggle |
| N | Move to the next display |

The menu offers a **Control + Option + Command** preset if shortcuts conflict with other apps. Letter shortcuts use physical US keyboard positions. Quit other window managers or change their bindings to avoid conflicts. The menu reports shortcuts macOS refused to register.

Enable **Launch at Login** from the menu after placing the app in its permanent location. macOS may ask you to approve it in Login Items.

## Security and workplace use

Local operation reduces exposure, but **Accessibility grants broader access than moving windows**. macOS does not give this app a resize-only permission. Review and trust the installed code, and obtain IT approval before using it with work data.

The reviewed implementation has no networking, analytics, general keystroke recorder, document reading, clipboard access, shell execution, plugins, or automatic updates. It reads focused-window geometry and full-screen state on demand, writes position and size, and keeps up to 50 restore frames in memory. It stores two preferences and optionally registers itself for login. Normal operating-system diagnostics may still be generated by macOS.

The app is **not App Sandbox confined**. Absence of network code is a source-level property, not an enforced outbound network ban. Hardened Runtime is enabled with no exception entitlements; this reduces some injection risks but does not make the app risk-free. Default ad hoc signing does not prove publisher identity, and this project has not received an independent security audit.

For IT review, see [SECURITY.md](SECURITY.md), including the permission/data inventory, remaining risks, build verification, and Developer ID signing instructions. A workplace rollout should use your organization's approved signing, notarization, and deployment process.

## Accessibility troubleshooting

If Settings shows Window Snapper enabled but the app still asks for access:

1. Quit Window Snapper using its menu bar menu.
2. In System Settings → Privacy & Security → Accessibility, select Window Snapper and remove its entry using the minus button.
3. Add `/Applications/Window Snapper.app` using the plus button and enable it.
4. Reopen the app from Applications, focus a normal Finder or Safari window, and try Control + Option + Left Arrow.

Recent local rebuilds can invalidate an earlier approval because the app is ad hoc signed. Remove and re-add the current installed copy rather than only toggling an older entry. If the menu says Accessibility Enabled but shortcuts do nothing, try its Left Half menu action and check Shortcut Conflicts; this distinguishes window control from hotkey registration problems.

## Behavior and limitations

- Snaps use each display’s usable area, respecting the Dock and menu bar. The display containing the largest portion of the window is selected.
- Native hotkey events trigger Accessibility API calls directly. There are no animation timers, polling loops, or network calls. Actual response time depends on the target app; no latency benchmark has been performed.
- Restore remembers up to 50 windows in memory and resets on quit. Moving to another monitor keeps the size when possible and preserves relative placement.
- Apps can enforce minimum sizes or reject changes. Full screen windows must leave full screen before snapping. System dialogs and apps without accessible resizable windows may not work.
- Dragging to screen edges and placement previews are future work.
- The build is locally ad hoc signed, suitable for personal use. Distribution to other people requires an appropriate signing and notarization workflow. Rebuilding or relocating may require granting Accessibility access again.

Implementation notes: [work summary](docs/artifacts/2026-10-15-window-snapper.md).

## App icon

The charcoal icon with ivory placement guides and a coral snapped pane is drawn with AppKit from [editable Swift artwork](scripts/generate-icon.swift). The build script generates every macOS icon size and packages `Resources/AppIcon.icns`. A full-size preview is saved as [AppIcon.png](Resources/AppIcon.png).
