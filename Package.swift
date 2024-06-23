// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Peavy",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Peavy",
            targets: ["Peavy"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mw99/DataCompression", .upToNextMajor(from: "3.8.0")),
    ],
    targets: [
        .target(
            name: "Peavy",
            dependencies: [
                .product(name: "DataCompression", package: "DataCompression")
            ]
        ),
        .testTarget(
            name: "PeavyTests",
            dependencies: ["Peavy"]
        ),
    ]
)
