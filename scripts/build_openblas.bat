@echo off

rd /s /q build
mkdir build

call "c:\Program Files\Microsoft Visual Studio\2022\Community\vc\Auxiliary\Build\vcvars64.bat"
set "LIB=%CONDA_PREFIX%\Library\lib;%LIB%" 
set "CPATH=%CONDA_PREFIX%\Library\include;%CPATH%" 

cmake -B build -S OpenBLAS-0.3.30 -G "Ninja" ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_Fortran_COMPILER=flang ^
    -DCMAKE_MT=mt ^
    -DBUILD_WITHOUT_LAPACK=no ^
    -DNOFORTRAN=0 ^
    -DDYNAMIC_ARCH=ON ^
    -DCMAKE_BUILD_TYPE=Release

cmake --build build --config Release
cmake --install build --config Release --prefix .\openblas-static-install

rd /s /q build
mkdir build
cmake -B build -S OpenBLAS-0.3.30 -G "Ninja" ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_Fortran_COMPILER=flang ^
    -DCMAKE_MT=mt ^
    -DBUILD_WITHOUT_LAPACK=no ^
    -DNOFORTRAN=0 ^
    -DDYNAMIC_ARCH=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DCMAKE_BUILD_TYPE=Release

cmake --build build --config Release
cmake --install build --config Release --prefix .\openblas-shared-install

rd /s /q build