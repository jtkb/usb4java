#!/bin/sh
#
# Compile libusb4java for 64 bit windows with mingw on Windows
# or cross-compile it with mingw on Linux. 
#
# For cross-compiling on Linux mingw-w64-dev must be installed.

set -e
cd $(dirname $0)/..

OS=windows
ARCH=x86_64
TMPDIR=$(pwd)/tmp
DISTDIR=$(pwd)/../resources/de/ailis/usb4java/jni/${OS}-${ARCH}

# Clean up
rm -rf $TMPDIR
rm -rf $DISTDIR

# Download and unpack libusb-win32
LIBUSBWIN32_VERSION=1.2.2.0
mkdir -p $TMPDIR
wget -O $TMPDIR/libusb-win32.zip "http://downloads.sourceforge.net/project/libusb-win32/libusb-win32-releases/$LIBUSBWIN32_VERSION/libusb-win32-bin-$LIBUSBWIN32_VERSION.zip"
cd $TMPDIR
unzip libusb-win32.zip
INCLUDES=$TMPDIR/libusb-win32-bin-$LIBUSBWIN32_VERSION/include
LIBS=$TMPDIR/libusb-win32-bin-$LIBUSBWIN32_VERSION/lib/gcc
BINS=$TMPDIR/libusb-win32-bin-$LIBUSBWIN32_VERSION/bin/amd64
cd ..

# Create autoconf stuff if needed
if [ ! -e configure ]
then
    make -f Makefile.scm
fi

# Build libusb4java
CFLAGS=-m64 ./configure \
    --prefix=/ \
    --host=x86_64-w64-mingw32 \
    --with-libusb-includes=$INCLUDES \
    --with-libusb-libs=$LIBS,$BINS
make clean install-strip DESTDIR=$TMPDIR
mkdir -p $DISTDIR
cp -faL $TMPDIR/bin/libusb4java-0.dll $DISTDIR/libusb4java.dll
cp -faL $BINS/libusb0.dll $DISTDIR/libusb0.dll
chmod -x $DISTDIR/libusb4java.dll
rm -rf $TMPDIR
