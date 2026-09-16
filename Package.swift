// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ControlBar",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "ControlBar", targets: ["ControlBar"])
    ],
    targets: [
        .target(name: "ControlBar"),
        .target(
            name: "ControlBarExamples",
            dependencies: ["ControlBar"],
            path: "Example"
        )
    ],
    swiftLanguageModes: [.v6]
)
