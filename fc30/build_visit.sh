#!/bin/bash

set -e

# Get some packages with the package manager
dnf -y upgrade
dnf -y install `cat packlist.txt`

# Environment variables for build
jobs=`grep -c processor /proc/cpuinfo`
base_dir=/root/visit-3.0.1-fc30              # Top-level directory
build_dir=${base_dir}/build                  # Build directory
third_party_dir=${base_dir}/third_party      # Install third-party libraries here
install_prefix=${base_dir}/visit-3.0.1-fc30  # Install VisIt here

# Download and patch VisIt install script
mkdir -p ${base_dir} ${build_dir} ${third_party_dir}
wget -nc http://portal.nersc.gov/project/visit/releases/3.0.1/build_visit3_0_1
chmod 755 build_visit3_0_1
cp -p build_visit3_0_1 build_visit3_0_1.orig
patch -p0 < build_visit3_0_1.patch

# Use newer version of zlib (needed for compatibility with system libpng)
# Use newer version of QT (default version has issues with GCC 9)
cd ${build_dir}
export ZLIB_VERSION=1.2.9
export QT_VERSION=5.12.4
wget -nv https://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz
wget -nv https://download.qt.io/archive/qt/5.12/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz
cd ${base_dir}

# Build options
build_string=
build_string+=" --skip-opengl-context-check"            # Allow building without a display (i.e. over ssh or in a docker image)
build_string+=" --build-mode Release"                   # VisIt build mode (Debug or Release)
build_string+=" --create-rpm"                           # Create RPM packages
build_string+=" --makeflags -j${jobs}"                  # Flags to pass to 'make'
build_string+=" --fortran"                              # Enable compilation of Fortran sources
build_string+=" --no-qt-silent"                         # Disable make silent operation for QT
build_string+=" --parallel"                             # Enable parallel build, display MPI prompt
build_string+=" --installation-build-dir ${build_dir}"  # Location to use as the build directory
build_string+=" --thirdparty-path ${third_party_dir}"   # Location third-party libraries will be installed
build_string+=" --optional"                             # Build all optional libraries
build_string+=" --prefix ${install_prefix}"             # Location VisIt will be installed
build_string+=" --tarball visit3.0.1.tar.gz"            # Tarball to extract VisIt from
build_string+=" --mpich"                                # Build MPICH support
#build_string+=" --openssl"                              # Build openssl support (suppsedly optional, but actually required)
build_string+=" --stdout"                               # Write build log to stdout

# Download everything
./build_visit3_0_1 ${build_string} --download-only 2>&1 | tee -a download.log

# Build dependencies
./build_visit3_0_1 ${build_string} --no-visit 2>&1 | tee -a build_deps.log

# Build VisIt
./build_visit3_0_1 ${build_string} 2>&1 | tee -a build_visit.log
