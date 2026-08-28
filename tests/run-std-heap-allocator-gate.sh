#!/usr/bin/env bash
# STD-112: std.heap Allocator trait gate — honesty soft auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# heap/vec .o make) + soft XLANG fallthrough (explicit-bad still picks another
# binary) + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c). Product allocator_vec.x -o exit0 = hard
# run; cookbook heap_trace_reset neighborhood also hard. check residual = obs
# (paused 2026-08-05). Report: run=/obs=/skip=.
# TSV anchors: with_alloc / push.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-heap-allocator-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD112_DOC:-analysis/archive/std/std-heap-allocator-v1.md}"
MANIFEST="${XLANG_STD112_TSV:-tests/baseline/std-heap-allocator.tsv}"
HEAP_X="std/heap/mod.x"
VEC_X="std/vec/mod.x"
LIB="tests/lib/std-heap-allocator.sh"
SMOKE="tests/heap/allocator_vec.x"
COOKBOOK="examples/cookbook/heap_trace_reset.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-heap-allocator.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-heap-allocator gate FAIL: $*" >&2
  std_heap_alloc_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-112: heap Allocator manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$HEAP_X" "$VEC_X" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-112 heap_alloc from_arena with_alloc; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(std_heap_alloc_symbols_ok "$HEAP_X" "$VEC_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-heap-allocator manifest OK"

if [ "${XLANG_STD112_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_heap_alloc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-heap-allocator gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-112: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_heap_alloc_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-heap-allocator OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_heap_alloc_$$"
LOG="/tmp/xlang_std_heap_alloc_build_$$.log"
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
rm -f "$OUT"
[ "$exitcode" -eq "$SMOKE_EXPECT" ] || die "runnable exit=$exitcode (expect $SMOKE_EXPECT)"
RUN_OK=$((RUN_OK + 1))
echo "std-heap-allocator OK: product -o"

# Neighborhood cookbook (std.heap trace surface) — same module; hard.
CB_OUT="/tmp/xlang_std_heap_alloc_cb_$$"
CB_LOG="/tmp/xlang_std_heap_alloc_cb_$$.log"
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
echo "std-heap-allocator cookbook heap_trace_reset OK"

std_heap_alloc_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-heap-allocator gate OK"
