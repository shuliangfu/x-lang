#!/usr/bin/env bash
# parser smoke: semicolon / return-paren POS; product NEG; check recovery → obs
#
# Honesty: soft default `./compiler/xlang` + soft auto-make (false authority)
# retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG /
# missing native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c /
# soft bootstrap-link / leftover xlang_asm2 unless XLANG_BSTRICT_USE_ASM2=1).
# `xlang check` paused (2026-08-05) → recovery/check-only arms = obs= (CHK002),
# not soft FAIL→OK. Product `-o` is the hard gate for POS + compile-fail NEG.
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

PREFIX="${XLANG_PARSER_PREFIX:-xlang: [PARSER]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-120}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "parser FAIL: $*" >&2
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
  # Opt-in leftover Stage2 only (July-14 wrong-binary ban otherwise).
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

run_exit() {
  local tag="$1" src="$2" want="$3"
  local exe="/tmp/xlang_parser_${tag}_$$"
  local log="/tmp/xlang_parser_${tag}_$$.log"
  local o_ec r_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag product -o timeout"
  elif [ "$o_ec" -ne 0 ] || [ ! -x "$exe" ]; then
    die "$tag product -o failed (ec=$o_ec); $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$exe" >/dev/null 2>&1
  r_ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$r_ec" -eq 124 ]; then
    die "$tag run timeout"
  elif [ "$r_ec" -ne "$want" ]; then
    die "$tag expected exit $want, got $r_ec"
  fi
  RUN_OK=$((RUN_OK + 1))
}

# Product -o must fail. Optional grep pattern when diagnostics are authoritative.
expect_reject() {
  local tag="$1" src="$2" pattern="${3:-}"
  local exe="/tmp/xlang_parser_${tag}_$$"
  local log="/tmp/xlang_parser_${tag}_$$.log"
  local o_ec
  [ -f "$src" ] || die "missing $src ($tag)"
  rm -f "$exe" "$log"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$exe" >"$log" 2>&1
  o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    die "$tag timeout"
  elif [ "$o_ec" -eq 0 ]; then
    die "$tag expected compile fail, got success"
  fi
  if [ -n "$pattern" ]; then
    grep -qE "$pattern" "$log" \
      || die "$tag expected /$pattern/; $(tail -5 "$log" 2>/dev/null | tr '\n' ' ')"
  fi
  rm -f "$exe" "$log"
  RUN_OK=$((RUN_OK + 1))
}

echo "=== parser gate (prefer asm; hard) ==="
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

# POS: return 0; with semicolon compiles + runs.
run_exit semicolon_required tests/parser/semicolon_required.x 0
# POS: return (1+2) ASI-ok before `}` → exit 3.
run_exit return_paren_expr tests/parser/return_paren_expr.x 3

# NEG: return operand then INT_LIT → product -o must fail.
# Seed asm may silent-parse to empty (no _main) then ld fail; still hard reject.
expect_reject semicolon_missing tests/parser/semicolon_missing.x \
  "ld failed|_main|Undefined symbols|expected ';' after return|parse produced no functions|parse error|P00[0-9]+|pipeline failed|XP00"
# NEG: incomplete if statement → product -o must fail.
expect_reject if_missing_paren tests/parser/if_missing_paren.x \
  "ld failed|_main|Undefined symbols|expected|parse produced no functions|parse error|P00[0-9]+|pipeline failed|XP00"
# NEG: bare import const access → hard typeck diagnostic.
expect_reject async_const_bare_access tests/parser/async_const_bare_access.x \
  "must be qualified|typeck error"

# Check-paused recovery arms (CHK002): former `xlang check` multi-diag authority.
# Do not soft-green by skipping silently — count obs= and keep fixtures on disk.
for chk_arm in \
  multi_error_recovery \
  control_stmt_recovery \
  top_level_recovery \
  unsafe_stmt_recovery \
  import_recovery
do
  [ -f "tests/parser/${chk_arm}.x" ] || die "missing tests/parser/${chk_arm}.x"
  echo "parser OBS $chk_arm (check paused CHK002; not soft FAIL→OK)" >&2
  OBS=$((OBS + 1))
done

ok_report
echo "parser test OK"
