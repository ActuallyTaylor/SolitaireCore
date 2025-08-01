// swift-tools-version: 6.1.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolitaireCore",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SolitaireCore",
            targets: ["SolitaireCore"]
        ),
        .library(
            name: "SolitaireCore.SwiftUI",
            targets: ["SolitaireCore.SwiftUI"]
        ),
        .library(
            name: "EmbeddedSolitaireCore",
            targets: ["EmbeddedSolitaireCore"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SolitaireCore"
        ),
        .target(
            name: "EmbeddedSolitaireCore",
            swiftSettings: [
                .enableExperimentalFeature("Embedded"),
                .unsafeFlags([
                    "-whole-module-optimization",
                    "-Xfrontend", "-disable-objc-interop",
                    "-Xfrontend", "-disable-stack-protector",
                    "-Xfrontend", "-function-sections",
                    "-Xfrontend", "-gline-tables-only",
                    "-Xcc", "-DTARGET_EXTENSION"
                ])
            ],
        ),
        .target(
            name: "SolitaireCore.SwiftUI",
            dependencies: ["SolitaireCore"]
        ),
        .testTarget(
            name: "SolitaireCoreTests",
            dependencies: ["SolitaireCore"]
        ),
    ]
)
