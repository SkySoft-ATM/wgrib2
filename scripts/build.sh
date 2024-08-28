#!/bin/bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}" || exit 1
export USE_IPOLATES=OFF
mkdir -p "for_skytp"
cmake -B "for_skytp"
cmake --build "for_skytp" --target wgrib2_lib -j $(nproc)
gcc -shared -o "for_skytp/libwgrib2.so" -Wl,--whole-archive "for_skytp/wgrib2/libwgrib2.a" -Wl,--no-whole-archive
SKYTP_DEP_DIR="${HOME}/go/src/ms-trajectory-prediction/dependencies"
if [ -d "${SKYTP_DEP_DIR}" ]; then
    for dep in for_skytp/config.h for_skytp/libwgrib2.so wgrib2/wgrib2_api.h wgrib2/wgrib2.h; do
        cp "$dep" "${SKYTP_DEP_DIR}/"
    done
fi
