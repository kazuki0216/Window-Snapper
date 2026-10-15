// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WindowSnapper",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "WindowSnapper", targets: ["WindowSnapper"])],
    targets: [.executableTarget(name: "WindowSnapper")],
    swiftLanguageModes: [.v5]
)
