# Window Snapper implementation

Status: Implemented; runtime behavior unverified
Updated: 2026-10-15

## Quick read

Created a native Swift menu bar app for moving and resizing the focused window using global shortcuts. It supports halves, quarters, maximize, center, restore, moving between displays, two shortcut presets, and launch at login.

The release app compiled and was packaged with a local ad hoc signature at `dist/Window Snapper.app`. Open it from its permanent location and grant Accessibility access. Live snapping and latency have not been checked.

## Changed surface

| Area | Status | Details |
| --- | --- | --- |
| App and window control | Implemented | [Swift source](../../Sources/WindowSnapper/main.swift) |
| Package | Implemented | [Package.swift](../../Package.swift) |
| App metadata | Implemented | [Info.plist](../../Resources/Info.plist) |
| Release packaging | Build succeeded | [Build script](../../scripts/build-app.sh) |
| Setup and shortcuts | Documented | [README](../../README.md) |
| App icon | Implemented | [Editable artwork](../../scripts/generate-icon.swift), [PNG preview](../../Resources/AppIcon.png), [macOS icon](../../Resources/AppIcon.icns) |

## Engineer details

### Design and flow

Carbon hotkey events and menu actions invoke the same window mover. It finds the frontmost app’s focused Accessibility window, reads its frame, chooses the display with the largest intersection, calculates the desired frame, then moves and resizes it. AppKit screen coordinates are converted to Accessibility coordinates using the primary display. Visible screen bounds exclude the menu bar and Dock.

No polling, animation timers, networking, or third-party dependencies are used. Accessibility calls have a 250 ms messaging timeout; actual timing depends on the controlled app. No performance measurements have been taken.

The app icon uses native AppKit artwork: a charcoal rounded tile, four ivory placement guides, and a single flat coral snapped pane. The packaging script renders all standard icon sizes, creates the ICNS resource, copies it into the bundle before signing, and references it through `CFBundleIconFile`. The menu bar continues to use a monochrome system symbol suitable for that surface. No image generation service was used.

Restore stores the previous successful frame for up to 50 windows in memory; repeated restore toggles between frames. Shortcut presets persist through UserDefaults. Login registration uses SMAppService. No agents were delegated.

### Build evidence

`bash scripts/build-app.sh` completed with exit code 0: `Build complete! (1.39 sec)`, followed by successful ad hoc signing and app packaging. The build uses workspace-local module caches. Debug information is disabled because this environment denied the initial dSYM generation step. Command Line Tools emitted missing optional developer search path warnings; linking succeeded.

No automated tests or live window manipulation were run. Accessibility approval must be granted through macOS by the user. Login behavior, monitor transitions, target app compatibility, and shortcut behavior remain unverified at runtime.

Icon update: visually inspected the generated 1024 px PNG. The app rebuild completed with exit code 0 (`Build complete! (1.54 sec)`) and successful signing after bundling the ICNS resource. The generator writes the ICNS container directly because iconutil rejected the iconset in this environment. Finder’s cached icon display has not been checked.

### Risks and follow-ups

- Apps may enforce minimum window sizes, reject resize requests, or expose no accessible focused window. Some failed changes may partially move the window.
- Full screen windows require leaving full screen before snapping.
- Shortcut registration conflicts are shown in the menu; letter keys use physical US layout positions.
- Local ad hoc signing is intended for personal use; rebuilding may require granting Accessibility permission again. Distribution signing and notarization are not implemented.
- Dragging to screen edges, placement previews, arbitrary shortcut editing, and latency benchmarking are not implemented.

Finder icon refresh: the screenshot showed the old blue icon despite matching source and bundled ICNS checksums. Renamed the bundled resource to `AppIcon-Modern.icns`, bumped CFBundleVersion to 2, and touched the rebuilt bundle. Build succeeded (2.04 sec); `codesign --verify` passed. Extracted the bundled ICNS using sips and visually confirmed the charcoal/coral artwork. Finder cache refresh itself remains unverified; reopening the folder may be needed.
