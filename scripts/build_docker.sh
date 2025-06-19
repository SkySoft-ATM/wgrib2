#!/bin/bash
set -euo pipefail

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "${PROJECT_DIR}" || exit 1

docker build -t wgrib2 -f Dockerfile .
docker create --name tmpwgrib2 wgrib2

rm -rf "${PROJECT_DIR}/for_skytp"
docker cp tmpwgrib2:/wgrib2/for_skytp "${PROJECT_DIR}/for_skytp" && \
    docker rm tmpwgrib2 && \
    docker rmi wgrib2
