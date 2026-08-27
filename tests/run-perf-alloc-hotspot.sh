#!/usr/bin/env bash
# PERF-007: alloc hotspot strace bench — heap call counts vs baseline caps.
#
# Honesty: soft XLANG_ALLOC_HOTSPOT_FAIL:-0 previously left over-cap
# unchecked (silent OK = portable false-green). Soft SKIP→OK on missing
# native / prefer-xlang-c-only retired. Prefer product xlang_asm. Over-cap /
# compile-fail / exit-mismatch = obs (FAIL=1 still hard). Non-Linux / no
# strace = skip. Explicit bad XLANG = hard die. Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-alloc-hotspot.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-alloc-hotspot.sh
# Env:
#   XLANG_ALLOC_HOTSPOT_FAIL=1 — over-cap hard-fail
#   XLANG_ALLOC_HOTSPOT_REQUIRE_STRACE=1 — no strace = hard (CI Linux)
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin = skip, no strace).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-alloc-hotspot.sh
. tests/lib/perf-alloc-hotspot.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

BASELINE="${XLANG_ALLOC_HOTSPOT_BASELINE:-tests/baseline/alloc-hotspot-perf.tsv}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
FAIL_FLAG="${XLANG_ALLOC_HOTSPOT_FAIL:-0}"
REQUIRE_STRACE="${XLANG_ALLOC_HOTSPOT_REQUIRE_STRACE:-0}"
PREFIX="xlang: [XLANG_ALLOC_HOTSPOT]"
OBS=0
RUN_OK=0
SKIP=0
CASE_OK=0
CASE_TOTAL=0
CASE_OBS=0

die() {
  echo "alloc-hotspot FAIL: $*" >&2
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

echo "=== PERF-007: alloc hotspot strace bench (baseline=${BASELINE}) ==="

# PLATFORM: DARWIN / non-Linux — strace N/A; honest skip before soft OK.
if ! perf_ah_strace_probe_ok; then
  if [ "$REQUIRE_STRACE" = "1" ]; then
    die "strace unavailable (XLANG_ALLOC_HOTSPOT_REQUIRE_STRACE=1)"
  fi
  # Explicit bad XLANG still hard-dies even on N/A platforms.
  if [ -n "${XLANG:-}" ]; then
    resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "alloc-hotspot perf SKIP: need Linux + working strace"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "alloc-hotspot: resolve=$XLANG_BIN"

while IFS=$'\t' read -r case_id bench_src expect_exit cap_m cap_c cap_r _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))
  exe="${OUT_DIR}/xlang_alloc_hotspot_${case_id}"
  rm -f "$exe"

  if [ ! -f "$bench_src" ]; then
    echo "alloc-hotspot OBS: missing bench $bench_src ($case_id)" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  echo "── case ${case_id} (${bench_src}) ──"
  if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -L . "$bench_src" -o "$exe"; then
    echo "alloc-hotspot OBS: compile $bench_src" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  rc=0
  "$exe" >/dev/null 2>&1 || rc=$?
  if [ "$rc" != "$expect_exit" ]; then
    echo "alloc-hotspot OBS: $case_id exit=${rc} expect=${expect_exit}" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  strace_rc=0
  perf_ah_strace_heap_counts "$exe" "$expect_exit" || strace_rc=$?
  if [ "$strace_rc" -ne 0 ]; then
    echo "alloc-hotspot OBS: strace $case_id rc=${strace_rc}" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  ok=$(perf_ah_within_caps "$case_id" "$perf_ah_malloc" "$perf_ah_calloc" "$perf_ah_realloc" "$BASELINE")
  perf_ah_report_emit "$case_id" "$perf_ah_malloc" "$perf_ah_calloc" "$perf_ah_realloc" \
    "$cap_m" "$cap_c" "$cap_r" "$ok"

  if [ "$ok" = "1" ]; then
    echo "alloc-hotspot OK: $case_id malloc=${perf_ah_malloc} calloc=${perf_ah_calloc} realloc=${perf_ah_realloc}"
    CASE_OK=$((CASE_OK + 1))
    RUN_OK=1
  else
    echo "alloc-hotspot OBS: $case_id exceeds cap (malloc=${perf_ah_malloc}/${cap_m} calloc=${perf_ah_calloc}/${cap_c} realloc=${perf_ah_realloc}/${cap_r})" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    if [ "$FAIL_FLAG" = "1" ]; then
      die "$case_id exceeds cap (XLANG_ALLOC_HOTSPOT_FAIL=1)"
    fi
  fi
done < "$BASELINE"

if [ "$CASE_TOTAL" -eq 0 ]; then
  die "no cases in $BASELINE"
fi

echo "alloc-hotspot perf OK (cases=${CASE_OK}/${CASE_TOTAL} obs_cases=${CASE_OBS})"
ok_report
exit 0
