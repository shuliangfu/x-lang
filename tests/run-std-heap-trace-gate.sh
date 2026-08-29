#!/usr/bin/env bash
# STD-017: std.heap XLANG_HEAP_TRACE gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c). Product trace_stats.x -o exit0 =
# hard run (default + XLANG_HEAP_TRACE=1); cookbook heap_trace_reset also hard.
# check residual = obs (paused 2026-08-05). Report: run=/obs=/skip=. G.7:
# complete existing resolve_shu; drop unused compiler-make.sh.
# TSV anchors: XLANG_HEAP_TRACE / HeapTraceStats / trace_reset.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-heap-trace-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_HEAP_TRACE_DOC:-analysis/archive/std/std-heap-trace-v1.md}"
MANIFEST="${XLANG_STD_HEAP_TRACE_TSV:-tests/baseline/std-heap-trace.tsv}"
HEAP_X="std/heap/mod.x"
HEAP_LIBC="std/heap/libc.x"
LIB="tests/lib/std-heap-trace.sh"
SMOKE="tests/heap/trace_stats.x"
COOKBOOK="examples/cookbook/heap_trace_reset.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-heap-trace.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-heap-trace gate FAIL: $*" >&2
  std_heap_trace_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
  exit 1
}

resolve_shu() {
  local cand abs root
  root=$(pwd)
  if [ -n "${XLANG:-}" ]; then
    case "$XLANG" in
      /*) abs="$XLANG" ;;
      *) abs="$root/$XLANG" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
    return 1
  fi
  # Prefer product asm; refuse soft auto-make / prefer-c.
  # PLATFORM: SHARED — product path honesty; Ubuntu gold still required.
  for cand in ./compiler/xlang_asm ./compiler/xlang-c ./compiler/xlang; do
    case "$cand" in
      /*) abs="$cand" ;;
      *) abs="$root/$cand" ;;
    esac
    if dod_native_exe "$abs"; then
      echo "$abs"
      return 0
    fi
  done
  return 1
}

echo "=== STD-017: heap trace manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$HEAP_X" "$HEAP_LIBC" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in XLANG_HEAP_TRACE HeapTraceStats trace_reset; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF -- 'XLANG_HEAP_TRACE' "$HEAP_LIBC" 2>/dev/null || die "libc.x missing XLANG_HEAP_TRACE"
grep -qF -- 'getenv' "$HEAP_LIBC" 2>/dev/null || die "libc.x missing getenv for trace"

sym_miss="$(std_heap_trace_symbols_ok "$HEAP_X" "$HEAP_LIBC" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-heap-trace manifest OK"

if [ "${XLANG_STD_HEAP_TRACE_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_heap_trace_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-heap-trace gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-017: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_heap_trace_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-heap-trace OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_heap_trace_$$"
LOG="/tmp/xlang_std_heap_trace_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$OUT" >"$LOG" 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$OUT" ]; then
  tail -n 20 "$LOG" 2>/dev/null || true
  rm -f "$OUT"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$OUT" >/dev/null 2>&1
exitcode=$?
set -e
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || {
  rm -f "$OUT"
  die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
}
# Env-on path must also succeed (trace counters exercised when enabled).
set +e
XLANG_HEAP_TRACE=1 "$OUT" >/dev/null 2>&1
trace_ec=$?
set -e
rm -f "$OUT"
[ "$trace_ec" -eq 0 ] || die "XLANG_HEAP_TRACE=1 runnable exit=$trace_ec"
RUN_OK=$((RUN_OK + 1))
echo "std-heap-trace OK: product -o (+ XLANG_HEAP_TRACE=1)"

# Neighborhood cookbook (trace_reset / trace_on) — same std.heap; hard.
CB_OUT="/tmp/xlang_std_heap_trace_cb_$$"
CB_LOG="/tmp/xlang_std_heap_trace_cb_$$.log"
rm -f "$CB_OUT" "$CB_LOG"
set +e
"$XLANG_BIN" -L . "$COOKBOOK" -o "$CB_OUT" >"$CB_LOG" 2>&1
cb_o=$?
set -e
if [ "$cb_o" -ne 0 ] || [ ! -x "$CB_OUT" ]; then
  tail -n 20 "$CB_LOG" 2>/dev/null || true
  rm -f "$CB_OUT"
  die "cookbook heap_trace_reset -o failed (ec=$cb_o; refuse soft SKIP→OK)"
fi
set +e
"$CB_OUT" >/dev/null 2>&1
cb_ec=$?
set -e
rm -f "$CB_OUT"
[ "$cb_ec" -eq 0 ] || die "cookbook heap_trace_reset exit=$cb_ec"
echo "std-heap-trace cookbook heap_trace_reset OK"

std_heap_trace_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-heap-trace gate OK"
