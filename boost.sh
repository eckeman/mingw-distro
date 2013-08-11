#!/bin/sh

source 0_append_distro_path.sh

7z x '-oC:\Temp\gcc' boost_1_54_0.tar > NUL || fail_with boost_1_54_0.tar - EPIC FAIL

patch -d /c/temp/gcc/boost_1_54_0 -p1 < boost-84470.patch     # https://svn.boost.org/trac/boost/changeset/84470
patch -d /c/temp/gcc/boost_1_54_0 -p1 < boost-bootstrap.patch
patch -d /c/temp/gcc/boost_1_54_0 -p1 < boost-mingw-w64.patch
patch -d /c/temp/gcc/boost_1_54_0 -p1 < boost-official.patch  # http://www.boost.org/users/history/version_1_54_0.html

cd /c/temp/gcc
mv boost_1_54_0 src
mkdir -p dest/include
cd src
bootstrap.sh || fail_with boost - EPIC FAIL

# pch=off : http://lists.boost.org/Archives/boost/2013/07/205244.php
# --without-context : https://svn.boost.org/trac/boost/ticket/7262
# --without-coroutine : Boost.Coroutine depends on Boost.Context.
b2 -j$NUMBER_OF_PROCESSORS pch=off --without-context --without-coroutine variant=release link=static runtime-link=static threading=multi --stagedir=/c/temp/gcc/dest stage -sNO_BZIP2 -sBZIP2_BINARY=bz2 -sBZIP2_INCLUDE=$X_DISTRO_INC -sBZIP2_LIBPATH=$X_DISTRO_LIB -sNO_ZLIB -sZLIB_BINARY=z -sZLIB_INCLUDE=$X_DISTRO_INC -sZLIB_LIBPATH=$X_DISTRO_LIB || fail_with boost - EPIC FAIL

cd /c/temp/gcc/dest/lib
for i in *.a; do mv $i ${i%-mgw*.a}.a; done
cd /c/temp/gcc
mv src/boost dest/include
mv dest boost-1.54.0

echo Packaging...

cd boost-1.54.0
7z -mx0 a ../boost-1.54.0.7z * > NUL || fail_with boost-1.54.0.7z - EPIC FAIL

echo Cleaning...

cd /c/temp/gcc
rm -rf src

echo Done.
