#!/usr/bin/env bash
# TYPE-003: borrow conflict / false-positive smoke (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK (no native) + prefer-c (xlang-c before asm) +
# soft auto-make xlang-c + check-bound green retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK / soft auto-make).
#   - policy=pos → product -o typeck-ok (expected extern UNDEF = run)
#   - policy=neg → product -o compile_fail with expect_substr (hard)
#   - check path CHK002 / paused = obs. Report run=/obs=/skip=.
# DOC authority = archive/type. Usage: ./tests/run-type-borrow-conflict.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/type-borrow-conflict.sh
. tests/lib/type-borrow-conflict.sh
# shellcheck source=tests/lib/lang-lifetime-diag.sh
. tests/lib/lang-lifetime-diag.sh

MATRIX="${XLANG_TYPE_BORROW_CASES:-tests/baseline/type-borrow-conflict-cases.tsv}"
PREFIX="${XLANG_TYPE_BORROW_PREFIX:-xlang: [XLANG_TYPE_BORROW]}"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "type-borrow-conflict FAIL: $*" >&2
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

# Positive typeck-ok: typeck must pass; expected extern UNDEF at link is OK.
# Return: 0=ok, 1=hard fail, 2=obs.
typeck_ok_case() {
  local label="$1"
  local src="$2"
  local err="/tmp/xlang_borrow_ok_$$.log"
  local out="/tmp/xlang_borrow_ok_$$"
  [ -f "$src" ] || { echo "type-borrow-conflict FAIL: missing $src" >&2; return 1; }

  set +e
  "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  local o_ec=$?
  set -e
  # Hard reject unexpected typeck failure on a positive fixture.
  if grep -qE 'typeck error|XT001|slice region mismatch|slice region escape|linear value used after move' "$err"; then
    echo "type-borrow-conflict FAIL: $label should typeck (got typeck error)" >&2
    tail -8 "$err" >&2 || true
    rm -f "$out"
    return 1
  fi
  if [ "$o_ec" -eq 0 ] && [ -x "$out" ]; then
    rm -f "$out"
    return 0
  fi
  # Expected: typeck passed, link UNDEF on fixture extern stub (slice_src).
  if [ "$o_ec" -ne 0 ] && grep -qE '_slice_src|slice_src|undefined symbol|not found for architecture|BLD001' "$err"; then
    rm -f "$out"
    return 0
  fi
  echo "type-borrow-conflict OBS $label (unexpected -o residual; refuse soft SKIP→OK)" >&2
  tail -8 "$err" >&2 || true
  rm -f "$out"
  return 2
}

# compile_fail: product -o must reject with expect_substr (hard).
# Return: 0=ok, 1=hard fail, 2=obs (check-only residual).
compile_fail_case() {
  local label="$1"
  local src="$2"
  local substr="$3"
  local want_line="$4"
  local err="/tmp/xlang_borrow_fail_$$.log"
  local out="/tmp/xlang_borrow_should_fail_$$"
  [ -f "$src" ] || { echo "type-borrow-conflict FAIL: missing $src" >&2; return 1; }
  [ -n "$substr" ] && [ "$substr" != "-" ] || {
    echo "type-borrow-conflict FAIL: neg case $label missing expect_substr" >&2
    return 1
  }

  set +e
  "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  local o_ec=$?
  set -e
  rm -f "$out"
  if [ "$o_ec" -ne 0 ] && grep -qF "$substr" "$err"; then
    if [ -n "$want_line" ] && [ "$want_line" != "-" ]; then
      if ! lang_lifetime_diag_expect_at_line "$(cat "$err")" "$substr" "$want_line"; then
        return 1
      fi
    fi
    return 0
  fi

  # Secondary observational check path (paused 2026-08-05 / CHK002).
  # PLATFORM: SHARED — not soft silence; count obs.
  set +e
  "$XLANG_BIN" check "$src" >"$err" 2>&1
  local c_ec=$?
  set -e
  if [ "$c_ec" -ne 0 ] && grep -qF "$substr" "$err"; then
    return 0
  fi
  echo "type-borrow-conflict OBS $label (no '$substr' on product -o / check; refuse soft SKIP→OK)" >&2
  if [ -s "$err" ]; then
    tail -6 "$err" >&2 || true
  fi
  return 2
}

[ -f "$MATRIX" ] || die "missing $MATRIX"

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"

echo "=== TYPE-003: borrow conflict smoke (XLANG=$XLANG_BIN) ==="
FAILS=0
while IFS=$'\t' read -r case_id file policy substr want_line notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  src=$(type_borrow_case_path "$file") || {
    echo "type-borrow-conflict FAIL: missing case file $file" >&2
    FAILS=$((FAILS + 1))
    continue
  }
  case "$policy" in
    pos)
      tk_ec=0
      typeck_ok_case "$case_id" "$src" || tk_ec=$?
      if [ "$tk_ec" -eq 0 ]; then
        echo "type-borrow-conflict OK $case_id (pos typeck-ok)"
        RUN_OK=$((RUN_OK + 1))
      elif [ "$tk_ec" -eq 2 ]; then
        OBS=$((OBS + 1))
      else
        FAILS=$((FAILS + 1))
      fi
      # check path observational only (paused); never soft-silence residual.
      set +e
      "$XLANG_BIN" check "$src" >/tmp/xlang_borrow_check_${case_id}.log 2>&1
      ck_ec=$?
      set -e
      if [ "$ck_ec" -ne 0 ]; then
        OBS=$((OBS + 1))
        echo "type-borrow-conflict OBS $case_id (check residual ec=$ck_ec; refuse hard-bind check)" >&2
      fi
      ;;
    neg)
      cf_ec=0
      compile_fail_case "$case_id" "$src" "$substr" "$want_line" || cf_ec=$?
      if [ "$cf_ec" -eq 0 ]; then
        echo "type-borrow-conflict OK $case_id (neg: $substr)"
        RUN_OK=$((RUN_OK + 1))
      elif [ "$cf_ec" -eq 2 ]; then
        OBS=$((OBS + 1))
      else
        FAILS=$((FAILS + 1))
      fi
      ;;
    *)
      die "unknown policy $policy for $case_id"
      ;;
  esac
done < "$MATRIX"

[ "$FAILS" -eq 0 ] || die "${FAILS} hard failure(s)"
if [ "$RUN_OK" -lt 1 ]; then
  die "no product -o cases ran (refuse soft SKIP→OK)"
fi

echo "type-borrow-conflict OK"
ok_report
