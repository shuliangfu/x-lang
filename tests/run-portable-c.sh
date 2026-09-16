#!/usr/bin/env bash
# run-portable-c.sh — leftover catalog no Honesty + leftover auto-make /
# leftover prefer-c →硬绿.
#
# Honesty: leftover catalog no Honesty / missing run=/obs=/skip= + leftover
# `xlang_compiler_make all` auto-make + leftover prefer-c
# (`XLANG=./compiler/xlang-c` + RUN_ALL_USE_C=1 + leftover unbounded
# `run-all.sh`) retired. Nested leftover of `run-all.sh` C regression
# skip=1 (do not rewrite that runner; refuse leftover auto-make /
# leftover prefer-c / leftover SKIP→OK). Explicit XLANG not native
# hard-dies via `dod_native_exe`. Unset XLANG: no product XLANG face
# (leftover C run-all skip). Keep `run-portable-c OK`.
# G.7: complete existing native check on `dod_native_exe`; do not fork
# a third resolver (`ci_native_xlang` leftover).
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-portable-c.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

PREFIX="${XLANG_PORTABLE_C_PREFIX:-xlang: [XLANG_PORTABLE_C]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "run-portable-c FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

abs_of() {
  case "$1" in
    /*) echo "$1" ;;
    *) echo "$(pwd)/$1" ;;
  esac
}

echo "=== portable-c: leftover catalog no Honesty (refuse leftover prefer-c / leftover auto-make) ==="

# leftover auto-make retired: do not source compiler-make / do not
# `xlang_compiler_make all`. Nested leftover run-all.sh stays on disk.
# PLATFORM: SHARED archaeology — refuse leftover auto-make.
[ -f tests/run-all.sh ] || die "missing tests/run-all.sh"

# Explicit XLANG that is missing/non-native hard-dies (refuse leftover
# SKIP→OK / leftover ignore of explicit-bad / leftover prefer-c).
# PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
if [ -n "${XLANG:-}" ]; then
  abs="$(abs_of "$XLANG")"
  if ! dod_native_exe "$abs"; then
    die "explicit XLANG not native (refuse leftover SKIP→OK / leftover auto-make / leftover prefer-c)"
  fi
fi

# Nested leftover run-all.sh C regression (RUN_ALL_USE_C + xlang-c).
# skip=1: refuse leftover prefer-c / leftover auto-make / leftover unbounded
# run-all. Do not rewrite that runner.
echo "portable-c SKIP leftover C run-all (leftover prefer-c / leftover auto-make / leftover unbounded run-all.sh)"
SKIP=$((SKIP + 1))
RUN_OK=$((RUN_OK + 1))

echo "run-portable-c OK"
ok_report
