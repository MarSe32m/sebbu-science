// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sebbu-science",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SebbuScience", targets: ["SebbuScience"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", branch: "main"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),

        .package(url: "https://github.com/MarSe32m/sebbu-bitstream", branch: "main"),
        .package(url: "https://github.com/MarSe32m/sebbu-bitstream-macros", branch: "main"),
        .package(url: "https://github.com/MarSe32m/sebbu-collections", branch: "main"),
        .package(url: "https://github.com/MarSe32m/sebbu-concurrency", branch: "main"),
        .package(url: "https://github.com/MarSe32m/sebbu-ts-ds", branch: "main"),

        .package(url: "https://github.com/tayloraswift/swift-png", from: "4.4.0"),
        .package(url: "https://github.com/pvieito/PythonKit", branch: "master")
    ],
    targets: [
        .target(
            name: "COpenBLAS"
        ),
        .target(
            name: "CLAPACK", 
            cSettings: [.define("HAVE_LAPACK_CONFIG_H", to: "1")]
        ),
        .target(
            name: "SebbuScience",
            dependencies: [
                .target(name: "COpenBLAS", condition: .when(platforms: [.linux, .windows])),
                .target(name: "CLAPACK", condition: .when(platforms: [.linux, .windows])),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "SebbuCollections", package: "sebbu-collections")
            ]
        ),
        .testTarget(
            name: "SebbuScienceTests",
            dependencies: ["SebbuScience"]
        ),
    ]
)
