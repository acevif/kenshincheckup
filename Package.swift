// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KenshinCheckup",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(
            name: "kenshin",
            targets: ["KenshinCheckupCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
        .package(url: "https://github.com/dduan/TOMLDecoder", from: "0.4.3"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    ],
    targets: [
        .target(
            name: "KenshinCheckupCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "TOMLDecoder", package: "TOMLDecoder"),
                .product(name: "Tagged", package: "swift-tagged"),
            ]
        ),
        .executableTarget(
            name: "KenshinCheckupCLI",
            dependencies: [
                "KenshinCheckupCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
            ]
        ),
        .testTarget(
            name: "KenshinCheckupCoreTests",
            dependencies: [
                "KenshinCheckupCore",
            ],
            resources: [
                .copy("config.sample.toml"),
            ]
        ),
        .testTarget(
            name: "KenshinCheckupCLITests",
            dependencies: [
                "KenshinCheckupCLI",
            ]
        ),
    ]
)
