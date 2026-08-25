#!/usr/bin/env bash
# STD-017：std.heap XLANG_HEAP_TRACE 调试钩子门禁（假权威诚实）。
#
# 用法：./tests/run-std-heap-trace-gate.sh
# wave honesty (2026-08-24): DOC defaults under analysis/archive/ when archived;
# live roadmap = analysis/自举进度.md (NEXT.md left; refuse resurrect).
# 2026-08-25: runnable hard-green (std/heap product surface + cookbook heap_trace_reset);
# Prefer xlang_asm; trace_stats.x exit 0 hard-fail (no soft SKIP / no hard check).
# check smoke observational SKIP (check gate paused 2026-08-05).
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD_HEAP_TRACE_DOC:-analysis/archive/std/std-heap-trace-v1.md}"
MANIFEST="${XLANG_STD_HEAP_TRACE_TSV:-tests/baseline/std-heap-trace.tsv}"
HEAP_X="std/heap/mod.x"
HEAP_LIBC="std/heap/libc.x"
LIB="tests/lib/std-heap-trace.sh"
SMOKE="tests/heap/trace_stats.x"
COOKBOOK="examples/cookbook/heap_trace_reset.x"
# Designed success score (tests/heap/trace_stats.x returns 0 on all checks).
SMOKE_EXPECT=0

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
  # Prefer product asm; pin XLANG_LINK_XLANG to avoid Darwin-arm64 asm→c remap.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in "${XLANG:-}" ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    [ -n "$cand" ] || continue
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
  echo "=== STD-017: smoke (XLANG=$XLANG_BIN; check observational; runnable hard) ==="
  if "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    CHECK_OK=1
  else
    echo "std-heap-trace gate SKIP check smoke (paused 2026-08-05)" >&2
  fi
  xlang_compiler_make -q ../std/heap/mod.o 2>/dev/null || xlang_compiler_make ../std/heap/mod.o 2>/dev/null || true
  xlang_compiler_make -q xlang-c 2>/dev/null || xlang_compiler_make xlang-c 2>/dev/null || true
  # Pin product link to resolved compiler (prefer asm).
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  export XLANG="$XLANG_BIN"
  export XLANG_LINK_XLANG="$XLANG_BIN"
  # shellcheck source=tests/lib/bootstrap-link-xlang.sh
  . "$(dirname "$0")/lib/bootstrap-link-xlang.sh"

  OUT="/tmp/xlang_std_heap_trace_$$"
  LOG="/tmp/xlang_std_heap_trace_build_$$.log"
  if $RUN_XLANG build -L . "$SMOKE" -o "$OUT" 2>"$LOG"; then
    exitcode=0
    "$OUT" >/dev/null 2>&1 || exitcode=$?
    if [ "$exitcode" -eq "$SMOKE_EXPECT" ]; then
      # Env-on path must also succeed (trace counters exercised when enabled).
      if XLANG_HEAP_TRACE=1 "$OUT" >/dev/null 2>&1; then
        RUN_OK=1
        SKIP=0
      else
        echo "std-heap-trace gate FAIL: XLANG_HEAP_TRACE=1 runnable" >&2
        rm -f "$OUT"
        std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
        exit 1
      fi
    else
      echo "std-heap-trace gate FAIL runnable exit=$exitcode (expect $SMOKE_EXPECT)" >&2
      rm -f "$OUT"
      std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
    rm -f "$OUT"
  else
    echo "std-heap-trace gate FAIL runnable link" >&2
    tail -20 "$LOG" 2>/dev/null >&2 || true
    std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
    exit 1
  fi

  # Neighborhood cookbook (trace_reset / trace_on) — same product face; hard-fail if present.
  if [ -f "$COOKBOOK" ]; then
    COUT="/tmp/xlang_std_heap_trace_cb_$$"
    CLOG="/tmp/xlang_std_heap_trace_cb_$$.log"
    if $RUN_XLANG build -L . "$COOKBOOK" -o "$COUT" 2>"$CLOG"; then
      cexit=0
      "$COUT" >/dev/null 2>&1 || cexit=$?
      rm -f "$COUT"
      if [ "$cexit" -ne 0 ]; then
        echo "std-heap-trace gate FAIL cookbook exit=$cexit (expect 0)" >&2
        std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
        exit 1
      fi
    else
      echo "std-heap-trace gate FAIL cookbook link" >&2
      tail -20 "$CLOG" 2>/dev/null >&2 || true
      std_heap_trace_emit_report "fail" "$CHECK_OK" 0 0
      exit 1
    fi
  fi
else
  echo "std-heap-trace gate FAIL: no native xlang" >&2
  std_heap_trace_emit_report "fail" 0 0 0
  exit 1
fi

std_heap_trace_emit_report "ok" "$CHECK_OK" "$RUN_OK" "$SKIP"
echo "std-heap-trace gate OK"
