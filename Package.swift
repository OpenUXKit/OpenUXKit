// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

/// Returns a URL of the sources
func pathInSources(componentToAppend: String) -> URL {
    URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Sources")
        .appendingPathComponent(componentToAppend)
}

let sourcesDirectory = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("Sources")

let package = Package(
    name: "OpenUXKit",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OpenUXKit",
            targets: ["OpenUXKit"]
        ),
        .library(
            name: "UXKit",
            targets: ["UXKit"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OpenUXKit"
        ),
        .target(
            name: "UXKit",
            linkerSettings: [
                .unsafeFlags([sourcesDirectory.appendingPathComponent("UXKit/UXKit.tbd").path])
            ]
        ),
        .testTarget(
            name: "OpenUXKitTests",
            dependencies: ["OpenUXKit"]
        ),
    ]
)
