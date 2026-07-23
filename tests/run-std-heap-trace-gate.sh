#!/usr/bin/env bash
# STD-017：std.heap XLANG_HEAP_TRACE 调试钩子门禁
#
# 用法：./tests/run-std-heap-trace-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${XLANG_STD_HEAP_TRACE_DOC:-analysis/std-heap-trace-v1.md}"
MANIFEST="${XLANG_STD_HEAP_TRACE_TSV:-tests/baseline/std-heap-trace.tsv}"
HEAP_X="std/heap/mod.x"
HEAP_LIBC="std/heap/libc.x"
LIB="tests/lib/std-heap-trace.sh"
SMOKE="tests/heap/trace_stats.x"

# shellcheck source=tests/lib/std-heap-trace.sh
. tests/lib/std-heap-trace.sh

echo "=== STD-017: heap trace manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$HEAP_X" "$HEAP_LIBC" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-heap-trace gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in XLANG_HEAP_TRACE HeapTraceStats trace_reset; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-heap-trace gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'XLANG_HEAP_TRACE' "$HEAP_LIBC" 2>/dev/null; then
  echo "std-heap-trace gate FAIL: libc.x missing XLANG_HEAP_TRACE" >&2
  exit 1
fi
if ! grep -qF 'getenv' "$HEAP_LIBC" 2>/dev/null; then
  echo "std-heap-trace gate FAIL: libc.x missing getenv for trace" >&2
  exit 1
fi

sym_miss="$(std_heap_trace_symbols_ok "$HEAP_X" "$HEAP_LIBC" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_heap_trace_emit_report "fail" 0 0 0
  echo "std-heap-trace gate FAIL: symbol_miss=${sym_miss}" >&2
  exit 1
fi
echo "std-heap-trace manifest OK"

stdlib_cm_native_xlang() {
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
  for cand in ./compiler/xlang-c ./compiler/xlang; do
    if stdlib_cm_native_xlang "$cand"; then
      echo "$cand"
      return 0
    fi
  done
  return 1
}

CHECK_OK=0
RUN_OK=0
SKIP=1
if XLANG_BIN="$(resolve_shu 2>/dev/null)"; then
  echo "=== STD-017: typeck (XLANG=$XLANG_BIN) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-heap-trace gate FAIL: typeck" >&2
    "$XLANG_BIN" check -L . "$SMOKE" 2>&1 | tail -8 >&2 || true
    std_heap_trace_emit_report "fail" 0 0 0
    exit 1
  fi
  SKIP=0
  make -C compiler -q xlang-c 2>/dev/null || XLANG_LEGACY_C_FRONTEND=1 make -C compiler xlang-c
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
  if $RUN_XLANG build -L . "$SMOKE" -o /tmp/xlang_std_heap_trace 2>/tmp/xlang_std_heap_trace_build.log; then
    exitcode=0
    /tmp/xlang_std_heap_trace >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq 0 ]; then
      RUN_OK=1
      if XLANG_HEAP_TRACE=1 /tmp/xlang_std_heap_trace >/dev/null 2>&1; then
        :
      else
        echo "std-heap-trace gate FAIL: XLANG_HEAP_TRACE=1 runnable" >&2
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
    tail -5 /tmp/xlang_std_heap_trace_build.log 2>/dev/null >&2 || true
    SKIP=1
  fi
else
  echo "std-heap-trace gate SKIP typeck (no native xlang)" >&2
fi

std_heap_trace_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-heap-trace gate OK"
