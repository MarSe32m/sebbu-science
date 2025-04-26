// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sebbu-science",
    platforms: [.macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SebbuScience", targets: ["SebbuScience"]),
        .library(name: "BLAS", targets: ["BLAS"]),
        .library(name: "LAPACKE", targets: ["LAPACKE"])
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
        .target(name: "CFFTW"),
        .target(name: "COpenBLAS"),
        .target(name: "CLAPACK"),
        .target(name: "_SebbuScienceCommon"),
        .target(
            name: "BLAS",
            dependencies: [
                .target(name: "_SebbuScienceCommon"),
                .target(name: "COpenBLAS", condition: .when(platforms: [.linux, .windows])),
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            cSettings: [
                .define("ACCELERATE_NEW_LAPACK", .when(platforms: [.macOS])),
                .define("ACCELERATE_LAPACK_ILP64", .when(platforms: [.macOS]))
            ],
            linkerSettings: [
                .linkedFramework("Accelerate", .when(platforms: [.macOS]))
            ]
        ),
        .target(
            name: "LAPACKE",
            dependencies: [
                .target(name: "_SebbuScienceCommon"),
                .target(name: "CLAPACK", condition: .when(platforms: [.linux, .windows])),
            ],
            cSettings: [
                .define("ACCELERATE_NEW_LAPACK", .when(platforms: [.macOS])),
                .define("ACCELERATE_LAPACK_ILP64", .when(platforms: [.macOS]))
            ],
            linkerSettings: [
                .linkedFramework("Accelerate", .when(platforms: [.macOS]))
            ]
        ),
        .target(
            name: "SebbuScience",
            dependencies: [
                .target(name: "_SebbuScienceCommon"),
                .target(name: "BLAS"),
                .target(name: "LAPACKE"),
                .target(name: "COpenBLAS", condition: .when(platforms: [.linux, .windows])),
                .target(name: "CLAPACK", condition: .when(platforms: [.linux, .windows])),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "SebbuCollections", package: "sebbu-collections")
            ],
            cSettings: [
                .define("ACCELERATE_NEW_LAPACK", .when(platforms: [.macOS])),
                .define("ACCELERATE_LAPACK_ILP64", .when(platforms: [.macOS]))
            ],
            linkerSettings: [
                .linkedFramework("Accelerate", .when(platforms: [.macOS]))
            ]
        ),
        .testTarget(
            name: "SebbuScienceTests",
            dependencies: ["SebbuScience"]
        ),
    ]
)
