# sebbu-science
Package for various scientific computation needs

The ```libopenblas.dll``` contained in the repo corresponds to version 0.3.29 of OpenBLAS for Windows x64. The package should work with any version of OpenBLAS as long as the headers match the given version. You can install OpenBLAS and LAPACKE on Linux, for example on Ubuntu with the command
```shell
apt-get install libopenblas-dev liblapacke-dev
```
On macOS, the package uses ```Accelerate``` for the blas and lapack operations.