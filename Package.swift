// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iosapp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "iosapp", targets: ["iosapp"])
    ],
    targets: [
        .target(
            name: "iosapp",
            dependencies: [],
            path: "iosapp",
            resources: [
                .process("audio"),
                .process("Assets.xcassets")
            ]
        )
    ]
)
