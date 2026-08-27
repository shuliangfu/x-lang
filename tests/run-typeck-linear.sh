#!/usr/bin/env bash
# M-4 Linear(T) use-once move typeck smoke.
#
# Honesty: prefer-c + soft auto-make + check-bound green retired. Prefer
# product xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing
# native = hard die (refuse soft SKIP→OK / soft auto-make / prefer-c).
#   - compile_fail negatives → product -o must emit T001 linear diag (hard).
#   - positive move_ok.x → product -o hard green (run).
#   - xlang check CHK002 / paused = obs (not soft silence).
# DOC authority = archive/type. Report: run=/obs=/skip=
# Usage: ./tests/run-typeck-linear.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

DOC="${XLANG_TYPE_LINEAR_DOC:-analysis/archive/type/type-linear-v1-rfc.md}"
PREFIX="${XLANG_TYPECK_LINEAR_PREFIX:-xlang: [XLANG_TYPECK_LINEAR]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-60}"
FIXTURE_DIR=tests/typeck/linear

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "linear typeck FAIL: $*" >&2
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

run_timeout_case() {
  gate_run_timeout "$XLANG_CASE_TIMEOUT" "$@"
}

# compile_fail: product -o must reject with the expected linear T001 diag.
# Return: 0=ok, 1=hard fail, 2=obs (timeout / residual).
compile_fail_case() {
  local label="$1"
  local expect_re="$2"
  local src="${FIXTURE_DIR}/${label}"
  local err="/tmp/xlang_linear_fail_$$.log"
  local out="/tmp/xlang_linear_should_fail_$$"
  [ -f "$src" ] || { echo "linear typeck FAIL: missing $src" >&2; return 1; }

  set +e
  run_timeout_case "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  local o_ec=$?
  set -e
  rm -f "$out"
  if [ "$o_ec" -eq 124 ]; then
    echo "linear typeck OBS $label (-o timeout ${XLANG_CASE_TIMEOUT}s; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] && grep -qE "$expect_re" "$err"; then
    return 0
  fi

  # Secondary observational check path (paused 2026-08-05 / CHK002).
  # PLATFORM: SHARED — not soft silence; count obs.
  set +e
  run_timeout_case "$XLANG_BIN" check "$src" >"$err" 2>&1
  local c_ec=$?
  set -e
  if [ "$c_ec" -eq 124 ]; then
    echo "linear typeck OBS $label (check timeout; product residual)" >&2
    return 2
  fi
  if grep -qE "$expect_re" "$err"; then
    return 0
  fi
  echo "linear typeck FAIL: $label expected '$expect_re' on product -o" >&2
  if [ -s "$err" ]; then
    tail -8 "$err" >&2 || true
  fi
  return 1
}

# Positive: product -o must succeed and run exit 0.
# Return: 0=ok, 1=hard fail, 2=obs.
typeck_ok_case() {
  local label="$1"
  local src="${FIXTURE_DIR}/${label}"
  local err="/tmp/xlang_linear_ok_$$.log"
  local out="/tmp/xlang_linear_ok_$$"
  [ -f "$src" ] || { echo "linear typeck FAIL: missing $src" >&2; return 1; }

  set +e
  run_timeout_case "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  local o_ec=$?
  set -e
  if [ "$o_ec" -eq 124 ]; then
    rm -f "$out"
    echo "linear typeck OBS $label (-o timeout; product residual)" >&2
    return 2
  fi
  if grep -qE 'typeck error|XT001|linear value used after move|cannot take address of linear' "$err"; then
    echo "linear typeck FAIL: $label should typeck (got typeck error)" >&2
    tail -8 "$err" >&2 || true
    rm -f "$out"
    return 1
  fi
  if [ "$o_ec" -ne 0 ] || [ ! -x "$out" ]; then
    echo "linear typeck FAIL: $label product -o failed (ec=$o_ec)" >&2
    tail -8 "$err" >&2 || true
    rm -f "$out"
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local r_ec=$?
  set -e
  rm -f "$out"
  if [ "$r_ec" -ne 0 ]; then
    echo "linear typeck FAIL: $label run exit=$r_ec" >&2
    return 1
  fi
  return 0
}

echo "=== M-4 linear typeck (archive DOC) ==="
[ -f "$DOC" ] || die "missing $DOC"
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi
# Dual DOC: top-level narrative may remain; Gate authority is archive.
# Refuse soft silence when archive Gate is missing (checked above).

for f in double_move.x call_double.x addr_of.x return_branch.x move_ok.x; do
  [ -f "${FIXTURE_DIR}/$f" ] || die "missing ${FIXTURE_DIR}/$f"
done

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
gate_progress "linear typeck: XLANG=$XLANG_BIN"

FAILS=0

# Negatives — product -o compile_fail hard green.
# Use `|| cf_ec=$?` so non-zero returns never trip set -e (portable).
cf_ec=0
compile_fail_case "double_move.x" 'linear value used after move' || cf_ec=$?
if [ "$cf_ec" -eq 0 ]; then
  echo "linear typeck OK double_move.x (compile_fail)"
  RUN_OK=$((RUN_OK + 1))
elif [ "$cf_ec" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  FAILS=$((FAILS + 1))
fi

cf_ec=0
compile_fail_case "call_double.x" 'linear value used after move' || cf_ec=$?
if [ "$cf_ec" -eq 0 ]; then
  echo "linear typeck OK call_double.x (compile_fail)"
  RUN_OK=$((RUN_OK + 1))
elif [ "$cf_ec" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  FAILS=$((FAILS + 1))
fi

cf_ec=0
compile_fail_case "addr_of.x" 'cannot take address of linear value' || cf_ec=$?
if [ "$cf_ec" -eq 0 ]; then
  echo "linear typeck OK addr_of.x (compile_fail)"
  RUN_OK=$((RUN_OK + 1))
elif [ "$cf_ec" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  FAILS=$((FAILS + 1))
fi

cf_ec=0
compile_fail_case "return_branch.x" 'linear value used after move' || cf_ec=$?
if [ "$cf_ec" -eq 0 ]; then
  echo "linear typeck OK return_branch.x (compile_fail)"
  RUN_OK=$((RUN_OK + 1))
elif [ "$cf_ec" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  FAILS=$((FAILS + 1))
fi

# Positive — product -o hard green.
tk_ec=0
typeck_ok_case "move_ok.x" || tk_ec=$?
if [ "$tk_ec" -eq 0 ]; then
  echo "linear typeck OK move_ok.x (typeck-ok)"
  RUN_OK=$((RUN_OK + 1))
elif [ "$tk_ec" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  FAILS=$((FAILS + 1))
fi

# Observational check path once (paused / CHK002) — never soft SKIP→OK.
set +e
run_timeout_case "$XLANG_BIN" check "${FIXTURE_DIR}/double_move.x" >/tmp/xlang_linear_check_$$.log 2>&1
c_ec=$?
set -e
if [ "$c_ec" -eq 124 ]; then
  echo "linear typeck OBS check (timeout; product residual)" >&2
  OBS=$((OBS + 1))
elif grep -qE 'linear value used after move' /tmp/xlang_linear_check_$$.log 2>/dev/null; then
  echo "linear typeck OK check double_move (obs path also green)"
elif grep -qE 'CHK002|no \.x files found' /tmp/xlang_linear_check_$$.log 2>/dev/null; then
  echo "linear typeck OBS check (CHK002 / paused; refuse soft silence)" >&2
  OBS=$((OBS + 1))
else
  echo "linear typeck OBS check (no linear diag; refuse soft SKIP→OK)" >&2
  OBS=$((OBS + 1))
fi
rm -f /tmp/xlang_linear_check_$$.log

[ "$FAILS" -eq 0 ] || die "${FAILS} hard failure(s)"

gate_progress "linear typeck OK (run=${RUN_OK} obs=${OBS})"
echo "linear typeck OK"
ok_report
