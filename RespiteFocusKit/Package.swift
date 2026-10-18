// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "RespiteFocusKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RespiteFocusKit", targets: ["RespiteFocusKit"]),
    ],
    targets: [
        .target(name: "RespiteFocusKit"),
    ]
)
