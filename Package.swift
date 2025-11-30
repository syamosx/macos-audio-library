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
        // Phase 2: Add GRDB for SQLite support
        // .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AudioLibrary",
            dependencies: [],
            path: "Sources"
        )
    ]
)
