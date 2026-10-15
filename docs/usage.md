[← Overview](../README.md)

# Using Window Snapper

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

## Behavior and limitations

- Snaps use each display’s usable area, respecting the Dock and menu bar. The display containing the largest portion of the window is selected.
- Native hotkey events trigger Accessibility API calls directly. There are no animation timers, polling loops, or network calls. Actual response time depends on the target app; no latency benchmark has been performed.
- Restore remembers up to 50 windows in memory and resets on quit. Moving to another monitor keeps the size when possible and preserves relative placement.
- Apps can enforce minimum sizes or reject changes. Full screen windows must leave full screen before snapping. System dialogs and apps without accessible resizable windows may not work.
- Dragging to screen edges and placement previews are future work.
- The build is locally ad hoc signed, suitable for personal use. Distribution to other people requires an appropriate signing and notarization workflow. Rebuilding or relocating may require granting Accessibility access again.
