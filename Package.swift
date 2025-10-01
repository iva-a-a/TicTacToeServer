// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TicTacToe",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🐦 Swinject
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
        // Fluent
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        // JWT
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .target(name: "Web"),
                .target(name: "Domain"),
                .target(name: "Datasource"),
                .target(name: "Di"),
            ],
            path: "App/",
            swiftSettings: swiftSettings
        ),

        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            path: "Sources/Domain",
            swiftSettings: swiftSettings
        ),

        .target(
            name: "Datasource",
            dependencies: [
                .target(name: "Domain"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "Sources/Datasource",
            swiftSettings: swiftSettings
        ),
        
        .target(
            name: "Web",
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Datasource"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            path: "Sources/Web",
            swiftSettings: swiftSettings
        ),
        
        .target(
            name: "Di",
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Datasource"),
                .target(name: "Web"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Swinject", package: "Swinject"),
                .product(name: "JWTKit", package: "jwt-kit")
            ],
            path: "Sources/Di",
            swiftSettings: swiftSettings
        ),
        
        .testTarget(
            name: "Tests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
                .target(name: "Web")
            ],
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
