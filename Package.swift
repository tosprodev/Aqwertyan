// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Aqwertyan",
    platforms: [.iOS(.v15), .macOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Aqwertyan",
            targets: ["Aqwertyan"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Aqwertyan",
            dependencies: [],
            resources: [.process("Resources")]
        ),
    ]
)
