#!/usr/bin/env bash
# C-08 v1：runtime vs .x driver 迁移盘点（manifest + 关键符号）。
#
# 用法：./tests/run-c08-runtime-inventory-gate.sh
# wave honesty (2026-08-24 #4): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# monofile seeds/runtime.from_x.c retired wave321 — live = multi-slice rt_* seeds.
# Override: XLANG_C08_RT="f1 f2…", XLANG_C08_DOC=…
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."

MANIFEST="${XLANG_C08_MANIFEST:-tests/baseline/c08-runtime-driver-inventory.tsv}"
DOC="${XLANG_C08_DOC:-analysis/archive/phase/phase-c-c08-v1.md}"
# Live slices that still carry XLANG_USE_X_DRIVER / driver_run_compiler_full.
RT="${XLANG_C08_RT:-compiler/seeds/rt_dispatch_impl.from_x.c compiler/seeds/rt_dispatch_thin_surface.from_x.c compiler/seeds/rt_run_compiler_parsed.from_x.c compiler/seeds/rt_run_x_emit.from_x.c}"

c08_any_file_has() {
  local needle="$1"
  local f
  for f in $RT; do
    if grep -qF "$needle" "$f" 2>/dev/null; then
      return 0
    fi
  done
  return 1
}

echo "=== C-08: runtime/driver inventory ==="
for f in "$MANIFEST" "$DOC"; do
  [ -f "$f" ] || { echo "c08 inventory FAIL: missing $f" >&2; exit 1; }
done
for f in $RT; do
  [ -f "$f" ] || { echo "c08 inventory FAIL: missing live seed $f" >&2; exit 1; }
done
c08_any_file_has 'XLANG_USE_X_DRIVER' || {
  echo "c08 inventory FAIL: live rt_* seeds missing XLANG_USE_X_DRIVER sections" >&2
  exit 1
}
c08_any_file_has 'driver_run_compiler_full' || {
  echo "c08 inventory FAIL: live rt_* seeds missing driver_run_compiler_full" >&2
  exit 1
}
# Live ABI export is main_entry (bare `entry` retired — L4 UNDEF risk if diverged).
grep -q 'function main_entry(' compiler/src/main.x || {
  echo "c08 inventory FAIL: main.x missing main_entry()" >&2
  exit 1
}
echo "c08 runtime inventory OK"
