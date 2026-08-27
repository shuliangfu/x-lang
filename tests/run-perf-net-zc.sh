#!/usr/bin/env bash
# PERF-009: net zero-copy cycles/MiB bench vs baseline / ref.
#
# Honesty: soft XLANG_NET_ZC_FAIL:-0 previously left over-cap / zc≥ref
# unchecked (silent OK = portable false-green). Soft SKIP→OK on missing
# native / prefer-xlang-c-only / soft auto-make retired. Prefer product
# xlang_asm. Over-cap / zc≥ref / compile-fail = obs (FAIL=1 still hard).
# Non-Linux / no perf = skip. Explicit bad XLANG = hard die.
# Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-net-zc.sh
#   XLANG=./compiler/xlang_asm ./tests/run-perf-net-zc.sh
# Env:
#   XLANG_NET_ZC_FAIL=1 — over-cap / zc≥ref hard-fail
#   XLANG_NET_ZC_REQUIRE_PERF=1 — no perf = hard (CI Linux)
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin = skip, no perf).
# Note: zc3/zc4/zc5 host-c binding remains deferred (tip residual).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/perf-net-zc.sh
. tests/lib/perf-net-zc.sh
# shellcheck source=tests/lib/io-uring-probe.sh
. tests/lib/io-uring-probe.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# Honesty: do NOT auto-make before resolve.

BASELINE="${XLANG_NET_ZC_BASELINE:-tests/baseline/net-zc-perf.tsv}"
OUT_DIR="${TESTS_OUT_DIR:-tests/.out}"
mkdir -p "$OUT_DIR"
FAIL_FLAG="${XLANG_NET_ZC_FAIL:-0}"
REQUIRE_PERF="${XLANG_NET_ZC_REQUIRE_PERF:-0}"
PREFIX="xlang: [XLANG_NET_ZC]"
OBS=0
RUN_OK=0
SKIP=0
CASE_OK=0
CASE_TOTAL=0
CASE_OBS=0
CASE_SKIP=0

die() {
  echo "net-zc FAIL: $*" >&2
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

pick_free_port() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()'
  else
    echo $((38500 + RANDOM % 2000))
  fi
}

echo "=== PERF-009: net zero-copy cycles/byte bench (baseline=${BASELINE}) ==="

# PLATFORM: DARWIN / non-Linux — perf N/A; honest skip.
if ! perf_nz_probe_ok; then
  if [ "$REQUIRE_PERF" = "1" ]; then
    die "perf unavailable (XLANG_NET_ZC_REQUIRE_PERF=1)"
  fi
  if [ -n "${XLANG:-}" ]; then
    resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "net-zc perf SKIP: need Linux + perf stat cycles"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "net-zc: resolve=$XLANG_BIN"

declare -A NZ_CYCLES NZ_CPM

# Pass 1: compile + perf stat.
while IFS=$'\t' read -r case_id bench_src server_c bytes_xfer _cap_mib _ref_case needs_uring _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))

  if [ "$needs_uring" = "1" ] && ! io_uring_available; then
    echo "net-zc SKIP case ${case_id} (io_uring N/A)"
    CASE_SKIP=$((CASE_SKIP + 1))
    SKIP=1
    continue
  fi

  if [ ! -f "$bench_src" ]; then
    echo "net-zc OBS: missing bench $bench_src ($case_id)" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi
  if [ ! -f "$server_c" ]; then
    echo "net-zc OBS: missing server $server_c ($case_id)" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  exe="${OUT_DIR}/xlang_net_zc_${case_id}"
  rm -f "$exe"
  echo "── measure ${case_id} ──"
  if ! "$XLANG_BIN" -L . "$bench_src" -o "$exe"; then
    echo "net-zc OBS: compile $bench_src" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  port=$(pick_free_port)
  if ! perf_nz_run_echo_cycles "$exe" "$server_c" "$port"; then
    echo "net-zc OBS: perf stat $case_id" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  cpm=$(perf_nz_cycles_per_mib "$perf_nz_cycles" "$bytes_xfer")
  NZ_CYCLES[$case_id]="$perf_nz_cycles"
  NZ_CPM[$case_id]="$cpm"
  echo "net-zc measure: $case_id cycles=${perf_nz_cycles} cycles_per_mib=${cpm}"
done < "$BASELINE"

# Pass 2: cap + zc_lt_ref + emit.
while IFS=$'\t' read -r case_id _x _srv bytes_xfer cap_mib ref_case needs_uring _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  [ -n "${NZ_CPM[$case_id]:-}" ] || continue

  cpm="${NZ_CPM[$case_id]}"
  ok=$(perf_nz_within_cap "$case_id" "$cpm" "$BASELINE")

  ref_cpm="-"
  if [ -n "$ref_case" ] && [ "$ref_case" != "-" ] && [ -n "${NZ_CPM[$ref_case]:-}" ]; then
    ref_cpm="${NZ_CPM[$ref_case]}"
    if awk -v z="$cpm" -v r="$ref_cpm" 'BEGIN { exit (z + 0 < r + 0) ? 0 : 1 }'; then
      :
    else
      ok=0
      echo "net-zc OBS: $case_id cycles_per_mib=${cpm} >= ref ${ref_case}=${ref_cpm}" >&2
    fi
  fi

  perf_nz_report_emit "$case_id" "${NZ_CYCLES[$case_id]}" "$bytes_xfer" "$cpm" \
    "$cap_mib" "${ref_case:--}" "$ref_cpm" "$ok"

  if [ "$ok" = "1" ]; then
    echo "net-zc OK: $case_id cycles_per_mib=${cpm} ref=${ref_cpm}"
    CASE_OK=$((CASE_OK + 1))
    RUN_OK=1
  else
    echo "net-zc OBS: $case_id over-cap or zc≥ref (cpm=${cpm} cap=${cap_mib})" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    if [ "$FAIL_FLAG" = "1" ]; then
      die "$case_id over-cap or zc≥ref (XLANG_NET_ZC_FAIL=1)"
    fi
  fi
done < "$BASELINE"

if [ "$CASE_TOTAL" -eq 0 ]; then
  die "no cases in $BASELINE"
fi

echo "net-zc perf OK (cases=${CASE_OK}/${CASE_TOTAL} obs_cases=${CASE_OBS} skip_cases=${CASE_SKIP})"
ok_report
exit 0
