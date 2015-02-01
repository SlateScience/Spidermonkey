#!/bin/sh

if [ -z $NDK_ROOT ]; then
    echo "NDK_ROOT MUST BE DEFINED!"
    echo "e.g. export NDK_ROOT=$HOME/android-ndk"
    exit -1  
fi

host_kernel=$(uname -s | tr "[:upper:]" "[:lower:]")
host_arch=$(uname -m)
cpus=$(sysctl hw.ncpu | awk '{print $2}')

TARGET=arm-linux-androideabi
TARGET_ARCH=armv7-a
TARGET_ARCH_ABI=armeabi-v7a
GCC_VERSION=4.6

TOOLCHAIN=$NDK_ROOT/toolchains/${TARGET}-${GCC_VERSION}/prebuilt/${host_kernel}-${host_arch}

###

ls | grep -v build.sh | xargs rm -rf
rm -rf .deps

../configure --with-android-ndk=$NDK_ROOT \
    --with-android-toolchain=$TOOLCHAIN \
    --with-android-gnu-compiler-version=${GCC_VERSION} \
    --with-arch=${TARGET_ARCH} \
    --target=${TARGET} \
    --enable-android-libstdcxx \
    --disable-shared-js --disable-tests --enable-intl-api=no \
    --disable-threadsafe \
    --disable-root-analysis --disable-exact-rooting --enable-gcincremental \
    --disable-debug --disable-debug-symbols --enable-strip --enable-install-strip

make -j$cpus

###

if [ -z $RELEASE_DIR ]; then
    echo "RELEASE_DIR MUST BE DEFINED!"
    echo "e.g. export RELEASE_DIR=../../../blocks/Spidermonkey25"
    exit -1  
fi

rm -rf "$RELEASE_DIR/android/include"
mkdir -p "$RELEASE_DIR/android/include"
cp -RL dist/include/* "$RELEASE_DIR/android/include/"

rm -rf "$RELEASE_DIR/android/lib/$TARGET_ARCH_ABI"
mkdir -p "$RELEASE_DIR/android/lib/$TARGET_ARCH_ABI"
cp -L dist/lib/libjs_static.a "$RELEASE_DIR/android/lib/$TARGET_ARCH_ABI/"
