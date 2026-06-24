#!/usr/bin/env bash
# STD-142：std.process 跨平台行为一致性门禁
#
# 用法：./tests/run-std-process-xplat-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-process-xplat-v1.md"
MANIFEST="tests/baseline/std-process-xplat-manifest.tsv"
VECTORS="tests/baseline/std-process-xplat.tsv"
MOD_SX="std/process/mod.sx"
PROC_C="${SHUX_STD_PROCESS_IMPL:-compiler/src/asm/runtime_process_os_glue.c}"
PROC_SX="std/process/process.sx"
LIB="tests/lib/std-process-xplat.sh"
SMOKE_SX="tests/process/xplat_behavior.sx"
MIN_VECTORS=10

# shellcheck source=tests/lib/std-process-xplat.sh
. "$LIB"

echo "=== STD-142: std.process xplat manifest ==="
for f in "$DOC" "$MANIFEST" "$VECTORS" "$LIB" "$MOD_SX" "$PROC_C" "$PROC_SX" "$SMOKE_SX" std/process/README.md; do
  if [ ! -f "$f" ]; then
    echo "std-process-xplat gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-142 spawn_io getppid spawn_wait_win pipe; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-process-xplat gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(std_process_xplat_symbols_ok "$MOD_SX" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_process_xplat_emit_report "fail" 0 0
  exit 1
fi

if ! std_process_xplat_vectors_ok "$VECTORS" "$MIN_VECTORS"; then
  std_process_xplat_emit_report "fail" 0 0
  exit 1
fi
echo "std-process-xplat registry OK"

make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o 2>/dev/null || true

SX_OK=0
SKIP=0
SHUX_BIN=""
if [ -x ./compiler/shux-c ]; then SHUX_BIN=./compiler/shux-c; fi

if [ -n "$SHUX_BIN" ]; then
  for sx in "$SMOKE_SX" tests/process/boundary.sx tests/process/spawn_wait_win.sx tests/process/spawn_pipe_echo.sx; do
    if ! "$SHUX_BIN" check -L . "$sx" >/dev/null 2>&1; then
      echo "std-process-xplat gate FAIL: typeck $sx" >&2
      std_process_xplat_emit_report "fail" 0 0
      exit 1
    fi
  done
  if std_process_xplat_run_smoke "$SHUX_BIN" "$SMOKE_SX"; then
    SX_OK=1
  else
    std_process_xplat_emit_report "fail" 0 0
    exit 1
  fi
else
  echo "std-process-xplat gate SKIP .sx smoke (no shux)" >&2
  SKIP=1
fi

std_process_xplat_emit_report "ok" "$SX_OK" "$SKIP"
echo "std-process-xplat gate OK"
