#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$(pwd)/.build"
cd "$(pwd)/.build"

# Download and install musl cross compilers
MUSL_CROSS_TOOLS_X86_64_TARBALL="x86_64-linux-musl-cross.tgz"
MUSL_CROSS_TOOLS_AARCH64_TARBALL="aarch64-linux-musl-cross.tgz"
MUSL_CROSS_TOOLS_X86_64_URL="https://musl.cc/$MUSL_CROSS_TOOLS_X86_64_TARBALL"
MUSL_CROSS_TOOLS_AARCH64_URL="https://musl.cc/$MUSL_CROSS_TOOLS_AARCH64_TARBALL"

TOOLS_DIR="$(pwd)/cross-tools"
mkdir -p $TOOLS_DIR

wget $MUSL_CROSS_TOOLS_X86_64_URL
wget $MUSL_CROSS_TOOLS_AARCH64_URL

tar xf $MUSL_CROSS_TOOLS_X86_64_TARBALL -C $TOOLS_DIR
tar xf $MUSL_CROSS_TOOLS_AARCH64_TARBALL -C $TOOLS_DIR

export PATH=$TOOLS_DIR/x86_64-linux-musl-cross/bin:$TOOLS_DIR/aarch64-linux-musl-cross/bin:$PATH

echo "X86 MUSL GCC VERSION"
x86_64-linux-musl-gcc --version

echo "AARCH64 MUSL GCC VERSION"
aarch64-linux-musl-gcc --version

echo "X86 GNU GCC VERSION"
x86_64-linux-gnu-gcc --version

echo "AARCH64 GNU GCC VERSION"
aarch64-linux-gnu-gcc --version

# Download FFTW source and build
PREFIX="$(pwd)/fftw-build"
mkdir -p "$PREFIX/x86_64/musl" "$PREFIX/x86_64/gnu" 
mkdir -p "$PREFIX/aarch64/musl" "$PREFIX/aarch64/gnu"

JOBS=$(nproc)

FFTW_REPO="http://www.fftw.org/fftw-3.3.10.tar.gz"
FFTW_TARBALL="fftw-3.3.10.tar.gz"
FFTW_DIR="fftw-3.3.10"

if [ ! -f "$FFTW_TARBALL" ]; then
    wget "$FFTW_REPO"
fi

if [ ! -d "$FFTW_DIR" ]; then
    tar xf "$FFTW_TARBALL"
fi

# x86_64 build
echo "=== Building FFTW for x86_64 (musl) ==="
pushd "$FFTW_DIR"
make distclean || true

./configure CC=x86_64-linux-musl-gcc \
    CFLAGS="-O3 -fPIC" \
    --prefix="$PREFIX/x86_64/musl" \
    --disable-shared --enable-static \
    --enable-threads \
    --enable-sse2 --enable-avx --enable-avx2 --enable-avx512

make -j$JOBS
make install
popd

echo "=== Building FFTW for x86_64 (gnu) ==="
pushd "$FFTW_DIR"
make distclean || true

./configure CC=x86_64-linux-gnu-gcc \
    CFLAGS="-O3 -fPIC" \
    --prefix="$PREFIX/x86_64/gnu" \
    --disable-shared --enable-static \
    --enable-threads \
    --enable-sse2 --enable-avx --enable-avx2 --enable-avx512

make -j$JOBS
make install
popd

# aarch64 build
#echo "=== Building FFTW for aarch64 (musl) ==="
#pushd "$FFTW_DIR"
#make distclean || true
#
#./configure CC=aarch64-linux-musl-gcc \
#    --prefix="$PREFIX/aarch64/musl" \
#    --disable-shared --enable-static \
#    --enable-threads \
#    --enable-neon
#
#make -j$JOBS
#make install
#popd
#
#echo "=== Building FFTW for aarch64 (gnu) ==="
#pushd "$FFTW_DIR"
#make distclean || true
#
#./configure CC=aarch64-linux-gnu-gcc \
#    --prefix="$PREFIX/aarch64/gnu" \
#    --disable-shared --enable-static \
#    --enable-threads \
#    --enable-neon
#
#make -j$JOBS
#make install
#popd

cd ..

cp "$PREFIX/x86_64/musl/lib/libfftw3.a" "libfftw3-x86_64-musl.a"
cp "$PREFIX/x86_64/musl/include/fftw3.h" "fftw3.h"
cp "$PREFIX/x86_64/gnu/lib/libfftw3.a" "libfftw3-x86_64-gnu.a"

#cp "$PREFIX/aarch64/musl/lib/libfftw3.a" "$BASEDIR/libfftw3-aarch64-musl.a"
#cp "$PREFIX/aarch64/gnu/lib/libfftw3.a" "$BASEDIR/libfftw3-aarch64-gnu.a"

echo "Build complete!"
rm -fr .build