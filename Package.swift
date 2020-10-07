// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftyGif",
    platforms: [
        .iOS("9.0"), .macOS(.v10_14),
    ],
    products: [
        .library(
            name: "SwiftyGif",
            targets: ["SwiftyGif"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftyGif",
            dependencies: [],
            path: "SwiftyGif"),
    ]
)
