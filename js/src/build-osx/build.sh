#!/bin/sh

cpus=$(sysctl hw.ncpu | awk '{print $2}')

# cleanup
ls | grep -v build.sh | xargs rm -rf
rm -rf .deps

# configure
../configure --disable-shared-js --disable-tests --enable-intl-api=no --enable-llvm-hacks \
    --disable-threadsafe \
    --disable-root-analysis --disable-exact-rooting --enable-gcincremental \
    --enable-debug --enable-debug-symbols

# make
xcrun make -j$cpus

# strip
# xcrun strip -S libjs_static.a

# info
xcrun lipo -info libjs_static.a
