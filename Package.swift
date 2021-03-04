// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TiltUp",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "TiltUp",
            targets: ["TiltUp"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TiltUp",
            dependencies: [])
    ]
)
