#!/bin/sh -x

## this script is supposed to be run one directory below the original configure script
## usually in build-ios

MIN_IOS_VERSION=4.3
IOS_SDK=7.0
RELEASE_DIR="spidermonkey-ios"

LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

cpus=$(sysctl hw.ncpu | awk '{print $2}')

build_with_arch()
{
rm -rf dist
rm -f ./config.cache

../configure --with-ios-target=${IOS_TARGET} --with-ios-version=$IOS_SDK --with-ios-min-version=$MIN_IOS_VERSION ${ARCH_OPTION} \
            --disable-shared-js --disable-tests --disable-ion --disable-jm --disable-tm --enable-llvm-hacks \
            --disable-methodjit --disable-monoic --disable-polyic ${YARR_JIT_OPTION} \
            --enable-optimize=-O3 --enable-strip --enable-install-strip \
            ${DEBUG_OPTION}
make -j$cpus
if (( $? )) ; then
    echo "error when compiling iOS ${CPU_ARCH} ${IOS_TARGET} version of the library"
    return
fi

# remove debugging info
$STRIP -S libjs_static.a

RELEASE_ARCH_DIR=${CPU_ARCH}

rm -r "$RELEASE_DIR/$RELEASE_ARCH_DIR"
mkdir -p "$RELEASE_DIR/$RELEASE_ARCH_DIR/lib"
cp -RL dist/include "$RELEASE_DIR/$RELEASE_ARCH_DIR"
cp -L dist/lib/libjs_static.a "$RELEASE_DIR/$RELEASE_ARCH_DIR/lib/libjs_static.a"

}

# create ios version (armv7)
IOS_TARGET=iPhoneOS
CPU_ARCH=armv7
ARCH_OPTION="--with-ios-arch=${CPU_ARCH}"
#YARR_JIT_OPTION="--disable-yarr-jit"
THUMB_OPTION="--with-thumb=yes"
build_with_arch


#
# create ios version (armv7s)
IOS_TARGET=iPhoneOS
CPU_ARCH=armv7s
ARCH_OPTION="--with-ios-arch=${CPU_ARCH}"
#YARR_JIT_OPTION="--disable-yarr-jit"
THUMB_OPTION="--with-thumb=yes"
build_with_arch

# remove everything but the static libraries and this script
ls | grep -v build.sh | grep -v $RELEASE_DIR | xargs rm -rf

# create i386 version (simulator)
IOS_TARGET=iPhoneSimulator
CPU_ARCH=i386
DEBUG_OPTION="--enable-debug"
build_with_arch

#copy to release dir
rm -rf dist
mkdir dist
mv $RELEASE_DIR dist/release
