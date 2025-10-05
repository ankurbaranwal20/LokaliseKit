// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LokaliseKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LokaliseKit",
            targets: ["LokaliseKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LokaliseKit",
            dependencies: [],
            path: "Sources/LokaliseKit"
        ),
        .testTarget(
            name: "LokaliseKitTests",
            dependencies: ["LokaliseKit"],
            path: "Tests/LokaliseKitTests"
        )
    ]
)
