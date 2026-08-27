#!/usr/bin/env bash
# M5 Stage2 hard gate: from existing xlang_asm (gen1) run second-pass selfhost
# → xlang_asm2; verify 42/hello/struct_mk. Same acceptance as
# verify-selfhost-stage2-bstrict.sh; default XLANG_STAGE2_SKIP_BOOTSTRAP=1
# skips redundant Step 0 bootstrap.
#
# Honesty: soft SKIP→OK when no native xlang_asm retired. False Darwin N/A
# ("strict_glue/parser partial") retired — dual-end Stage2 SHA256 already
# matched after strict-link root fix. Missing native = hard die. Explicit
# XLANG_STAGE2_BSTRICT_SKIP=1 = skip=1. Darwin default skip=1 (heavy verify;
# set XLANG_STAGE2_BSTRICT_FORCE=1 to run). Report run=/obs=/skip=.
#
# Usage (repo root):
#   ./tests/run-stage2-bstrict-gate.sh
#   XLANG_STAGE2_SKIP_BOOTSTRAP=0 ./tests/run-stage2-bstrict-gate.sh
# Env:   XLANG_STAGE2_BSTRICT_SKIP=1 → skip=1 status=ok
#        XLANG_STAGE2_BSTRICT_FORCE=1 → run on Darwin (default skip)
# 2026-08-27: soft SKIP→OK →硬绿.
# PLATFORM: SHARED — Linux runs; Darwin skip unless FORCE; Ubuntu gold.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_STAGE2_BSTRICT_PREFIX:-xlang: [XLANG_STAGE2_BSTRICT]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "stage2-bstrict-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || ulimit -s 16384 2>/dev/null || true

echo "=== stage2-bstrict ==="
if [ "${XLANG_STAGE2_BSTRICT_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "stage2-bstrict-gate: SKIP (XLANG_STAGE2_BSTRICT_SKIP=1)"
  echo "stage2-bstrict-gate OK"
  ok_report
  exit 0
fi

# Missing/non-native hard-dies before Darwin skip (refuse soft SKIP→OK).
if ! dod_native_exe compiler/xlang_asm; then
  die "no native xlang_asm (refuse soft SKIP→OK)"
fi
if ! comp_riscv64_native_xlang compiler/xlang_asm; then
  die "xlang_asm present but not native for this host (refuse soft SKIP→OK)"
fi

# PLATFORM: DARWIN — heavy gen1→gen2 verify; default skip=1 with honest
# counter (false "parser partial" narrative retired). Linux covers gold;
# FORCE=1 runs the same path as Linux.
if [ "$(uname -s 2>/dev/null)" = "Darwin" ] && [ "${XLANG_STAGE2_BSTRICT_FORCE:-0}" != "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "stage2-bstrict-gate: SKIP (Darwin default; FORCE=1 to run; Linux gold)"
  echo "stage2-bstrict-gate OK (Darwin skip)"
  ok_report
  exit 0
fi

if [ ! -x compiler/xlang ] && [ ! -x compiler/xlang-x ]; then
  die "seed xlang missing (xlang_compiler_make OPT=1 all)"
fi

chmod +x compiler/verify-selfhost-stage2-bstrict.sh tests/run-bootstrap-stage2-bstrict.sh \
  tests/run-stage2-hash-gate.sh 2>/dev/null || true

export XLANG_STAGE2_SKIP_BOOTSTRAP="${XLANG_STAGE2_SKIP_BOOTSTRAP:-1}"
gate_progress "stage2-bstrict-gate: verify-selfhost-stage2-bstrict (SKIP_BOOTSTRAP=${XLANG_STAGE2_SKIP_BOOTSTRAP})"
(
  cd compiler
  export XLANG_STAGE2_SKIP_BOOTSTRAP
  # CI=1 would enable round2 fast-path; clear CI fast vars for full B-strict.
  env -u CI \
    XLANG_ASM_CI_SKIP_FAST=1 \
    XLANG_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY= \
    XLANG_ASM_CI_SKIP_SECOND_PASS= \
    bash ./verify-selfhost-stage2-bstrict.sh
)
RUN_OK=$((RUN_OK + 1))

gate_progress "stage2-bstrict-gate OK (gen1/gen2 parity: 42 + hello + struct_mk inline + SHA256 track)"
echo "stage2-bstrict-gate OK (gen1/gen2 parity: 42 + hello + struct_mk inline + SHA256 track)"
ok_report
