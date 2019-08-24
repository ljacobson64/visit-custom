FROM fedora:30

# Get some packages with the package manager
COPY packlist.txt /root/
RUN dnf -y upgrade
RUN dnf -y install `cat /root/packlist.txt`

# Environment variables for build
ENV base_dir=/root/visit-3.0.1-fc30
ENV build_dir=${base_dir}/build
ENV third_party_dir=${base_dir}/third_party
ENV install_prefix=${base_dir}/visit-3.0.1-fc30

# Download and patch VisIt install script
COPY build_visit3_0_1.patch ${base_dir}/
RUN mkdir -p ${base_dir} ${build_dir} ${third_party_dir}
RUN cd ${base_dir} && wget -nv http://portal.nersc.gov/project/visit/releases/3.0.1/build_visit3_0_1
RUN chmod 755 ${base_dir}/build_visit3_0_1
RUN cd ${base_dir} && cp -p build_visit3_0_1 build_visit3_0_1.orig
RUN cd ${base_dir} && patch -p0 < build_visit3_0_1.patch

# Use newer version of zlib (needed for compatibility with system libpng)
ENV ZLIB_VERSION=1.2.9
RUN cd ${build_dir} && wget -nv https://sourceforge.net/projects/libpng/files/zlib/${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz

# Use newer version of QT (default version has issues with GCC 9)
ENV QT_VERSION=5.12.4
RUN cd ${build_dir} && wget -nv https://download.qt.io/archive/qt/5.12/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz

# Build options
ENV build_options="--skip-opengl-context-check \
                   --build-mode Release \
                   --create-rpm \
                   --makeflags -j$(grep -c processor /proc/cpuinfo) \
                   --fortran \
                   --no-qt-silent \
                   --parallel \
                   --installation-build-dir ${build_dir} \
                   --thirdparty-path ${third_party_dir} \
                   --optional \
                   --prefix ${install_prefix} \
                   --tarball visit3.0.1.tar.gz \
                   --mpich \
                   --stdout"

# Download everything
RUN ${base_dir}/build_visit3_0_1 $(eval echo ${build_options}) --download-only 2>&1 | tee -a ${base_dir}/download.log

# Build dependencies
RUN ${base_dir}/build_visit3_0_1 $(eval echo ${build_options}) --no-visit 2>&1 | tee -a ${base_dir}/build_deps.log

# Build VisIt
RUN ${base_dir}/build_visit3_0_1 $(eval echo ${build_options}) 2>&1 | tee -a ${base_dir}/build_visit.log

# Generate tarball
RUN cd ${build_dir}/visit3.0.1/build && \
    sed -i "s/CPACK_RPM_SPEC_MORE_DEFINE \"/CPACK_RPM_SPEC_MORE_DEFINE /" CPackConfig.cmake && \
    make package
