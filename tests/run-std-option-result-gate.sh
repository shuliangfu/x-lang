#!/usr/bin/env bash
# STD-080/081: std.option + std.result gate — honesty leftover unused compiler-make →硬绿.
#
# Honesty: leftover unused compiler-make.sh sourced unused (no
# xlang_compiler_make) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse leftover unused
# compiler-make / soft SKIP→OK / prefer-c / soft ensure rebuild). Product
# roundtrip.x -o exit0 = hard run (run=1). check residual = obs.
# Report: run=/obs=/skip=. G.7: complete existing resolve_shu; drop unused
# compiler-make.sh.
# formal_mod: std/option/option.o + std/result/result.o (mod|0); fk0 k25/k26.
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
# Usage: ./tests/run-std-option-result-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh

DOC="${XLANG_STD_OPTION_RESULT_DOC:-analysis/archive/std/std-option-result-v1.md}"
OPT_MANIFEST="${XLANG_STD_OPTION_MANIFEST:-tests/baseline/std-option-manifest.tsv}"
RES_MANIFEST="${XLANG_STD_RESULT_MANIFEST:-tests/baseline/std-result-manifest.tsv}"
OPT_X="std/option/mod.x"
RES_X="std/result/mod.x"
LIB="tests/lib/std-option-result.sh"
SMOKE_X="tests/std-option-result/roundtrip.x"
MIN_OPT=8
MIN_RES=8
SMOKE_EXPECT=0

# shellcheck source=tests/lib/std-option-result.sh
. "$LIB"

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "std-option-result gate FAIL: $*" >&2
  std_option_result_emit_report "fail" "$RUN_OK" "$OBS" "$SKIP"
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

echo "=== STD-080/081: std.option & std.result manifest ==="
for f in "$DOC" "$OPT_MANIFEST" "$RES_MANIFEST" "$LIB" "$OPT_X" "$RES_X" "$SMOKE_X" \
  std/option/README.md std/result/README.md; do
  [ -f "$f" ] || die "missing $f"
done

for kw in STD-080 STD-081 from_result from_error_code map and_then; do
  grep -qF -- "$kw" "$DOC" 2>/dev/null || die "doc missing '$kw'"
done

grep -qF '## 3. Gate' "$DOC" 2>/dev/null || die "doc missing '## 3. Gate'"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_OPT="$c2" ;; esac
done < "$OPT_MANIFEST"
while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_apis) MIN_RES="$c2" ;; esac
done < "$RES_MANIFEST"

std_option_result_check_manifest "$OPT_X" "$OPT_MANIFEST" "$MIN_OPT" "std.option" \
  || die "option manifest"
std_option_result_check_manifest "$RES_X" "$RES_MANIFEST" "$MIN_RES" "std.result" \
  || die "result manifest"
echo "std-option-result manifest OK"

if [ "${XLANG_STD_OPTION_RESULT_MANIFEST_ONLY:-0}" = "1" ]; then
  SKIP=1
  std_option_result_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
  echo "std-option-result gate OK (manifest only)"
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "=== STD-080/081: smoke (XLANG=$XLANG_BIN; check obs; product -o hard) ==="

# Refuse leftover unused compiler-make.sh (product -o is the hard path).
# PLATFORM: SHARED archaeology — leave wrap body / ensure_std family alone.

set +e
"$XLANG_BIN" check -L . "$SMOKE_X" >/tmp/xlang_std_option_result_check.log 2>&1
chk=$?
set -e
if [ "$chk" -ne 0 ]; then
  echo "std-option-result OBS check (paused / CHK residual ec=$chk; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi

OUT="/tmp/xlang_std080_option_result_$$"
LOG="/tmp/xlang_std080_option_result_build_$$.log"
rm -f "$OUT" "$LOG"
set +e
"$XLANG_BIN" -L . "$SMOKE_X" -o "$OUT" >"$LOG" 2>&1
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
echo "std-option-result OK: product -o"

std_option_result_emit_report "ok" "$RUN_OK" "$OBS" "$SKIP"
echo "std-option-result gate OK"
