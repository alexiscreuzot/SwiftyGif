import PackageDescription

let package = Package(
name: "SwiftyGif",
exclude: [
    "SwiftyGifExample"
],
targets: [
    Target(
        name: "SwiftyGif"
    ),
    Target(
        name: "SwiftyGifTests",
        dependencies: [
            .Target(name: "SwiftyGif")
        ]
    )
]
