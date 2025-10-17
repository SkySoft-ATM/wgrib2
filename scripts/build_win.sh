#!/usr/bin/env bash
set -euo pipefail
set -x
# --- paths --------------------------------------------------------------------
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}"

# prefix where you installed MinGW g2c earlier
G2C_PREFIX="/c/Users/Administrator/work/g2c"

# build dir + staging output
BUILD_DIR="${PROJECT_DIR}/cmake-build-mingw"
STAGE_DIR="${PROJECT_DIR}/for_skytp_win"

# --- configure & build --------------------------------------------------------
rm -rf "${BUILD_DIR}"
cmake -S . -B "${BUILD_DIR}" \
  -G "MinGW Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${G2C_PREFIX};C:/msys64/mingw64" \
  -DBUILD_LIB=ON \
  -DBUILD_SHARED_LIB=OFF \
  -DUSE_NETCDF=OFF \
  -DCMAKE_C_FLAGS="-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE" \
  -DCMAKE_Fortran_FLAGS="-fno-second-underscore"

mingw32-make -C "${BUILD_DIR}" -j

# The library target is usually named wgrib2_lib or similar; if your fork
# produces a static lib at wgrib2/libwgrib2.a, just collect it below.

# --- collect headers + libs for CGO -------------------------------------------
rm -rf "${STAGE_DIR}"
mkdir -p "${STAGE_DIR}/include" "${STAGE_DIR}/lib"

# headers needed by cgo users of wgrib2
cp "${BUILD_DIR}/config.h"                    "${STAGE_DIR}/include/"
cp "${PROJECT_DIR}/wgrib2/wgrib2.h"           "${STAGE_DIR}/include/"
cp "${PROJECT_DIR}/wgrib2/wgrib2_api.h"       "${STAGE_DIR}/include/"

# core static libs (prefer static to avoid DLL chase)
cp "${BUILD_DIR}/wgrib2/libwgrib2.a"          "${STAGE_DIR}/lib/"
cp "${G2C_PREFIX}/lib/libg2c.a"               "${STAGE_DIR}/lib/"

# codec/dep libs from MinGW (static where available)
# If *.a isn’t present on your install, you can omit and let the final link use DLLs.
cp /mingw64/lib/libaec.a                      "${STAGE_DIR}/lib/" || true
cp /mingw64/lib/libopenjp2.a                  "${STAGE_DIR}/lib/" || true
cp /mingw64/lib/libpng.a                      "${STAGE_DIR}/lib/" || true
cp /mingw64/lib/libz.a                        "${STAGE_DIR}/lib/" || true
# regex provider on MinGW (libsystre)
cp /mingw64/lib/libregex.a                    "${STAGE_DIR}/lib/" || true

echo "Staged to: ${STAGE_DIR}"
