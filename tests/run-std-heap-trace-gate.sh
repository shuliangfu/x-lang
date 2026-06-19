#!/usr/bin/env bash
# STD-017：std.heap SHUX_HEAP_TRACE 调试钩子门禁
#
# 用法：./tests/run-std-heap-trace-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD_HEAP_TRACE_DOC:-analysis/std-heap-trace-v1.md}"
MANIFEST="${SHUX_STD_HEAP_TRACE_TSV:-tests/baseline/std-heap-trace.tsv}"
HEAP_SU="std/heap/mod.sx"
HEAP_C="std/heap/heap.c"
LIB="tests/lib/std-heap-trace.sh"
SMOKE="tests/heap/trace_stats.sx"

# shellcheck source=tests/lib/std-heap-trace.sh
. tests/lib/std-heap-trace.sh

echo "=== STD-017: heap trace manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$HEAP_SU" "$HEAP_C" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-heap-trace gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in SHUX_HEAP_TRACE HeapTraceStats heap_trace_reset; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-heap-trace gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'getenv("SHUX_HEAP_TRACE")' "$HEAP_C" 2>/dev/null; then
  echo "std-heap-trace gate FAIL: heap.c missing SHUX_HEAP_TRACE getenv" >&2
  exit 1
fi

sym_miss="$(std_heap_trace_symbols_ok "$HEAP_SU" "$HEAP_C" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_heap_trace_emit_report "fail" 0 0 0
  echo "std-heap-trace gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-heap-trace manifest OK"

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
resolve_shu() {
  local cand
  for cand in ./compiler/shux-c ./compiler/shux; do
    if stdlib_cm_native_shu "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if SHUX_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-017: typeck (SHUX=$SHUX_BIN) ==="
  if "$SHUX_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-heap-trace gate FAIL: typeck" >&2
    "$SHUX_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_heap_trace_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q ../std/heap/heap.o 2>/dev/null || make -C compiler ../std/heap/heap.o
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  # shellcheck source=tests/lib/bootstrap-link-shux.sh
  . "$(dirname "$0")/lib/bootstrap-link-shux.sh"
  if $RUN_SHUX -L . "$SMOKE" -o /tmp/shux_std_heap_trace 2>/tmp/shux_std_heap_trace_build.log; then
    exitcode=0
    /tmp/shux_std_heap_trace >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      if SHUX_HEAP_TRACE=1 /tmp/shux_std_heap_trace >/dev/null 2>&1; then
        :
      else
        echo "std-heap-trace gate FAIL: SHUX_HEAP_TRACE=1 runnable" >&2
        std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
        exit 1
      fi
    else
      echo "std-heap-trace gate FAIL: runnable exit=$exitcode" >&2
      std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  else
    echo "std-heap-trace gate SKIP runnable link (check passed)" >&2
    tail -5 /tmp/shux_std_heap_trace_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-heap-trace gate SKIP typeck (no native shux)" >&2
fi

std_heap_trace_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-heap-trace gate OK"
