import AppKit

// Render at each native size so the source stays editable and reproducible.
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let iconset = root.appendingPathComponent(".build/AppIcon.iconset")
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

func color(_ hex: UInt32, alpha: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
            green: CGFloat((hex >> 8) & 255) / 255,
            blue: CGFloat(hex & 255) / 255, alpha: alpha)
}

func rounded(_ rect: CGRect, _ radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func render(size: Int, to url: URL) throws {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
                                 bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                 isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    let transform = NSAffineTransform()
    transform.scale(by: CGFloat(size) / 1024)
    transform.concat()

    // A quiet charcoal tile and a single coral pane snapping into corner guides.
    let tile = rounded(CGRect(x: 80, y: 80, width: 864, height: 864), 192)
    NSGraphicsContext.saveGraphicsState()
    let shadow = NSShadow()
    shadow.shadowColor = color(0x000000, alpha: 0.18)
    shadow.shadowBlurRadius = 18
    shadow.shadowOffset = NSSize(width: 0, height: -10)
    shadow.set()
    color(0x202124).setFill()
    tile.fill()
    NSGraphicsContext.restoreGraphicsState()
    NSGradient(colors: [color(0x2C2D31), color(0x202124)])!
        .draw(in: tile, angle: -90)
    color(0xFFFFFF, alpha: 0.08).setStroke()
    tile.lineWidth = 2
    tile.stroke()

    // Open corners communicate placement without miniature window chrome.
    let guides = NSBezierPath()
    let low: CGFloat = 256
    let high: CGFloat = 768
    let arm: CGFloat = 100
    for (x, y, dx, dy) in [
        (low, low, CGFloat(1), CGFloat(1)),
        (high, low, CGFloat(-1), CGFloat(1)),
        (low, high, CGFloat(1), CGFloat(-1)),
        (high, high, CGFloat(-1), CGFloat(-1))
    ] {
        guides.move(to: CGPoint(x: x, y: y + dy * arm))
        guides.line(to: CGPoint(x: x, y: y))
        guides.line(to: CGPoint(x: x + dx * arm, y: y))
    }
    guides.lineWidth = 24
    guides.lineCapStyle = .round
    guides.lineJoinStyle = .round
    color(0xF4F1EB).setStroke()
    guides.stroke()

    let pane = rounded(CGRect(x: 300, y: 300, width: 222, height: 424), 28)
    color(0xFF715B).setFill()
    pane.fill()
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: url)
}

for points in [16, 32, 128, 256, 512] {
    try render(size: points, to: iconset.appendingPathComponent("icon_\(points)x\(points).png"))
    try render(size: points * 2, to: iconset.appendingPathComponent("icon_\(points)x\(points)@2x.png"))
}
try render(size: 1024, to: root.appendingPathComponent("Resources/AppIcon.png"))

// Store PNG representations directly in the standard ICNS container.
// This avoids relying on iconutil's image conversion service at build time.
func bigEndian(_ value: Int) -> Data {
    var number = UInt32(value).bigEndian
    return withUnsafeBytes(of: &number) { Data($0) }
}
let entries = [
    ("icp4", "icon_16x16.png"), ("ic11", "icon_16x16@2x.png"),
    ("icp5", "icon_32x32.png"), ("ic12", "icon_32x32@2x.png"),
    ("ic07", "icon_128x128.png"), ("ic13", "icon_128x128@2x.png"),
    ("ic08", "icon_256x256.png"), ("ic14", "icon_256x256@2x.png"),
    ("ic09", "icon_512x512.png"), ("ic10", "icon_512x512@2x.png")
]
var body = Data()
for (type, filename) in entries {
    let png = try Data(contentsOf: iconset.appendingPathComponent(filename))
    body.append(Data(type.utf8))
    body.append(bigEndian(png.count + 8))
    body.append(png)
}
var icns = Data("icns".utf8)
icns.append(bigEndian(body.count + 8))
icns.append(body)
try icns.write(to: root.appendingPathComponent("Resources/AppIcon.icns"))
