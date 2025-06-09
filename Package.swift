// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TicTacToe",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🐦 Swinject — для Dependency Injection
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Swinject", package: "Swinject"),
                .target(name: "web"),
                .target(name: "domain"),
                .target(name: "datasource"),
                .target(name: "di"),
            ],
            path: "App/",
            swiftSettings: swiftSettings
        ),

        .target(
            name: "domain",
            dependencies: [
            ],
            path: "Sources/domain",
            sources: ["model", "service"],
            swiftSettings: swiftSettings
        ),

        .target(
            name: "datasource",
            dependencies: [
                .target(name: "domain"),
            ],
            path: "Sources/datasource",
            sources: ["model", "repository", "mapper"],
            swiftSettings: swiftSettings
        ),

        .target(
            name: "web",
            dependencies: [
                .target(name: "domain"),
                .target(name: "datasource"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/web",
            sources: ["model", "controller", "mapper"],
            swiftSettings: swiftSettings
        ),

        .target(
            name: "di",
            dependencies: [
                .target(name: "domain"),
                .target(name: "datasource"),
                .target(name: "web"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Swinject", package: "Swinject"),
            ],
            path: "Sources/di",
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
