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

wget -nc $MUSL_CROSS_TOOLS_X86_64_URL
wget -nc $MUSL_CROSS_TOOLS_AARCH64_URL

tar xf $MUSL_CROSS_TOOLS_X86_64_TARBALL -C $TOOLS_DIR
tar xf $MUSL_CROSS_TOOLS_AARCH64_TARBALL -C $TOOLS_DIR

export PATH=$TOOLS_DIR/x86_64-linux-musl-cross/bin:$TOOLS_DIR/aarch64-linux-musl-cross/bin:$PATH
#export LD_LIBRARY_PATH=$TOOLS_DIR/x86_64-linux-musl-cross/x86_64-linux-musl/LIBRARY_PATH
#export LIBRARY_PATH=$TOOLS_DIR/x86_64-linux-musl-cross/x86_64-linux-musl/lib
#export LD_LIBRARY_PATH=$TOOLS_DIR/aarch64-linux-musl-cross/x86_64-linux-musl/lib

echo "X86 MUSL GCC VERSION"
x86_64-linux-musl-gcc --version

echo "AARCH64 MUSL GCC VERSION"
aarch64-linux-musl-gcc --version

# Clone OpenBLAS
OPENBLAS_VERSION="0.3.30"
OPENBLAS_REPO="https://github.com/OpenMathLib/OpenBLAS.git"
OPENBLAS_TAG="v$OPENBLAS_VERSION"

PREFIX="$(pwd)/openblas-build"
mkdir -p "$PREFIX/x86_64/musl" "$PREFIX/x86_64/gnu" 
mkdir -p "$PREFIX/aarch64/musl" "$PREFIX/aarch64/gnu"

JOBS=$(nproc)

build_openblas() {
    local target_cc=$1
    local target_fc=$2
    local install_prefix=$3
    
    git clone --depth=1 --branch $OPENBLAS_TAG $OPENBLAS_REPO OpenBLAS
    pushd OpenBLAS
    #make clean

   ##         FC=$target_fc \
    make CC=$target_cc \
         NO_SHARED=1 \
         USE_OPENMP=0 \
         NO_AFFINITY=1 \
         DYNAMIC_ARCH=1 \
         NUM_THREADS=16 \
         NO_TEST=1 \
         CFLAGS="-O2 -fno-lto -static" \
         FFLAGS="-O2 -fno-lto -static" \
         LDFLAGS="-fno-lto -static" \
         -j$JOBS

    # FC=$target_fc \
    make PREFIX="$install_prefix" \
         CC=$target_cc \
         NO_SHARED=1 \
         USE_OPENMP=0 \
         NO_AFFINITY=1 \
         DYNAMIC_ARCH=1 \
         NUM_THREADS=16 \
         NO_TEST=1 \
         CFLAGS="-O2 -fno-lto -static" \
         FFLAGS="-O2 -fno-lto -static" \
         LDFLAGS="-fno-lto -static" \
         INSTALL_STATIC=1 \
         INSTALL_SHARED=0 \
         install
    popd
    rm -rf OpenBLAS
}



echo "=== Building OpenBLAS for x86_64 (musl) ==="
build_openblas x86_64-linux-musl-gcc x86_64-linux-musl-gfortran "$PREFIX/x86_64/musl"

echo "=== Building OpenBLAS for x86_64 (gnu) ==="
build_openblas x86_64-linux-gnu-gcc x86_64-linux-gnu-gfortran "$PREFIX/x86_64/gnu"

#echo "=== Building OpenBLAS for aarch64 (musl) ==="
#build_openblas aarch64-linux-musl-gcc aarch64-linux-musl-gfortran "$PREFIX/aarch64/musl"

#echo "=== Building OpenBLAS for aarch64 (gnu) ==="
#build_openblas aarch64-linux-gnu-gcc aarch64-linux-gnu-gfortran "$PREFIX/aarch64/gnu"

cd ..


#cp "$PREFIX/aarch64/musl/lib/libopenblasp-r$OPENBLAS_VERSION.a" "libopenblasp-r$OPENBLAS_VERSION-aarch64-musl.a"
#cp "$PREFIX/aarch64/gnu/lib/libopenblasp-r$OPENBLAS_VERSION.a" "libopenblasp-r$OPENBLAS_VERSION-aarch64-gnu.a"

# Copy artifacts
cp "$PREFIX/x86_64/musl/lib/libopenblasp-r$OPENBLAS_VERSION.a" "libopenblasp-r$OPENBLAS_VERSION-x86_64-musl.a"
# Copy artifacts
cp "$PREFIX/x86_64/gnu/lib/libopenblasp-r$OPENBLAS_VERSION.a" "libopenblasp-r$OPENBLAS_VERSION-x86_64-gnu.a"
cp -r "$PREFIX/x86_64/musl/include" include

rm -fr .build
echo "Build complete!"
