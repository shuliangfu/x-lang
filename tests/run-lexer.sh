#!/usr/bin/env bash
# lexer smoke: invalid_char NEG hard; token-dump POS → obs (product no dump).
#
# Honesty: soft auto-make xlang-c + soft SKIP token-dump when XLANG set + soft
# prefer-c NEG fallback (false authority) retired. Prefer product xlang_asm;
# pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native = hard die (refuse
# soft SKIP→OK / soft auto-make / prefer-c / soft bootstrap-link).
# Token-list dump vs expected.txt is seed/xlang-c-era behavior; product
# xlang_asm/xlang no longer emit token streams without -o → obs= (fixtures
# kept), not soft FAIL→OK. Product -o invalid_char L003 is the hard gate.
# Report: run=/obs=/skip=
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_LEXER_PREFIX:-xlang: [LEXER]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "lexer FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
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
  if [ -n "${XLANG_BSTRICT_USE_ASM2:-}" ] && dod_native_exe ./compiler/xlang_asm2; then
    echo "$(pwd)/compiler/xlang_asm2"
    return 0
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

echo "=== lexer gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# Fixtures kept on disk (token-dump era); count obs, do not soft-green.
for dump_arm in main comments; do
  [ -f "tests/lexer/${dump_arm}.x" ] || die "missing tests/lexer/${dump_arm}.x"
  [ -f "tests/lexer/expected.txt" ] || die "missing tests/lexer/expected.txt"
  [ -f "tests/lexer/expected-comments.txt" ] || die "missing tests/lexer/expected-comments.txt"
  echo "lexer OBS token_dump_${dump_arm} (product no token stream; not soft FAIL→OK)" >&2
  OBS=$((OBS + 1))
done

# Hard NEG: illegal character → product -o must fail with L003 / illegal character.
neg_src="tests/lexer/invalid_char.x"
[ -f "$neg_src" ] || die "missing $neg_src"
neg_exe="/tmp/xlang_lexer_fail_$$"
neg_log="/tmp/xlang_lexer_fail_$$.log"
rm -f "$neg_exe" "$neg_log"
set +e
gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" build "$neg_src" -o "$neg_exe" >"$neg_log" 2>&1
neg_ec=$?
set -e
if [ "$neg_ec" -eq 124 ]; then
  die "invalid_char timeout"
elif [ "$neg_ec" -eq 0 ]; then
  die "invalid_char expected compile fail, got success"
fi
grep -qE 'illegal character|L003' "$neg_log" \
  || die "expected illegal character/L003; $(tail -5 "$neg_log" 2>/dev/null | tr '\n' ' ')"
rm -f "$neg_exe" "$neg_log"
RUN_OK=$((RUN_OK + 1))

ok_report
echo "lexer test OK"
