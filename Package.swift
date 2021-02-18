// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Matrix",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "Matrix", targets: ["Matrix"])
    ],
    dependencies: [],
    targets: [
        .target(name: "Matrix", dependencies: []),
    ]
)
