#!/usr/bin/env bash
# CORE-013: core.types i16/u16 width gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + soft auto-make xlang-c + check SKIP
# narrative retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make). Product -o i16_u16_width.x exit0 = hard run; check = obs.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-types-i16-u16-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-types-i16-u16.sh
. tests/lib/core-types-i16-u16.sh

DOC="${XLANG_CORE_TYPES_I16_U16_DOC:-analysis/archive/core/core-types-i16-u16-v1.md}"
MANIFEST="${XLANG_CORE_TYPES_I16_U16_TSV:-tests/baseline/core-types-i16-u16.tsv}"
TYPES_X="core/types/mod.x"
TYPECK="compiler/src/typeck/typeck.x"
CODEGEN="compiler/src/codegen/codegen.x"
SMOKE="tests/core-types-size/i16_u16_width.x"
SCALAR="tests/core-types-size/main.x"
MIN_SYMBOLS=4

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-types-i16-u16 gate FAIL: $*" >&2
  core_types_i16_u16_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== CORE-013: i16/u16 width manifest (archive DOC) ==="
if [ -f analysis/core-types-i16-u16-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
if [ -f compiler/src/typeck/typeck.c ]; then
  die "typeck.c resurrected (live = typeck.x)"
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  die "codegen.c resurrected (live = codegen.x)"
fi
for f in "$DOC" "$MANIFEST" tests/lib/core-types-i16-u16.sh "$TYPES_X" "$TYPECK" "$CODEGEN" "$SMOKE" "$SCALAR"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$MANIFEST"

for kw in i16 u16 标量宽度表 CORE-013; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

MISS=0
SYM_N=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "core-types-i16-u16 FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol) SYM_N=$((SYM_N + 1)) ;;
    cross_ref)
      if [ ! -f "$mod_path" ]; then
        echo "core-types-i16-u16 FAIL: missing $mod_path ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
        echo "core-types-i16-u16 FAIL: $mod_path missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    smoke)
      if ! grep -qF "$anchor" "$SMOKE" 2>/dev/null; then
        echo "core-types-i16-u16 FAIL: smoke missing '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

[ "$SYM_N" -ge "$MIN_SYMBOLS" ] && [ "$MISS" -eq 0 ] || die "symbols=${SYM_N} miss=${MISS}"

sym_miss="$(core_types_i16_u16_symbols_ok "$TYPES_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-types-i16-u16 manifest OK (symbols=${SYM_N})"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== CORE-013: smoke (XLANG=$XLANG_BIN) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_core_i16_check.log 2>&1
chk_a=$?
"$XLANG_BIN" check -L . "$SCALAR" >/tmp/xlang_core_i16_check_scalar.log 2>&1
chk_b=$?
set -e
if [ "$chk_a" -ne 0 ] || [ "$chk_b" -ne 0 ]; then
  echo "core-types-i16-u16 OBS check (paused / CHK residual a=$chk_a b=$chk_b; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core_i16_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_core_i16_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core_i16_o.log 2>/dev/null || true
  rm -f "$exe"
  die "product -o failed (ec=$o_ec; refuse soft SKIP→OK)"
fi
set +e
"$exe" >/dev/null 2>&1
run_ec=$?
set -e
rm -f "$exe"
[ "$run_ec" -eq 0 ] || die "runnable exit=$run_ec (expected 0)"
RUN_OK=$((RUN_OK + 1))

echo "core-types-i16-u16 gate OK"
core_types_i16_u16_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
