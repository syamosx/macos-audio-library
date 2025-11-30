// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AudioLibrary",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "AudioLibrary",
            targets: ["AudioLibrary"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0")
    ],
    targets: [
        .executableTarget(
            name: "AudioLibrary",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources"
        )
    ]
)
