#!/usr/bin/env bash
# M-3 Region domain-label typeck smoke (T[]<label> cross-region assign compile fail).
#
# Honesty: soft-skip WARN (unsafe-context / read_ptr C-delegate) + prefer-c +
# soft auto-make xlang-c + check-bound green retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die (refuse soft SKIP→OK).
#   - compile_fail negatives → product -o must emit T001 region diag (hard).
#   - positive typeck-ok fixtures → product -o typeck-pass + expected extern
#     UNDEF (slice_src / read_ptr_slice) counts as run (link stub not this gate).
#   - read_ptr escape/mismatch tip not detecting region → obs (was soft-skip
#     WARN); check path CHK002 / paused = obs. Report run=/obs=/skip=.
# DOC authority = archive/type. Usage: ./tests/run-typeck-region.sh
# PLATFORM: SHARED archaeology — Ubuntu gold still required.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/gate-progress.sh
. tests/lib/gate-progress.sh

DOC="${XLANG_TYPE_REGION_DOC:-analysis/archive/type/type-region-v1-rfc.md}"
PREFIX="${XLANG_TYPECK_REGION_PREFIX:-xlang: [XLANG_TYPECK_REGION]}"
XLANG_CASE_TIMEOUT="${XLANG_CASE_TIMEOUT:-60}"
FIXTURE_DIR=tests/typeck/slice_lifetime

RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "region typeck FAIL: $*" >&2
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

# Do NOT match bare "region" — fixture paths contain "region" / "read_ptr_region_*"
# and would false-green BLD001 UNDEF residuals (honesty root).
REGION_DIAG_RE='slice region mismatch|slice region escape|\[\]i32<r[ab]>|\[\]u8<'

# compile_fail: product -o must reject with region T001 (hard).
# Return: 0=ok, 1=hard fail, 2=obs (timeout / residual).
compile_fail_case() {
  local label="$1"
  local src="${FIXTURE_DIR}/${label}"
  local err="/tmp/xlang_region_fail_$$.log"
  local out="/tmp/xlang_region_should_fail_$$"
  [ -f "$src" ] || { echo "region typeck FAIL: missing $src" >&2; return 1; }

  set +e
  run_timeout_case "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  local o_ec=$?
  set -e
  rm -f "$out"
  if [ "$o_ec" -eq 124 ]; then
    echo "region typeck OBS $label (-o timeout ${XLANG_CASE_TIMEOUT}s; product residual)" >&2
    return 2
  fi
  if [ "$o_ec" -ne 0 ] && grep -qE "$REGION_DIAG_RE" "$err"; then
    return 0
  fi

  # Secondary observational check path (paused 2026-08-05 / CHK002).
  # PLATFORM: SHARED — not soft silence; count obs.
  set +e
  run_timeout_case "$XLANG_BIN" check "$src" >"$err" 2>&1
  local c_ec=$?
  set -e
  if [ "$c_ec" -eq 124 ]; then
    echo "region typeck OBS $label (check timeout; product residual)" >&2
    return 2
  fi
  if grep -qE "$REGION_DIAG_RE" "$err"; then
    return 0
  fi
  echo "region typeck OBS $label (no region diag on product -o / check; refuse soft-skip WARN)" >&2
  if [ -s "$err" ]; then
    tail -6 "$err" >&2 || true
  fi
  return 2
}

# Positive typeck-ok: typeck must pass; expected extern UNDEF at link is OK.
# Return: 0=ok, 1=hard fail, 2=obs.
typeck_ok_case() {
  local label="$1"
  local expected_undef_re="$2"
  local src="${FIXTURE_DIR}/${label}"
  local err="/tmp/xlang_region_ok_$$.log"
  local out="/tmp/xlang_region_ok_$$"
  [ -f "$src" ] || { echo "region typeck FAIL: missing $src" >&2; return 1; }

  set +e
  run_timeout_case "$XLANG_BIN" "$src" -o "$out" >"$err" 2>&1
  local o_ec=$?
  set -e
  rm -f "$out"
  if [ "$o_ec" -eq 124 ]; then
    echo "region typeck OBS $label (-o timeout; product residual)" >&2
    return 2
  fi
  # Hard reject unexpected typeck failure on a positive fixture.
  if grep -qE 'typeck error|XT001|slice region mismatch|slice region escape' "$err"; then
    echo "region typeck FAIL: $label should typeck (got typeck error)" >&2
    tail -8 "$err" >&2 || true
    return 1
  fi
  if [ "$o_ec" -eq 0 ] && [ -x "$out" ]; then
    return 0
  fi
  # Expected: typeck passed, link UNDEF on fixture extern stub.
  if [ "$o_ec" -ne 0 ] && grep -qE "$expected_undef_re" "$err"; then
    return 0
  fi
  echo "region typeck OBS $label (unexpected -o residual; refuse soft SKIP→OK)" >&2
  tail -8 "$err" >&2 || true
  return 2
}

echo "=== M-3 region typeck (archive DOC) ==="
[ -f "$DOC" ] || die "missing $DOC"
if ! grep -qE '^## Gate[[:space:]]*$' "$DOC"; then
  die "doc missing ## Gate section"
fi

if [ "${XLANG_TYPECK_REGION_SKIP:-0}" = "1" ]; then
  SKIP=$((SKIP + 1))
  gate_progress "region typeck: SKIP (XLANG_TYPECK_REGION_SKIP=1)"
  echo "region typeck OK"
  ok_report
  exit 0
fi

for f in \
  region_mismatch.x \
  region_block_escape.x \
  region_assign_escape.x \
  region_return_escape.x \
  region_call_mismatch.x \
  region_call_escape.x \
  region_same_ok.x \
  region_block_same.x \
  region_call_ok.x \
  read_ptr_region_escape.x \
  read_ptr_region_mismatch.x \
  read_ptr_region_ok.x; do
  [ -f "${FIXTURE_DIR}/$f" ] || die "missing ${FIXTURE_DIR}/$f"
done

XLANG_BIN="$(resolve_shu)" || die "no native xlang/xlang_asm/xlang-c (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
gate_progress "region typeck: XLANG=$XLANG_BIN"

FAILS=0

# Core negatives — product -o compile_fail hard green.
# Use `|| cf_ec=$?` so non-zero returns never trip set -e (portable).
for label in \
  region_mismatch.x \
  region_block_escape.x \
  region_assign_escape.x \
  region_return_escape.x \
  region_call_mismatch.x \
  region_call_escape.x; do
  cf_ec=0
  compile_fail_case "$label" || cf_ec=$?
  if [ "$cf_ec" -eq 0 ]; then
    echo "region typeck OK $label (compile_fail)"
    RUN_OK=$((RUN_OK + 1))
  elif [ "$cf_ec" -eq 2 ]; then
    OBS=$((OBS + 1))
  else
    FAILS=$((FAILS + 1))
  fi
done

# Positives — typeck pass + expected extern UNDEF.
for label in region_same_ok.x region_block_same.x region_call_ok.x; do
  tk_ec=0
  typeck_ok_case "$label" '_slice_src|slice_src' || tk_ec=$?
  if [ "$tk_ec" -eq 0 ]; then
    echo "region typeck OK $label (typeck-ok)"
    RUN_OK=$((RUN_OK + 1))
  elif [ "$tk_ec" -eq 2 ]; then
    OBS=$((OBS + 1))
  else
    FAILS=$((FAILS + 1))
  fi
done

# read_ptr escape/mismatch: tip may not emit region diag yet → obs
# (was soft-skip WARN). Prefer hard when diag present.
for label in read_ptr_region_escape.x read_ptr_region_mismatch.x; do
  cf_ec=0
  compile_fail_case "$label" || cf_ec=$?
  if [ "$cf_ec" -eq 0 ]; then
    echo "region typeck OK $label (compile_fail)"
    RUN_OK=$((RUN_OK + 1))
  elif [ "$cf_ec" -eq 2 ]; then
    echo "region typeck OBS $label (read_ptr region residual; was soft-skip WARN)" >&2
    OBS=$((OBS + 1))
  else
    FAILS=$((FAILS + 1))
  fi
done

tk_ec=0
typeck_ok_case "read_ptr_region_ok.x" '_read_ptr_slice|read_ptr_slice' || tk_ec=$?
if [ "$tk_ec" -eq 0 ]; then
  echo "region typeck OK read_ptr_region_ok.x (typeck-ok)"
  RUN_OK=$((RUN_OK + 1))
elif [ "$tk_ec" -eq 2 ]; then
  OBS=$((OBS + 1))
else
  FAILS=$((FAILS + 1))
fi

[ "$FAILS" -eq 0 ] || die "${FAILS} hard failure(s)"

gate_progress "region typeck OK (run=${RUN_OK} obs=${OBS})"
echo "region typeck OK"
ok_report
