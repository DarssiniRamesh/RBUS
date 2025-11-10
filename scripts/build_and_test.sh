#!/usr/bin/env bash
# A helper script to configure, build, install, and run RBUS unit tests from the repository root.
# This script is designed to be executed from the repo root without changing directories.
# It ensures correct paths (no nested RBUS/RBUS) and exits non-zero on failure.

set -euo pipefail

# PUBLIC_INTERFACE
# This script can be run as:
#   scripts/build_and_test.sh
# Optional environment variables:
#   BUILD_DIR: relative path for build directory (default: build/rbus)
#   INSTALL_PREFIX: absolute or relative path to install prefix (default: "$PWD/install/usr")
#   BUILD_TYPE: CMake build type (default: Debug)
#   PARALLEL_JOBS: Number of parallel build jobs (default: auto, delegated to cmake --build --parallel)
# Behavior:
#   - Configures using cmake -S . -B "${BUILD_DIR}"
#   - Installs to "${INSTALL_PREFIX}"
#   - Enables unit testing and desktop build
#   - Builds and installs targets
#   - Attempts to run gtest binary if present

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Defensive check: ensure this script is invoked from within the RBUS repo root.
# The repo root contains CMakeLists.txt and directories like src/, utils/, etc.
if [[ ! -f "${ROOT_DIR}/CMakeLists.txt" ]]; then
  echo "Error: CMakeLists.txt not found at repo root: ${ROOT_DIR}"
  echo "Please run this script from within the RBUS repository root (RBUS)."
  exit 1
fi

# Fail fast if caller explicitly tries to use a nested RBUS path
if [[ "${PWD}" == *"/RBUS/RBUS"* ]] || [[ "${ROOT_DIR}" == *"/RBUS/RBUS"* ]]; then
  echo "Error: Detected nested path RBUS/RBUS which does not exist in this repository layout."
  echo "Please run from the repository root: .../RBUS"
  exit 1
fi

# Defaults
BUILD_DIR_REL="${BUILD_DIR:-build/rbus}"
BUILD_DIR="${ROOT_DIR}/${BUILD_DIR_REL}"
INSTALL_PREFIX_INPUT="${INSTALL_PREFIX:-${ROOT_DIR}/install/usr}"
BUILD_TYPE="${BUILD_TYPE:-Debug}"

# Normalize install prefix to absolute path
INSTALL_PREFIX="$(python3 - <<'PY'
import os
p=os.environ.get("INSTALL_PREFIX_INPUT","")
print(os.path.abspath(p) if p else "")
PY
)"

# Create required directories
mkdir -p "${BUILD_DIR}"
mkdir -p "${INSTALL_PREFIX}"

echo "== RBUS configure step =="
echo "  Source Dir     : ${ROOT_DIR}"
echo "  Build Dir      : ${BUILD_DIR}"
echo "  Install Prefix : ${INSTALL_PREFIX}"
echo "  Build Type     : ${BUILD_TYPE}"

# Always configure with -S . equivalent using the computed root directory
cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
  -DBUILD_FOR_DESKTOP=ON \
  -DENABLE_UNIT_TESTING=ON \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}"

echo "== RBUS build and install =="
cmake --build "${BUILD_DIR}" --target install --parallel

echo "== RBUS unit tests (best-effort) =="
UT_BIN="${BUILD_DIR}/unittests/rbus_gtest.bin"
if [[ -x "${UT_BIN}" ]]; then
  echo "Running unit tests: ${UT_BIN}"
  set +e
  "${UT_BIN}"
  UT_RC=$?
  set -e
  if [[ ${UT_RC} -ne 0 ]]; then
    echo "Unit tests failed with exit code: ${UT_RC}"
    exit ${UT_RC}
  fi
else
  echo "No unit test binary found at ${UT_BIN}. Skipping test execution."
fi

echo "== RBUS build_and_test.sh completed successfully =="
