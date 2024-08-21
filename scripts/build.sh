#!/bin/bash
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}" || exit 1
mkdir -p "for_skytp"
cmake --build "for_skytp" --target wgrib2_lib -j $(nproc)
gcc -shared -o "for_skytp/libwgrib2.so" -Wl,--whole-archive "for_skytp/wgrib2/libwgrib2.a" -Wl,--no-whole-archive
