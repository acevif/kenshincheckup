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
        .package(url: "https://github.com/dduan/TOMLDecoder", from: "0.4.3"),
    ],
    targets: [
        .target(
            name: "KenshinCheckupCore",
            dependencies: [
                .product(name: "TOMLDecoder", package: "TOMLDecoder"),
            ]
        ),
        .executableTarget(
            name: "KenshinCheckupCLI",
            dependencies: [
                "KenshinCheckupCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
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
