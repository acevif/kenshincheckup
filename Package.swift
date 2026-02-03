// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KenshinCheckup",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "KenshinCheckupCore"
        ),
        .executableTarget(
            name: "kenshin",
            dependencies: [
                "KenshinCheckupCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "KenshinCheckupCoreTests",
            dependencies: [
                "KenshinCheckupCore",
            ]
        ),
        .testTarget(
            name: "kenshinTests",
            dependencies: [
                "kenshin",
            ]
        ),
    ]
)
