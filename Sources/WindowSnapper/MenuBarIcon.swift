import AppKit

enum MenuBarIcon {
    static func make() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            // Match the app icon: one snapped pane within open placement guides.
            let guides = NSBezierPath()
            for (x, y, dx, dy) in [
                (CGFloat(2.25), CGFloat(2.75), CGFloat(1), CGFloat(1)),
                (15.75, 2.75, -1, 1),
                (2.25, 15.25, 1, -1),
                (15.75, 15.25, -1, -1)
            ] {
                guides.move(to: CGPoint(x: x, y: y + dy * 3))
                guides.line(to: CGPoint(x: x, y: y))
                guides.line(to: CGPoint(x: x + dx * 3, y: y))
            }
            NSColor.black.setStroke()
            guides.lineWidth = 1.5
            guides.lineCapStyle = .round
            guides.lineJoinStyle = .round
            guides.stroke()

            NSColor.black.setFill()
            NSBezierPath(roundedRect: CGRect(x: 4.75, y: 5.25, width: 4.5, height: 7.5),
                         xRadius: 0.9, yRadius: 0.9).fill()
            return true
        }
        // macOS supplies the correct tint for light/dark mode and open menus.
        image.isTemplate = true
        image.accessibilityDescription = "Window Snapper"
        return image
    }
}
