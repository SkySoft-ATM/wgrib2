FROM golang:1.24
RUN apt update
RUN apt install -y libg2c-dev libg2c0d libaec-dev cmake libnetcdf-dev gfortran
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
