# sebbu-science
Package for various scientific computation needs

This package vend OpenBLAS on Windows and Linux platforms. The package vendors a static OpenBLAS library for Linux x86_64 musl and gnu. On Windows, we (ab)use the static binary dependencies feature of Swift Package Manager to vend the OpenBLAS DLL. If you wish to distribute the binaries built with this package, you need to copy the ```openblas.dll``` from the COpenBLAS.artifactbundle with the executable of yours. OpenBLAS version is 0.3.31.
On macOS, the package uses ```Accelerate``` for the blas, lapack and fft operations so you don't need to install anything.

However, due to a [bug](https://github.com/swiftlang/swift/issues/80991) in the Swift compiler, when you use ```sebbu-science``` as a dependency on macOS, you must set the following flags for your target
```swift
cSettings: [
    .define("ACCELERATE_NEW_LAPACK", .when(platforms: [.macOS])),
    .define("ACCELERATE_LAPACK_ILP64", .when(platforms: [.macOS]))
],
linkerSettings: [
    .linkedFramework("Accelerate", .when(platforms: [.macOS]))
]
```