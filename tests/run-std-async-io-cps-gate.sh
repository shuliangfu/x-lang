#!/usr/bin/env bash
# STD-042：std.async IO 与 CPS suspend 统一文档门禁
#
# 用法：./tests/run-std-async-io-cps-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_ASYNC_IO_CPS_DOC:-analysis/std-async-io-cps-v1.md}"
MANIFEST="${SHUX_STD_ASYNC_IO_CPS_TSV:-tests/baseline/std-async-io-cps.tsv}"
MOD_X="std/async/mod.x"
IO_X="std/io/mod.x"
SCHED_C="compiler/src/asm/runtime_scheduler_glue.c"
IO_C="std/io/mod.x"
LIB="tests/lib/std-async-io-cps.sh"
ALIGN_X="tests/async/io_cps_align.x"
IO_URING_X="tests/async/io_uring_facade.x"
EMIT_X="tests/parser/async_await_io.x"
MIN_SYMS=4

# shellcheck source=tests/lib/std-async-io-cps.sh
. "$LIB"

echo "=== STD-042: async IO CPS manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$IO_X" "$SCHED_C" "$IO_C" "$ALIGN_X" "$IO_URING_X" "$EMIT_X"; do
  if [ ! -f "$f" ]; then
    echo "std-async-io-cps gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-042 STD-049 poll_async_completions cps_suspend_io IO_ASYNC_NOT_READY drain_until_idle io_uring_is_available; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-async-io-cps gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_syms) MIN_SYMS="$c2" ;;
  esac
done < "$MANIFEST"

SYM_N=0
while IFS=$'\t' read -r item_id kind anchor _rest; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    symbol)
      SYM_N=$((SYM_N + 1))
      ;;
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-async-io-cps gate FAIL: doc missing section $anchor" >&2
        exit 1
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SYM_N" -lt "$MIN_SYMS" ]; then
  echo "std-async-io-cps gate FAIL: symbol count $SYM_N < min $MIN_SYMS" >&2
  exit 1
fi

sym_miss="$(std_async_io_cps_symbols_ok "$MOD_X" "$IO_X" "$SCHED_C" "$IO_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_async_io_cps_emit_report "fail" 0 0 0 0
  echo "std-async-io-cps gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-async-io-cps manifest OK"

stdlib_cm_native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

ALIGN_OK=0
IO_URING_OK=0
EMIT_OK=0
SKIP=1
if SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux-c && echo ./compiler/shux-c || true)"; then
  :
elif SHUX_BIN="$(stdlib_cm_native_shu ./compiler/shux && echo ./compiler/shux || true)"; then
  :
else
  SHUX_BIN=""
fi

if [ -n "$SHUX_BIN" ]; then
  echo "=== STD-042: typeck + smoke + emit (SHUX=$SHUX_BIN) ==="
  make -C compiler -q ../std/async/scheduler.o 2>/dev/null || make -C compiler ../std/async/scheduler.o 2>/dev/null || true
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c 2>/dev/null || true
  if ! "$SHUX_BIN" check -L . "$ALIGN_X" >/dev/null 2>&1; then
    echo "std-async-io-cps gate FAIL: typeck $ALIGN_X" >&2
    "$SHUX_BIN" check -L . "$ALIGN_X" 2>&1 | tail -10 >&2 || true
    std_async_io_cps_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if ! "$SHUX_BIN" check -L . "$IO_URING_X" >/dev/null 2>&1; then
    echo "std-async-io-cps gate FAIL: typeck $IO_URING_X" >&2
    "$SHUX_BIN" check -L . "$IO_URING_X" 2>&1 | tail -10 >&2 || true
    std_async_io_cps_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_async_io_cps_run_smoke "$SHUX_BIN" "$ALIGN_X" "align"; then
    ALIGN_OK=1
  else
    std_async_io_cps_emit_report "fail" 0 0 0 0
    exit 1
  fi
  if std_async_io_cps_run_smoke "$SHUX_BIN" "$IO_URING_X" "io_uring"; then
    IO_URING_OK=1
  else
    std_async_io_cps_emit_report "fail" "$ALIGN_OK" 0 0 0
    exit 1
  fi
  if std_async_io_cps_check_emit "$SHUX_BIN" "$EMIT_X"; then
    EMIT_OK=1
  else
    std_async_io_cps_emit_report "fail" "$ALIGN_OK" "$IO_URING_OK" 0 0
    exit 1
  fi
  SKIP=0
else
  echo "std-async-io-cps gate SKIP smoke (no native shux)" >&2
fi

std_async_io_cps_emit_report "ok" "$ALIGN_OK" "$IO_URING_OK" "$EMIT_OK" "$SKIP"
echo "std-async-io-cps gate OK"
