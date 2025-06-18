FROM registry.access.redhat.com/ubi8/ubi:8.10
WORKDIR /opt
RUN yum install -y gcc gcc-c++ gcc-gfortran make cmake git zlib-devel libcurl-devel libpng-devel
RUN git clone https://github.com/hdfgroup/hdf5
WORKDIR /opt/hdf5
RUN git checkout hdf5_1.14.6
RUN mkdir build
WORKDIR /opt/hdf5/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DHDF5_BUILD_HL_LIB=ON -DHDF5_BUILD_TOOLS=OFF -DHDF5_BUILD_EXAMPLES=OFF
RUN make -j $(nproc)
RUN make install
WORKDIR /opt
RUN rm -rf hdf5

RUN git clone https://github.com/Unidata/netcdf-c
WORKDIR /opt/netcdf-c
RUN git checkout v4.9.3
RUN mkdir build
WORKDIR /opt/netcdf-c/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
RUN make -j $(nproc)
RUN make install
WORKDIR /opt
RUN rm -rf netcdf-c

RUN yum install -y libjpeg-turbo-devel
RUN git clone https://github.com/jasper-software/jasper
WORKDIR /opt/jasper
RUN git checkout version-4.2.5
RUN mkdir -p cmake_build
WORKDIR /opt/jasper/cmake_build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DALLOW_IN_SOURCE_BUILD=ON
RUN make -j $(nproc)
RUN make install
WORKDIR /opt
RUN rm -rf jasper

RUN git clone https://github.com/NOAA-EMC/NCEPLIBS-g2c
RUN cmake -S NCEPLIBS-g2c -B NCEPLIBS-g2c/build
RUN cmake --build NCEPLIBS-g2c/build --parallel $(nproc)
RUN cmake --install NCEPLIBS-g2c/build
RUN rm -rf NCEPLIBS-g2c

ADD aux_progs /wgrib2/aux_progs
ADD c_api /wgrib2/c_api
ADD cmake /wgrib2/cmake
ADD CMakeLists.txt /wgrib2/CMakeLists.txt
ADD docs /wgrib2/docs
ADD extra /wgrib2/extra
ADD pywgrib2_s /wgrib2/pywgrib2_s
ADD scripts /wgrib2/scripts
ADD spack /wgrib2/spack
ADD tests /wgrib2/tests
ADD VERSION /wgrib2/VERSION
ADD wgrib /wgrib2/wgrib
ADD wgrib2 /wgrib2/wgrib2
ADD wmo_scripts /wgrib2/wmo_scripts
WORKDIR /wgrib2
RUN scripts/build.sh
