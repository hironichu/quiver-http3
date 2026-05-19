// swift-tools-version: 6.2

import Foundation
import PackageDescription

let useLocalDeps = Context.environment["SWIFTCI_USE_LOCAL_DEPS"] != nil
let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let localQuiverPackagesRoot = Context.environment["QUIVER_PACKAGES_PATH"]

func quiverPackage(_ repository: String) -> Package.Dependency {
    if let localQuiverPackagesRoot {
        let localURL = URL(fileURLWithPath: localQuiverPackagesRoot, relativeTo: packageDirectory)
            .appendingPathComponent(repository)
            .standardizedFileURL
        let manifestURL = localURL.appendingPathComponent("Package.swift")

        if FileManager.default.fileExists(atPath: manifestURL.path) {
            return .package(path: localURL.path)
        }
    }

    return .package(url: "https://github.com/hironichu/\(repository).git", branch: "experimental/runtime")
}

func nioDependencies() -> [Package.Dependency] {
    if useLocalDeps {
        return [
            .package(path: "../../swift-nio"),
            .package(path: "../../swift-nio-ssl"),
        ]
    } else {
        return [
            .package(url: "https://github.com/apple/swift-nio.git", branch: "pr-3433"),
            .package(url: "https://github.com/apple/swift-nio-ssl.git", branch: "pr-567-windows-support"),
        ]
    }
}

let package = Package(
    name: "quiver-http3",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "QPACK", targets: ["QPACK"]),
        .library(name: "HTTP3", targets: ["HTTP3"]),
        .library(name: "HTTP3ServiceLifecycle", targets: ["HTTP3ServiceLifecycle"]),
    ],
    dependencies: nioDependencies() + [
        quiverPackage("quiver-quic"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.12.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "QPACK",
            dependencies: [],
            path: "Sources/QPACK"
        ),
        .target(
            name: "HTTP3",
            dependencies: [
                .product(name: "QUIC", package: "quiver-quic"),
                "QPACK",
                .product(name: "QUICCore", package: "quiver-quic"),
                .product(name: "QUICCrypto", package: "quiver-quic"),
                .product(name: "QUICStream", package: "quiver-quic"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/HTTP3"
        ),
        .target(
            name: "HTTP3ServiceLifecycle",
            dependencies: [
                "HTTP3",
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
            ],
            path: "Sources/HTTP3ServiceLifecycle"
        ),
        .testTarget(
            name: "QPACKTests",
            dependencies: ["QPACK"],
            path: "Tests/QPACKTests"
        ),
        .testTarget(
            name: "HTTP3Tests",
            dependencies: [
                "HTTP3",
                "HTTP3ServiceLifecycle",
                .product(name: "QUIC", package: "quiver-quic"),
                "QPACK",
                .product(name: "QUICCore", package: "quiver-quic"),
                .product(name: "QUICStream", package: "quiver-quic"),
                .product(name: "QuiverTestSupport", package: "quiver-quic"),
            ],
            path: "Tests/HTTP3Tests"
        ),
    ]
)
