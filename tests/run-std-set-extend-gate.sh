#!/usr/bin/env bash
# STD-015: std.set Set_u64 / Set_str extend gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# extend.x -o exit0 = hard run (run=1); cookbook set_u64_insert also hard.
# check residual = obs. Report: run=/obs=/skip=. G.7: complete existing
# resolve_shu; drop unused compiler-make.sh.
# TSV anchors: Set_u64 / Set_str / insert / remove / str_*.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-set-extend-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_SET_EXTEND_DOC:-analysis/archive/std/std-set-extend-v1.md}"
MANIFEST="${XLANG_STD_SET_EXTEND_TSV:-tests/baseline/std-set-extend.tsv}"
SET_X="std/set/mod.x"
LIB="tests/lib/std-set-extend.sh"
SMOKE="tests/set/extend.x"
COOKBOOK="examples/cookbook/set_u64_insert.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-set-extend.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-set-extend gate FAIL: $*" >&2
  std_set_extend_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-015: set extend manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$SET_X" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in Set_u64 Set_str hash_bytes set_str_key_cap; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(std_set_extend_symbols_ok "$SET_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-set-extend manifest OK"

if [ "${XLANG_STD_SET_EXTEND_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_set_extend_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-set-extend gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-015: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_set_extend_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-set-extend OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_set_extend_$$"
LOG="/tmp/xlang_std_set_extend_build_$$.log"
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
echo "std-set-extend OK: product -o"

# Neighborhood cookbook (Set_u64 insert/contains_key/remove) — same std.set; hard.
CB_OUT="/tmp/xlang_std_set_extend_cb_$$"
CB_LOG="/tmp/xlang_std_set_extend_cb_$$.log"
rm -f "$CB_OUT" "$CB_LOG"
set +e
"$XLANG_BIN" -L . "$COOKBOOK" -o "$CB_OUT" >"$CB_LOG" 2>&1
cb_o=$?
set -e
if [ "$cb_o" -ne 0 ] || [ ! -x "$CB_OUT" ]; then
  tail -n 20 "$CB_LOG" 2>/dev/null || true
  rm -f "$CB_OUT"
  die "cookbook set_u64_insert -o failed (ec=$cb_o; refuse soft SKIP→OK)"
fi
set +e
"$CB_OUT" >/dev/null 2>&1
cb_ec=$?
set -e
rm -f "$CB_OUT"
[ "$cb_ec" -eq 0 ] || die "cookbook set_u64_insert exit=$cb_ec"
echo "std-set-extend cookbook set_u64_insert OK"

std_set_extend_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-set-extend gate OK"
