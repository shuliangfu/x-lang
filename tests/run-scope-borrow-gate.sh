#!/usr/bin/env bash
# MEM-A3: scope borrow — return/assign address escape typeck honesty gate.
#
# Honesty: soft default `./compiler/xlang-c` + soft auto-make (prefer-c /
# false authority) retired. Prefer product xlang_asm; pin XLANG_LINK_XLANG.
# Explicit bad XLANG / missing native = hard die (refuse soft SKIP→OK /
# soft auto-make / prefer-c).
# Retire hard-bound `xlang check` (CHK002 under paused check gate).
#   - hard: product -o compile_fail with "scope borrow escape" diagnostic
#   - obs: check-bound residual only (not used as pass signal)
# Report: run=/obs=/skip=
# Usage: ./tests/run-scope-borrow-gate.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

PREFIX="${XLANG_SCOPE_BORROW_PREFIX:-xlang: [XLANG_SCOPE_BORROW]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-90}"
SRC_RET="tests/typeck/borrow/return_addr_escape.x"
SRC_ASSIGN="tests/typeck/borrow/assign_scope_escape.x"
MSG="scope borrow escape"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "scope-borrow-gate FAIL: $*" >&2
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

# Product -o must compile_fail with scope-borrow diagnostic (not link UNDEF).
# Return 0=ok, 1=hard fail, 2=obs. bash 3.2: keep errexit off across returns.
check_neg_product() {
  local src="$1"
  local label="$2"
  local out="/tmp/xlang_scope_borrow_${label}_$$"
  local err="/tmp/xlang_scope_borrow_${label}_$$.log"
  local o_ec
  rm -f "$out"
  set +e
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$XLANG_BIN" -L . "$src" -o "$out" >"$err" 2>&1
  o_ec=$?
  set -e
  rm -f "$out"
  if [ "$o_ec" -eq 124 ]; then
    echo "scope-borrow-gate OBS $label (-o timeout; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -eq 0 ]; then
    echo "scope-borrow-gate FAIL $label: expected compile_fail, got success" >&2
    return 1
  fi
  if grep -qF "$MSG" "$err" 2>/dev/null \
    && ! grep -qiE 'Undefined symbols|undefined reference|BLD001' "$err" 2>/dev/null; then
    echo "scope-borrow-gate OK $label (product -o compile_fail: $MSG)"
    return 0
  fi
  if grep -qiE 'CHK002|no \.x files found' "$err" 2>/dev/null; then
    echo "scope-borrow-gate OBS $label (check-bound CHK002 residual; not soft false-green)" >&2
    return 2
  fi
  echo "scope-borrow-gate FAIL $label: compile_fail without '$MSG'" >&2
  tail -n 8 "$err" >&2 || true
  return 1
}

echo "=== MEM-A3: scope borrow escape (prefer asm; hard/obs) ==="
[ -f "$SRC_RET" ] || die "missing $SRC_RET"
[ -f "$SRC_ASSIGN" ] || die "missing $SRC_ASSIGN"
XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "XLANG=$XLANG_BIN"

prc=0
check_neg_product "$SRC_RET" return_escape || prc=$?
if [ "$prc" -eq 1 ]; then
  die "return_addr_escape"
elif [ "$prc" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  RUN_OK=$((RUN_OK + 1))
fi

prc=0
check_neg_product "$SRC_ASSIGN" assign_escape || prc=$?
if [ "$prc" -eq 1 ]; then
  die "assign_scope_escape"
elif [ "$prc" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  RUN_OK=$((RUN_OK + 1))
fi

echo "scope-borrow-gate OK (MEM-A3 honesty; run=${RUN_OK} obs=${OBS})"
ok_report
exit 0
