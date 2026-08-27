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

## Credits

`UniqueVerner76Solver` uses the Runge--Kutta 7(6) pair and sixth-order
interpolant coefficients developed and copyrighted by James H. Verner. They
are used here with the acknowledgment required by their source. The corrected
coefficient set `RKV76.IIa.Efficient.000003389335684.240711` is published as
*An even more “efficient” Runge--Kutta (7)6 Pair with Interpolants* at [Jim
Verner's Refuge for Runge-Kutta Pairs](https://www.sfu.ca/~jverner/). See also
J. H. Verner, *Numerically optimal Runge--Kutta pairs with interpolants*,
Numerical Algorithms 53 (2010), 383--396,
[doi:10.1007/s11075-009-9290-3](https://doi.org/10.1007/s11075-009-9290-3).
