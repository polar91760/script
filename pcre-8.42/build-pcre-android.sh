#!/bin/bash

#
# build PCRE for android
# author:billshen
#

# exit on error
set -e

ME=`basename $0`
DIR="$( cd "$( dirname "$0" )" && pwd )" 
BUILD_DIR="${DIR}/tmp/build-pcre-android/"
DEST_DIR="${DIR}/../prebuilt/android"
ANDROID_NDK="/Users/polar.wu/softing/android-ndk-r15c"

if [ ! -f pcre_version.c ]; then
	echo
	echo "Cannot find pcre_version.c"
	echo "Run script from within pcre directory:"
	echo "pcre-8.42$ ../../../${ME}"
	echo
	exit
fi


if [ -f Makefile ]; then
	make clean
fi

CC_COMMON_FLAGS="-I. -DANDROID -DTARGET_OS_ANDROID -fno-strict-aliasing -fno-omit-frame-pointer -fno-exceptions -fdata-sections -ffunction-sections"

# build for x86

CC_X86_FLAGS="${CC_COMMON_FLAGS} \
-funwind-tables \
-finline-limit=300"

X86_SYSROOT="${ANDROID_NDK}/platforms/android-21/arch-x86"
X86_TOOLCHAIN_ROOT="${ANDROID_NDK}/toolchains/x86-4.9/prebuilt/darwin-x86_64"
X86_TOOL_PREFIX="i686-linux-android"
X86_COMMON_FLAGS="\
-isystem ${ANDROID_NDK}/platforms/android-21/arch-x86/usr/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.9/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86/include \
"

./configure \
CPP="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-cpp" \
CXXCPP="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-cpp" \
CPPFLAGS="--sysroot=${X86_SYSROOT}" \
CXXCPPFLAGS="--sysroot=${X86_SYSROOT}" \
CC="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-gcc" \
CXX="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-g++" \
LD="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-ld" \
CXXFLAGS="-Os -s ${CC_X86_FLAGS} -fno-rtti --sysroot=${X86_SYSROOT} ${X86_COMMON_FLAGS}" \
CFLAGS="-Os -s ${CC_X86_FLAGS} --sysroot=${X86_SYSROOT} ${X86_COMMON_FLAGS}" \
LDFLAGS="--sysroot=${X86_SYSROOT}" \
AR="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-ar" \
AS="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-as" \
LIBTOOL="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-libtool" \
STRIP="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-strip" \
RANLIB="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-ranlib" \
--prefix=${DEST_DIR}/x86 \
--disable-dependency-tracking \
--target=arm-linux-androideabi \
--host=arm-linux-androideabi \
--enable-static \
--disable-shared \

set +e
make -j2
make install --ignore-errors
rm -rf ${DEST_DIR}/x86/bin
rm -rf ${DEST_DIR}/x86/share
rm -rf ${DEST_DIR}/x86/lib/pkgconfig
rm -rf ${DEST_DIR}/x86/lib/libpcre*.la
set -e


# build for arm

make clean

CC_ARMEABI_FLAGS="${CC_ARMEABI_FLAGS} \
-D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5__ \
-fsigned-char \
-march=armv5te \
-mtune=xscale \
-msoft-float \
-mfpu=vfp \
-mfloat-abi=softfp \
-fPIC \
-finline-limit=64"

ARM_SYSROOT="${ANDROID_NDK}/platforms/android-21/arch-arm"
ARMEABI_TOOLCHAIN_ROOT="${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64"
ARMEABI_TOOL_PREFIX="arm-linux-androideabi"
ARMEABI_COMMON_FLAGS="\
-isystem ${ANDROID_NDK}/platforms/android-21/arch-arm/usr/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.9/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi/include \
"

./configure \
CPP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-cpp" \
CXXCPP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-cpp" \
CPPFLAGS="--sysroot=${ARM_SYSROOT}" \
CXXCPPFLAGS="--sysroot=${ARM_SYSROOT}" \
CC="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-gcc" \
CXX="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-g++" \
LD="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ld" \
CXXFLAGS="-Os -s ${CC_ARMEABI_FLAGS} -fno-rtti --sysroot=${ARM_SYSROOT} ${ARMEABI_COMMON_FLAGS}" \
CFLAGS="-Os -s ${CC_ARMEABI_FLAGS} --sysroot=${ARM_SYSROOT} ${ARMEABI_COMMON_FLAGS}" \
LDFLAGS="--sysroot=${ARM_SYSROOT}" \
AR="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ar" \
AS="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-as" \
LIBTOOL="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-libtool" \
STRIP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-strip" \
RANLIB="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ranlib" \
--prefix=${DEST_DIR}/armeabi \
--disable-dependency-tracking \
--target=arm-linux-androideabi \
--host=arm-linux-androideabi \
--enable-static \
--disable-shared \

set +e
make -j2
make install --ignore-errors
rm -rf ${DEST_DIR}/armeabi/bin
rm -rf ${DEST_DIR}/armeabi/share
rm -rf ${DEST_DIR}/armeabi/lib/pkgconfig
rm -rf ${DEST_DIR}/armeabi/lib/libpcre*.la
set -e


# build for arm-v7a

make clean

CC_ARMEABI_FLAGS="${CC_ARMEABI_FLAGS} \
-D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5__ \
-fsigned-char \
-march=armv5te \
-mtune=xscale \
-msoft-float \
-mfpu=vfp \
-mfloat-abi=softfp \
-fPIC \
-finline-limit=64"

ARM_SYSROOT="${ANDROID_NDK}/platforms/android-21/arch-arm"
ARMEABI_TOOLCHAIN_ROOT="${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64"
ARMEABI_TOOL_PREFIX="arm-linux-androideabi"
ARMEABI_COMMON_FLAGS="\
-isystem ${ANDROID_NDK}/platforms/android-21/arch-arm/usr/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.9/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a/include \
"

./configure \
CPP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-cpp" \
CXXCPP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-cpp" \
CPPFLAGS="--sysroot=${ARM_SYSROOT}" \
CXXCPPFLAGS="--sysroot=${ARM_SYSROOT}" \
CC="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-gcc" \
CXX="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-g++" \
LD="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ld" \
CXXFLAGS="-Os -s ${CC_ARMEABI_FLAGS} -fno-rtti --sysroot=${ARM_SYSROOT} ${ARMEABI_COMMON_FLAGS}" \
CFLAGS="-Os -s ${CC_ARMEABI_FLAGS} --sysroot=${ARM_SYSROOT} ${ARMEABI_COMMON_FLAGS}" \
LDFLAGS="--sysroot=${ARM_SYSROOT}" \
AR="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ar" \
AS="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-as" \
LIBTOOL="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-libtool" \
STRIP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-strip" \
RANLIB="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ranlib" \
--prefix=${DEST_DIR}/armeabi-v7a \
--disable-dependency-tracking \
--target=arm-linux-androideabi \
--host=arm-linux-androideabi \
--enable-static \
--disable-shared \

set +e
make -j2
make install --ignore-errors
rm -rf ${DEST_DIR}/armeabi-v7a/bin
rm -rf ${DEST_DIR}/armeabi-v7a/share
rm -rf ${DEST_DIR}/armeabi-v7a/lib/pkgconfig
rm -rf ${DEST_DIR}/armeabi-v7a/lib/libpcre*.la
set -e


CC_MIPS_FLAGS="${CC_COMMON_FLAGS} \
-fsigned-char \
-fpic \
-finline-functions \
-funwind-tables \
-fmessage-length=0 \
-fno-inline-functions-called-once \
-fgcse-after-reload \
-frerun-cse-after-loop \
-frename-registers"


echo
echo "Installed static libraries in ${DEST_DIR}"
echo
