// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwiftyGif",
    platforms: [
        .iOS("8.0"),
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
