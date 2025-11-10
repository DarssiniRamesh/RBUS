#!/bin/bash
set -e
set -x

# Build from the repository root (this script is expected to run inside RBUS/)
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f "${REPO_ROOT}/CMakeLists.txt" ]; then
  echo "Error: CMakeLists.txt not found at ${REPO_ROOT}. Ensure you are in the RBUS repository."
  exit 1
fi

echo "======================================================================================"
echo "Building RBUS for coverity"

cmake -S "${REPO_ROOT}" -B "${REPO_ROOT}/build/rbus" \
  -DCMAKE_INSTALL_PREFIX="${REPO_ROOT}/install/usr" \
  -DBUILD_FOR_DESKTOP=ON \
  -DENABLE_UNIT_TESTING=ON \
  -DCMAKE_BUILD_TYPE=Debug

cmake --build "${REPO_ROOT}/build/rbus" --target install --parallel
echo "======================================================================================"
exit 0
