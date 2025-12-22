// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeveloperSupportStoreExampleFeature",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "DeveloperSupportStoreExampleFeature",
            targets: ["DeveloperSupportStoreExampleFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../.."),
    ],
    targets: [
        .target(
            name: "DeveloperSupportStoreExampleFeature",
            dependencies: [
                .product(name: "DeveloperSupportStore", package: "phoenix-v1"),
            ]
        ),
        .testTarget(
            name: "DeveloperSupportStoreExampleFeatureTests",
            dependencies: [
                "DeveloperSupportStoreExampleFeature",
            ]
        ),
    ]
)
