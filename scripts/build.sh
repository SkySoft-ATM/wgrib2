#!/bin/bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}" || exit 1
CMAKE_BUILD_DIR="${PROJECT_DIR}/cmake-build-debug"
cmake -S . -B "${CMAKE_BUILD_DIR}" -DBUILD_LIB=ON -DBUILD_SHARED_LIB=OFF
cmake --build "${CMAKE_BUILD_DIR}" --target wgrib2_lib -j $(nproc)
gcc -shared -o "${CMAKE_BUILD_DIR}/wgrib2/libwgrib2.so" -Wl,--whole-archive "${PROJECT_DIR}/cmake-build-debug/wgrib2/libwgrib2.a" -Wl,--no-whole-archive
FOR_SKYTP="${PROJECT_DIR}/for_skytp"
rm -rf "${FOR_SKYTP}"
mkdir -p "${FOR_SKYTP}"
cp "${CMAKE_BUILD_DIR}/wgrib2/libwgrib2.so" "${FOR_SKYTP}/libwgrib2.so"
cp "${CMAKE_BUILD_DIR}/config.h" "${FOR_SKYTP}/config.h"
cp "${PROJECT_DIR}/wgrib2/wgrib2.h" "${FOR_SKYTP}/wgrib2.h"
cp "${PROJECT_DIR}/wgrib2/wgrib2_api.h" "${FOR_SKYTP}/wgrib2_api.h"
