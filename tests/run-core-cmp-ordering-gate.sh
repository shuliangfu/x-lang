#!/usr/bin/env bash
# CORE-005: core.cmp Ordering gate — honesty soft→硬绿.
#
# Honesty: soft SKIP→OK (no native) + soft auto-make xlang-c + check SKIP
# narrative retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make). Product -o tests/cmp/main.x exit0 = hard run; check = obs.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-core-cmp-ordering-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/core-cmp-ordering.sh
. tests/lib/core-cmp-ordering.sh

DOC="${XLANG_CORE_CMP_DOC:-analysis/archive/core/core-cmp-ordering-v1.md}"
MANIFEST="${XLANG_CORE_CMP_TSV:-tests/baseline/core-cmp-ordering.tsv}"
CMP_X="core/cmp/mod.x"
SMOKE="tests/cmp/main.x"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "core-cmp-ordering gate FAIL: $*" >&2
  core_cmp_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== CORE-005: cmp/Ordering manifest (archive DOC) ==="
if [ -f analysis/core-cmp-ordering-v1.md ]; then
  die "top-level DOC resurrected (live = archive/core/)"
fi
for f in "$DOC" "$MANIFEST" tests/lib/core-cmp-ordering.sh "$CMP_X" "$SMOKE"; do
  [ -f "$f" ] || die "missing $f"
done
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
for kw in Ordering cmp_i32 cmp_u8 cmp_ptr then; do
  grep -qF "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(core_cmp_symbols_ok "$CMP_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "core-cmp-ordering manifest OK"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== CORE-005: smoke (XLANG=$XLANG_BIN) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_core_cmp_check.log 2>&1
chk_ec=$?
set -e
if [ "$chk_ec" -ne 0 ]; then
  echo "core-cmp-ordering OBS check (paused / CHK residual ec=$chk_ec; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

exe="/tmp/xlang_core_cmp_$$"
rm -f "$exe" 2>/dev/null || true
set +e
"$XLANG_BIN" -L . "$SMOKE" -o "$exe" >/tmp/xlang_core_cmp_o.log 2>&1
o_ec=$?
set -e
if [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
  tail -n 12 /tmp/xlang_core_cmp_o.log 2>/dev/null || true
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

echo "core-cmp-ordering gate OK"
core_cmp_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
