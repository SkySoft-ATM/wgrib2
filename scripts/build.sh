#!/bin/bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}" || exit 1
cmake --build "${PROJECT_DIR}/cmake-build-debug" --target wgrib2_lib -j $(nproc)
gcc -shared -o "${PROJECT_DIR}/cmake-build-debug/wgrib2/libwgrib2.so" -Wl,--whole-archive "${PROJECT_DIR}/cmake-build-debug/wgrib2/libwgrib2.a" -Wl,--no-whole-archive
