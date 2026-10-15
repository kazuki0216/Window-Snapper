[← Overview](../README.md)

# Installation

## Download and install

1. Open the [v0.1.0 beta release](https://github.com/kazuki0216/Window-Snapper/releases/tag/v0.1.1-beta.1).
2. Under **Assets**, download **`Window-Snapper-0.1.1-arm64.zip`**. Choose this file, rather than GitHub's automatically generated **Source code** archives.
3. Double-click the ZIP in Finder, then drag **Window Snapper.app** into **Applications**.
4. Quit any older copy and open Window Snapper from Applications. Enable its **Accessibility** permission when prompted.
5. Focus a normal window and press **Control + Option + Left Arrow**.

**Compatibility:** this beta is for **Apple Silicon Macs (M1 or newer)**, with a declared minimum of macOS 13. This download does not support Intel Macs or macOS versions earlier than 13. Compatibility across macOS versions has not been validated. No Swift, Xcode, Git, or Homebrew installation is needed to run it.

**Signing:** this is an experimental, locally ad hoc signed build, **not Developer ID signed or Apple-notarized**. macOS may refuse to open it, and managed work Macs may prohibit it. Follow your organization's approved process; do not disable Gatekeeper, SIP, or endpoint protection. See [Apple's guidance on opening apps safely](https://support.apple.com/102445). A seamless verified download requires Developer ID signing and notarization.

Optional integrity check: download the matching `.sha256` file alongside the app ZIP and, in that directory, run `shasum -a 256 -c Window-Snapper-0.1.1-arm64.zip.sha256`. This detects a mismatched download; it is not a publisher identity or safety guarantee.

## Permissions and first use

Open the installed app from Applications before granting access. If updating, quit the older copy first.

1. Go to **System Settings → Privacy & Security → Accessibility**. The permission label can vary with macOS version.
2. Enable **Window Snapper**. If absent, use the + button to add the Applications copy.
3. Return to a normal, non-full-screen window and press **Control + Option + Left Arrow**.

Click its window symbol in the menu bar for settings and actions. There is no Dock icon. Input Monitoring, Screen Recording, Full Disk Access, and administrator privileges are not needed by the app. Disable conflicting shortcuts in Rectangle before using both apps.

If macOS or your employer blocks an unverified app, use your organization's approved distribution process. Do not disable Gatekeeper, SIP, or endpoint protection. A locally ad hoc signed build is not a substitute for a Developer ID signed, notarized workplace release.

## Updates and removal

Updates are manual: download a newer compatible release, or review and build a new source revision. Quit the installed app before replacing it. There is no automatic updater or background download. Rebuilt ad hoc signatures can invalidate Accessibility approval; follow the Accessibility troubleshooting steps below if necessary.

To uninstall, disable Launch at Login in the menu if enabled, quit the app, remove its Accessibility entry, and move the app to Trash. The app stores its small preferences under the `com.windowsnapper.app` UserDefaults domain; deleting the app does not necessarily remove these preferences.

## Accessibility troubleshooting

If Settings shows Window Snapper enabled but the app still asks for access:

1. Quit Window Snapper using its menu bar menu.
2. In System Settings → Privacy & Security → Accessibility, select Window Snapper and remove its entry using the minus button.
3. Add `/Applications/Window Snapper.app` using the plus button and enable it.
4. Reopen the app from Applications, focus a normal Finder or Safari window, and try Control + Option + Left Arrow.

Recent local rebuilds can invalidate an earlier approval because the app is ad hoc signed. Remove and re-add the current installed copy rather than only toggling an older entry. If the menu says Accessibility Enabled but shortcuts do nothing, try its Left Half menu action and check Shortcut Conflicts; this distinguishes window control from hotkey registration problems.

## Other installation routes

To compile the app yourself, follow [Building from source](building.md). GitHub’s **Download ZIP** downloads source, not an installable app. There is no Homebrew cask yet.
