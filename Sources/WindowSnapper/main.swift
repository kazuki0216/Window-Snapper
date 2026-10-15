import AppKit
import ApplicationServices
import Carbon
import ServiceManagement

enum SnapAction: Int, CaseIterable {
    case left = 1, right, top, bottom, topLeft, topRight, bottomLeft, bottomRight
    case maximize, center, restore, nextDisplay

    var title: String {
        switch self {
        case .left: return "Left Half"
        case .right: return "Right Half"
        case .top: return "Top Half"
        case .bottom: return "Bottom Half"
        case .topLeft: return "Top Left Quarter"
        case .topRight: return "Top Right Quarter"
        case .bottomLeft: return "Bottom Left Quarter"
        case .bottomRight: return "Bottom Right Quarter"
        case .maximize: return "Maximize"
        case .center: return "Center"
        case .restore: return "Restore Previous Size"
        case .nextDisplay: return "Move to Next Display"
        }
    }

    var key: (UInt32, String) {
        switch self {
        case .left: return (UInt32(kVK_LeftArrow), "\u{f702}")
        case .right: return (UInt32(kVK_RightArrow), "\u{f703}")
        case .top: return (UInt32(kVK_UpArrow), "\u{f700}")
        case .bottom: return (UInt32(kVK_DownArrow), "\u{f701}")
        case .topLeft: return (UInt32(kVK_ANSI_U), "u")
        case .topRight: return (UInt32(kVK_ANSI_I), "i")
        case .bottomLeft: return (UInt32(kVK_ANSI_J), "j")
        case .bottomRight: return (UInt32(kVK_ANSI_K), "k")
        case .maximize: return (UInt32(kVK_Return), "\r")
        case .center: return (UInt32(kVK_ANSI_C), "c")
        case .restore: return (UInt32(kVK_Delete), "\u{7f}")
        case .nextDisplay: return (UInt32(kVK_ANSI_N), "n")
        }
    }
}

enum ShortcutPreset: Int, CaseIterable {
    case controlOption, controlOptionCommand
    var title: String { self == .controlOption ? "Control + Option" : "Control + Option + Command" }
    var carbon: UInt32 { UInt32(controlKey | optionKey | (self == .controlOptionCommand ? cmdKey : 0)) }
    var cocoa: NSEvent.ModifierFlags { self == .controlOption ? [.control, .option] : [.control, .option, .command] }
}

final class HotKeys {
    private var references: [EventHotKeyRef] = []
    private var handler: EventHandlerRef?
    var onAction: ((SnapAction) -> Void)?

    init() {
        var type = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, context in
            guard let event, let context else { return OSStatus(eventNotHandledErr) }
            var identifier = EventHotKeyID()
            let result = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &identifier)
            guard result == noErr, identifier.signature == 0x57534E50,
                  let action = SnapAction(rawValue: Int(identifier.id)) else { return OSStatus(eventNotHandledErr) }
            Unmanaged<HotKeys>.fromOpaque(context).takeUnretainedValue().onAction?(action)
            return noErr
        }, 1, &type, Unmanaged.passUnretained(self).toOpaque(), &handler)
    }

    func register(_ preset: ShortcutPreset) -> [String] {
        references.forEach { UnregisterEventHotKey($0) }
        references.removeAll()
        var conflicts: [String] = []
        for action in SnapAction.allCases {
            var ref: EventHotKeyRef?
            let id = EventHotKeyID(signature: 0x57534E50, id: UInt32(action.rawValue))
            let status = RegisterEventHotKey(action.key.0, preset.carbon, id, GetApplicationEventTarget(), 0, &ref)
            if status == noErr, let ref { references.append(ref) }
            else { conflicts.append(action.title) }
        }
        return conflicts
    }

    deinit {
        references.forEach { UnregisterEventHotKey($0) }
        if let handler { RemoveEventHandler(handler) }
    }
}

struct SnapFailure: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

final class WindowMover {
    private struct Previous { let window: AXUIElement; let frame: CGRect }
    private var history: [Previous] = []

    func perform(_ action: SnapAction) throws {
        guard AXIsProcessTrusted() else {
            throw SnapFailure(message: "Enable Window Snapper in System Settings → Privacy & Security → Accessibility, then try again.")
        }
        guard let app = NSWorkspace.shared.frontmostApplication, app.processIdentifier != ProcessInfo.processInfo.processIdentifier else {
            throw SnapFailure(message: "Select a window in another app first.")
        }
        let element = AXUIElementCreateApplication(app.processIdentifier)
        AXUIElementSetMessagingTimeout(element, 0.25)
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXFocusedWindowAttribute as CFString, &value) == .success,
              let value, CFGetTypeID(value) == AXUIElementGetTypeID() else {
            throw SnapFailure(message: "This app has no accessible focused window.")
        }
        let window = value as! AXUIElement
        AXUIElementSetMessagingTimeout(window, 0.25)
        var fullscreen: CFTypeRef?
        if AXUIElementCopyAttributeValue(window, "AXFullScreen" as CFString, &fullscreen) == .success,
           (fullscreen as? Bool) == true {
            throw SnapFailure(message: "Leave full screen before snapping this window.")
        }
        let original = try frame(of: window)
        let screens = NSScreen.screens
        guard let primary = screens.first else { return }
        // Accessibility uses a top-left origin; AppKit uses a bottom-left origin.
        func axRect(_ rect: CGRect) -> CGRect {
            CGRect(x: rect.minX, y: primary.frame.maxY - rect.maxY, width: rect.width, height: rect.height)
        }
        let current = screens.max { a, b in
            area(original.intersection(axRect(a.frame))) < area(original.intersection(axRect(b.frame)))
        } ?? primary
        let bounds = axRect(current.visibleFrame)
        var target = bounds
        switch action {
        case .left, .right:
            target.size.width /= 2
            if action == .right { target.origin.x += target.width }
        case .top, .bottom:
            target.size.height /= 2
            if action == .bottom { target.origin.y += target.height }
        case .topLeft, .topRight, .bottomLeft, .bottomRight:
            target.size.width /= 2; target.size.height /= 2
            if action == .topRight || action == .bottomRight { target.origin.x += target.width }
            if action == .bottomLeft || action == .bottomRight { target.origin.y += target.height }
        case .maximize: break
        case .center:
            target.size = CGSize(width: min(original.width, bounds.width), height: min(original.height, bounds.height))
            target.origin = CGPoint(x: bounds.midX - target.width / 2, y: bounds.midY - target.height / 2)
        case .restore:
            guard let previous = history.last(where: { CFEqual($0.window, window) }) else { return }
            target = previous.frame
        case .nextDisplay:
            guard screens.count > 1, let index = screens.firstIndex(of: current) else { return }
            let destination = axRect(screens[(index + 1) % screens.count].visibleFrame)
            let width = min(original.width, destination.width)
            let height = min(original.height, destination.height)
            let xRatio = (original.minX - bounds.minX) / max(1, bounds.width - original.width)
            let yRatio = (original.minY - bounds.minY) / max(1, bounds.height - original.height)
            target = CGRect(x: destination.minX + min(1, max(0, xRatio)) * (destination.width - width),
                            y: destination.minY + min(1, max(0, yRatio)) * (destination.height - height), width: width, height: height)
        }
        try setFrame(target, on: window)
        history.removeAll { CFEqual($0.window, window) }
        history.append(Previous(window: window, frame: original))
        if history.count > 50 { history.removeFirst() }
    }

    private func area(_ rect: CGRect) -> CGFloat { rect.isNull ? 0 : rect.width * rect.height }

    private func frame(of window: AXUIElement) throws -> CGRect {
        var position: CFTypeRef?; var size: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &position) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &size) == .success,
              let position, let size, CFGetTypeID(position) == AXValueGetTypeID(), CFGetTypeID(size) == AXValueGetTypeID() else {
            throw SnapFailure(message: "Unable to read this window’s size or position.")
        }
        var point = CGPoint.zero; var dimensions = CGSize.zero
        guard AXValueGetType(position as! AXValue) == .cgPoint,
              AXValueGetType(size as! AXValue) == .cgSize,
              AXValueGetValue(position as! AXValue, .cgPoint, &point),
              AXValueGetValue(size as! AXValue, .cgSize, &dimensions),
              validFrame(CGRect(origin: point, size: dimensions)) else {
            throw SnapFailure(message: "This window does not expose a supported frame.")
        }
        return CGRect(origin: point, size: dimensions)
    }

    private func setFrame(_ rect: CGRect, on window: AXUIElement) throws {
        guard validFrame(rect) else {
            throw SnapFailure(message: "This window returned invalid dimensions. No change was made.")
        }
        var point = rect.origin; var size = rect.size
        guard let position = AXValueCreate(.cgPoint, &point), let dimensions = AXValueCreate(.cgSize, &size) else {
            throw SnapFailure(message: "Unable to prepare this window’s position or size.")
        }
        // Move, resize, then move again: apps can constrain position using the old size.
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
        let resize = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, dimensions)
        let move = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position)
        guard resize == .success, move == .success else {
            throw SnapFailure(message: "This window could not be resized or moved. Some apps restrict window changes.")
        }
    }

    private func validFrame(_ rect: CGRect) -> Bool {
        rect.origin.x.isFinite && rect.origin.y.isFinite &&
        rect.size.width.isFinite && rect.size.height.isFinite &&
        rect.size.width > 0 && rect.size.height > 0
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let hotKeys = HotKeys()
    private let mover = WindowMover()
    private var conflicts: [String] = []
    private var preset: ShortcutPreset {
        ShortcutPreset(rawValue: UserDefaults.standard.integer(forKey: "shortcutPreset")) ?? .controlOption
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = MenuBarIcon.make()
        statusItem.button?.toolTip = "Window Snapper"
        hotKeys.onAction = { [weak self] in self?.snap($0) }
        conflicts = hotKeys.register(preset)
        rebuildMenu()
        if !UserDefaults.standard.bool(forKey: "hasLaunched") {
            UserDefaults.standard.set(true, forKey: "hasLaunched")
            showMessage("Welcome to Window Snapper", "Use Control + Option + arrow keys to snap the focused window. Enable Accessibility in System Settings to get started. All actions and shortcut presets are available in the menu bar.")
            requestAccessibility()
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) { rebuildMenu() }

    private func rebuildMenu() {
        let menu = statusItem.menu ?? NSMenu()
        menu.removeAllItems()
        menu.delegate = self
        let permission = NSMenuItem(title: AXIsProcessTrusted() ? "Accessibility Enabled" : "Enable Accessibility…", action: #selector(requestAccessibility), keyEquivalent: "")
        permission.target = self; permission.isEnabled = !AXIsProcessTrusted(); menu.addItem(permission)
        menu.addItem(.separator())
        for action in SnapAction.allCases {
            let item = NSMenuItem(title: action.title, action: #selector(menuSnap(_:)), keyEquivalent: action.key.1)
            item.keyEquivalentModifierMask = preset.cocoa
            item.tag = action.rawValue; item.target = self; menu.addItem(item)
        }
        menu.addItem(.separator())
        let shortcuts = NSMenuItem(title: "Shortcut Modifiers", action: nil, keyEquivalent: "")
        let submenu = NSMenu()
        for option in ShortcutPreset.allCases {
            let item = NSMenuItem(title: option.title, action: #selector(changePreset(_:)), keyEquivalent: "")
            item.target = self; item.tag = option.rawValue; item.state = option == preset ? .on : .off
            submenu.addItem(item)
        }
        shortcuts.submenu = submenu; menu.addItem(shortcuts)
        if !conflicts.isEmpty {
            let warning = NSMenuItem(title: "Shortcut Conflicts…", action: #selector(showConflicts), keyEquivalent: "")
            warning.target = self; menu.addItem(warning)
        }
        let login = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self; login.state = SMAppService.mainApp.status == .enabled ? .on : .off; menu.addItem(login)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Window Snapper", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quit.target = NSApplication.shared; menu.addItem(quit)
        statusItem.menu = menu
    }

    private func snap(_ action: SnapAction) {
        do { try mover.perform(action) }
        catch { showMessage("Unable to Snap Window", error.localizedDescription) }
    }
    @objc private func menuSnap(_ sender: NSMenuItem) {
        guard let action = SnapAction(rawValue: sender.tag) else { return }
        snap(action)
    }
    @objc private func changePreset(_ sender: NSMenuItem) {
        UserDefaults.standard.set(sender.tag, forKey: "shortcutPreset")
        conflicts = hotKeys.register(preset)
        if !conflicts.isEmpty { showConflicts() }
    }
    @objc private func showConflicts() {
        showMessage("Shortcuts Already in Use", "Choose another shortcut preset or disable the conflicting shortcuts in other apps:\n\n" + conflicts.joined(separator: "\n"))
    }
    @objc private func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
            else {
                try SMAppService.mainApp.register()
                if SMAppService.mainApp.status == .requiresApproval { SMAppService.openSystemSettingsLoginItems() }
            }
        } catch { showMessage("Launch at Login", error.localizedDescription) }
    }
    private func showMessage(_ title: String, _ message: String) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        let alert = NSAlert(); alert.messageText = title; alert.informativeText = message
        alert.addButton(withTitle: "OK"); alert.runModal()
        NSApplication.shared.hide(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
