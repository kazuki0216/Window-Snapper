# Custom menu bar icon

Status: Implemented
Updated: 2026-10-15

## Quick read

Replaced the four-panel system symbol with a custom snapped pane inside open corner guides. It matches the app icon's geometry while using a monochrome macOS template for automatic appearance tinting. Version 0.1.1, build 3 packages the change for the next Apple Silicon beta.

Next: install the updated app and renew Accessibility approval if macOS requires it.

## Changed surface

| Area | Source |
| --- | --- |
| Vector artwork | [MenuBarIcon.swift](../../Sources/WindowSnapper/MenuBarIcon.swift) |
| Status item | [main.swift](../../Sources/WindowSnapper/main.swift) |
| Version | [Info.plist](../../Resources/Info.plist) |
| Updated download | [README](../../README.md), [installation](../installation.md) |

## Engineer details

The 18-point NSImage draws four rounded corner guides and one solid pane through AppKit paths. `isTemplate` delegates tinting to macOS; `accessibilityDescription` retains the app name. Drawing uses no external assets, dependencies, timers, or new permissions. No agents were delegated.

The release packaging script completed successfully; the built and extracted bundles both passed strict signature verification, and bundled notices and executable permission checks passed. A local native rendering was visually inspected at 18 points and enlarged. `git diff --check` passed. The live status item in light/dark appearance has not been inspected; appearance tinting follows NSImage's template behavior. The installed Applications copy was not replaced automatically.

The beta remains Apple Silicon only, ad hoc signed, and not notarized. No window-control behavior or security permissions changed. Rebuilding may invalidate previous Accessibility approval.
