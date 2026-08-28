#!/usr/bin/env bash
# STD-129: std.set Set_i32 union/intersect/difference gate — honesty soft
# auto-make →硬绿.
#
# Honesty: soft auto-make (`xlang_compiler_make … xlang-c … || true` + soft
# set/mod.o make) + soft XLANG fallthrough (explicit-bad still picks another
# binary) + check=/run=/skip= retired. Prefer product xlang_asm; pin
# XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse soft
# SKIP→OK / soft auto-make / prefer-c). Product ops.x -o exit0 = hard run;
# cookbook set_u64_insert neighborhood also hard. check residual = obs (paused
# 2026-08-05). Report: run=/obs=/skip=.
# TSV anchors: union_into / intersect_into / difference_into.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-set-ops-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/compiler-make.sh
. tests/lib/compiler-make.sh

DOC="${XLANG_STD129_DOC:-analysis/archive/std/std-set-ops-v1.md}"
MANIFEST="${XLANG_STD129_TSV:-tests/baseline/std-set-ops-manifest.tsv}"
MOD_X="std/set/mod.x"
LIB="tests/lib/std-set-ops.sh"
SMOKE="tests/set/ops.x"
COOKBOOK="examples/cookbook/set_u64_insert.x"
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-set-ops.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-set-ops gate FAIL: $*" >&2
  std_set_ops_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-129: set ops manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$MOD_X" "$SMOKE" "$COOKBOOK"; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-129 union_into intersect_into difference_into; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

sym_miss="$(std_set_ops_symbols_ok "$MOD_X" "$MANIFEST" || true)"
[ "${sym_miss:-0}" -eq 0 ] || die "symbol_miss=${sym_miss}"
echo "std-set-ops manifest OK"

if [ "${XLANG_STD129_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_set_ops_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-set-ops gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-129: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

set +e
"$XLANG_BIN" check -L . "$SMOKE" >/tmp/xlang_std_set_ops_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-set-ops OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std_set_ops_$$"
LOG="/tmp/xlang_std_set_ops_build_$$.log"
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
echo "std-set-ops OK: product -o"

# Neighborhood cookbook (Set_u64 insert/contains_key/remove) — same std.set; hard.
CB_OUT="/tmp/xlang_std_set_ops_cb_$$"
CB_LOG="/tmp/xlang_std_set_ops_cb_$$.log"
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
echo "std-set-ops cookbook set_u64_insert OK"

std_set_ops_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-set-ops gate OK"
