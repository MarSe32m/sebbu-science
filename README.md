# sebbu-science
Package for various scientific computation needs

This package depends on OpenBLAS on Windows and Linux platforms. The package vendors a static OpenBLAS library for linux x86_64 musl and gnu. Static OpenBLAS for Windows is a work in progress. For now you need to put the ```libopenblas.dll``` next to the executable for it to work. The ```libopenblas.dll``` contained in the repo corresponds to version 0.3.30 of OpenBLAS for Windows x64. The package should work with any version of OpenBLAS as long as the headers match the given version.
On macOS, the package uses ```Accelerate``` for the blas, lapack and fft operations so you don't need to install anything.
