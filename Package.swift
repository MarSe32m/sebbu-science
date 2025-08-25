// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sebbu-science",
    platforms: [.macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "SebbuScience", targets: ["SebbuScience"]),
        .library(name: "CFFTW", targets: ["CFFTW"]),
        .library(name: "COpenBLAS", targets: ["COpenBLAS"]),
        .library(name: "FFT", targets: ["FFT"]),
        .library(name: "PythonKitUtilities", targets: ["PythonKitUtilities"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.1.0-prerelease"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/MarSe32m/sebbu-collections", branch: "main"),
        .package(url: "https://github.com/pvieito/PythonKit", branch: "master")
    ],
    targets: [
        .target(name: "DynamicCFFTW"),
        .target(name: "DynamicCOpenBLAS"),
        .target(name: "DynamicCLAPACK"),
        .target(name: "CMath"),
        .target(
            name: "_SebbuScienceCommon",
            linkerSettings: [
                .linkedLibrary("dl", .when(platforms: [.linux]))
            ]
        ),
        .binaryTarget(
            name: "CFFTW", 
            path: "CFFTW.artifactbundle"
        ),
        .binaryTarget(
            name: "COpenBLAS", 
            path: "COpenBLAS.artifactbundle"
        ),
        .target(
            name: "BLAS",
            dependencies: [
                .target(name: "_SebbuScienceCommon"),
                .target(name: "DynamicCOpenBLAS", condition: .when(platforms: [.linux, .windows])),
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
                .target(name: "DynamicCLAPACK", condition: .when(platforms: [.linux, .windows])),
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
            name: "FFT",
            dependencies: [
                .target(name: "_SebbuScienceCommon"),
                .target(name: "DynamicCFFTW", condition: .when(platforms: [.windows])),
                //FIXME: Use static CFFTW on Windows also once https://github.com/swiftlang/swift-package-manager/issues/8657 is fixed
                .target(name: "CFFTW", condition: .when(platforms: [.linux])),
                .product(name: "Numerics", package: "swift-numerics"),
                .target(name: "NumericsExtensions")
            ]),
        .target(
            name: "NumericsExtensions",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .target(name: "CMath")
            ]
        ),
        .target(
            name: "PythonKitUtilities",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "PythonKit", package: "PythonKit")
            ]
        ),
        .target(
            name: "SebbuScience",
            dependencies: [
                .target(name: "_SebbuScienceCommon"),
                .target(name: "BLAS"),
                .target(name: "LAPACKE"),
                .target(name: "FFT"),
                .target(name: "DynamicCOpenBLAS", condition: .when(platforms: [.linux, .windows])),
                .target(name: "DynamicCLAPACK", condition: .when(platforms: [.linux, .windows])),
                .target(name: "NumericsExtensions"),
                .product(name: "Algorithms", package: "swift-algorithms"),
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
        //FIXME: Remove this and use static COpenBLAS on Windows once https://github.com/swiftlang/swift-package-manager/issues/8657 is fixed
        .target(
            name: "_COpenBLASWindows", 
            linkerSettings: [
                .linkedLibrary("openblas", .when(platforms: [.windows])),
                .unsafeFlags(["-L\(Context.packageDirectory)/COpenBLAS.artifactbundle/lib/windows"], .when(platforms: [.windows]))
            ]
        ),
        //FIXME: Remove this and use static CFFTW on Windows once https://github.com/swiftlang/swift-package-manager/issues/8657 is fixed
        .target(
            name: "_CFFTWWindows",
            linkerSettings: [
                .linkedLibrary("fftw3", .when(platforms: [.windows])),
                .unsafeFlags(["-L\(Context.packageDirectory)/CFFTW.artifactbundle/lib/windows"], .when(platforms: [.windows]))
            ]
        ),
        .testTarget(
            name: "SebbuScienceTests",
            dependencies: ["SebbuScience"]
        ),
    ]
)
