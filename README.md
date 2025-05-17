# sebbu-science
Package for various scientific computation needs

This package depends on OpenBLAS, LAPACKE and FFTW3 on Windows and Linux platforms. The ```libopenblas.dll``` contained in the repo corresponds to version 0.3.29 of OpenBLAS for Windows x64. The package should work with any version of OpenBLAS as long as the headers match the given version. The ```libfftw3-3.dll``` contained in the repo corresponds to version 3.3.10 of FFTW. You can install OpenBLAS, LAPACKE and FFTW3 on Linux, for example on Ubuntu with the command
```shell
apt-get install libopenblas-dev liblapacke-dev libfftw3-dev
```
On macOS, the package uses ```Accelerate``` for the blas, lapack and fft operations so you don't need to install anything.
