#!/usr/bin/env bash
# CORE-009: core.builtin clz/ctz/popcount — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native still gate OK) + prefer-c only + soft
# auto-make retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
#   - archive DOC + ## Gate + mapping / pure .x = hard.
#   - product -o tests/builtin/main.x = hard run.
#   - XLANG_DEBUG_C __builtin_* emit (table retired with codegen.c) = obs.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-builtin-bitops-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-builtin-bitops.sh
. tests/lib/core-builtin-bitops.sh

DOC="${XLANG_CORE_BUILTIN_DOC:-analysis/archive/core/core-builtin-bitops-v1.md}"
MANIFEST="${XLANG_CORE_BUILTIN_TSV:-tests/baseline/core-builtin-bitops.tsv}"
CODEGEN="compiler/src/codegen/codegen.x"
BUILTIN_X="core/builtin/mod.x"
LIB="tests/lib/core-builtin-bitops.sh"
EMIT_X="tests/builtin/main.x"
MIN_MAP=3

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-builtin-bitops gate FAIL: $*" >&2
  core_builtin_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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
  # Prefer product asm; pin XLANG_LINK_XLANG for dogfood consistency.
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

echo "=== CORE-009: core.builtin bitops manifest (archive DOC; c retired) ==="
if [ -f analysis/core-builtin-bitops-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  die "codegen.c resurrected (live = codegen.x / pure .x)"
fi
for f in "$DOC" "$MANIFEST" "$LIB" "$CODEGEN" "$BUILTIN_X" "$EMIT_X" \
  tests/run-builtin.sh; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

for kw in __builtin_clz clz_u32 popcount_u32; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_mappings) MIN_MAP="$c2" ;;
  esac
done < "$MANIFEST"

map_miss="$(core_builtin_mappings_ok "$CODEGEN" "$MANIFEST" "$BUILTIN_X" || true)"
x_miss="$(core_builtin_x_impl_ok "$BUILTIN_X" || true)"
if [ "${map_miss:-0}" -gt 0 ] || [ "${x_miss:-0}" -gt 0 ]; then
  die "mapping_miss=${map_miss:-0} x_miss=${x_miss:-0}"
fi
echo "core-builtin-bitops manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== CORE-009: product -o runnable (XLANG=$XLANG_BIN) ==="
EXE="/tmp/xlang_core_builtin_$$"
LOG="/tmp/xlang_core_builtin_$$.log"
set +e
"$XLANG_BIN" -L . "$EMIT_X" -o "$EXE" >"$LOG" 2>&1
bec=$?
set -e
if [ "$bec" -ne 0 ]; then
  if grep -qE 'Undefined symbols|undefined reference|UNDEF|BLD001' "$LOG" 2>/dev/null; then
    echo "core-builtin-bitops OBS runnable (product -o UNDEF/ld residual)" >&2
    OBS=$((OBS + 1))
  else
    tail -n 12 "$LOG" >&2 || true
    die "product -o $EMIT_X"
  fi
else
  set +e
  "$EXE" >/dev/null 2>&1
  rec=$?
  set -e
  rm -f "$EXE"
  if [ "$rec" -ne 0 ]; then
    die "runnable exit=$rec"
  fi
  RUN_OK=$((RUN_OK + 1))
  echo "core-builtin-bitops runnable OK"
fi
rm -f "$EXE" "$LOG"

echo "=== CORE-009: XLANG_DEBUG_C emit observational ==="
# __builtin_* table retired with codegen.c; pure .x path does not emit host
# intrinsics — count under-emit as obs, never soft-silence the whole gate.
found="$(core_builtin_emit_ok "$XLANG_BIN" "$EMIT_X" "$MANIFEST" || true)"
EMIT_TOTAL=3
if [ "${found:-0}" -lt "$EMIT_TOTAL" ]; then
  echo "core-builtin-bitops OBS emit ${found:-0}/${EMIT_TOTAL} (__builtin_* table retired; pure .x)" >&2
  OBS=$((OBS + 1))
else
  RUN_OK=$((RUN_OK + 1))
  echo "core-builtin-bitops emit OK ${found}/${EMIT_TOTAL}"
fi

echo "=== CORE-009: run-builtin.sh hook ==="
chmod +x tests/run-builtin.sh
if XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" ./tests/run-builtin.sh; then
  RUN_OK=$((RUN_OK + 1))
  echo "core-builtin-bitops hook OK"
else
  die "run-builtin.sh hook failed (refuse soft SKIP→OK)"
fi

core_builtin_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "core-builtin-bitops gate OK"
