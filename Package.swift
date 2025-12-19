// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DeveloperSupportStore",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "DeveloperSupportStore",
            targets: ["DeveloperSupportStore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/russell-archer/StoreHelper.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "DeveloperSupportStore",
            dependencies: ["StoreHelper"],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "DeveloperSupportStoreTests",
            dependencies: ["DeveloperSupportStore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
