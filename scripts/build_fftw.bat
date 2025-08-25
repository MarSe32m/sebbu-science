@echo off

set FFTW_DIR=fftw-3.3.10
set FFTW_URL=https://www.fftw.org/%FFTW_DIR%.tar.gz
set FFTW_TARBALL=%FFTW_DIR%.tar.gz

echo "Downloading %FFTW_URL%..."
curl -L -o %FFTW_TARBALL% %FFTW_URL%

if exist %FFTW_TARBALL% (
  echo "Downloaded to %FFTW_TARBALL%"
) else (
  echo "Download failed"
)

powershell -Command "tar -xzf %FFTW_TARBALL%"
del %FFTW_TARBALL%

mkdir build
rd /s /q build

:: Build static library
cmake -B build -S fftw-3.3.10 -G "Visual Studio 17 2022" ^
  -DBUILD_SHARED_LIBS=OFF ^
  -DENABLE_THREADS=ON ^
  -DWITH_COMBINED_THREADS=ON ^
  -DENABLE_SSE2=ON ^
  -DENABLE_AVX=ON ^
  -DENABLE_AVX2=ON ^
  -DENABLE_AVX512=ON

cmake --build build --config Release
cmake --install build --config Release --prefix .\fftw-static-install

rd /s /q build
mkdir build

:: Build shared library
cmake -B build -S fftw-3.3.10 -G "Visual Studio 17 2022" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DENABLE_THREADS=ON ^
  -DWITH_COMBINED_THREADS=ON ^
  -DENABLE_SSE2=ON ^
  -DENABLE_AVX=ON ^
  -DENABLE_AVX2=ON ^
  -DENABLE_AVX512=ON

cmake --build build --config Release
cmake --install build --config Release --prefix .\fftw-shared-install

rd /s /q build
rd /s /q %FFTW_DIR%

echo "FFTW build done!"
