// swift-tools-version: 6.1.0

import PackageDescription

let package = Package(
  name: "LoggingClient",
  platforms: [
    .macOS(.v13),
    .iOS(.v17),
    .watchOS(.v10),
    .tvOS(.v17),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "LoggingClient",
      targets: ["LoggingClient"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.23.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.10.0"),
    .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
    .package(url: "https://github.com/indigo-stacks/swift-file-logger", from: "0.9.2"),
    .package(url: "https://github.com/kean/PulseLogHandler", from: "5.1.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "LoggingClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "FileLogger", package: "swift-file-logger"),
        .product(name: "PulseLogHandler", package: "PulseLogHandler"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "LoggingClientTests",
      dependencies: ["LoggingClient"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
