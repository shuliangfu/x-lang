#!/usr/bin/env bash
# PERF-011: Zig strategy dashboard — Xlang/Zig median, sparkline, optional --record.
#
# Honesty: soft XLANG_ZIG_STRATEGY_FAIL:-0 previously left microbench behind
# unchecked (silent OK = portable false-green). Soft SKIP→OK on missing
# native / soft auto-make / prefer-xlang-c-only / fossil bench paths retired.
# Prefer product xlang_asm. Microbench behind / compile-fail / nan = obs
# (FAIL=1 still hard). No zig = skip. Explicit bad XLANG = hard die.
# Report run=/obs=/skip=.
#
# Usage:
#   ./tests/run-perf-zig-strategy-dashboard.sh
#   ./tests/run-perf-zig-strategy-dashboard.sh --record
#   XLANG_ZIG_STRATEGY_RECORD=1 ./tests/run-perf-zig-strategy-dashboard.sh --record
# Env:
#   XLANG_ZIG_STRATEGY_FAIL=1 — microbench behind hard-fail
# PLATFORM: SHARED archaeology (Ubuntu gold; Darwin L2 same rules when zig present).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/zig-baseline.sh
. tests/lib/zig-baseline.sh
# shellcheck source=tests/lib/zig-strategy-dashboard.sh
. tests/lib/zig-strategy-dashboard.sh
# Honesty: do NOT auto-make before resolve.

CASES="${XLANG_ZIG_STRATEGY_CASES:-tests/baseline/zig-strategy-cases.tsv}"
HISTORY="${XLANG_ZIG_STRATEGY_HISTORY:-tests/baseline/zig-strategy-history.tsv}"
BENCH_ROOT="bench"
RUNS="$(zig_baseline_meta_get runs)"
[ -n "$RUNS" ] || RUNS=3
FAIL_FLAG="${XLANG_ZIG_STRATEGY_FAIL:-0}"
DO_RECORD=0
PREFIX="xlang: [XLANG_ZIG_STRATEGY]"
OBS=0
RUN_OK=0
SKIP=0
CASE_OK=0
CASE_TOTAL=0
CASE_OBS=0

for arg in "$@"; do
  case "$arg" in
    --record) DO_RECORD=1 ;;
  esac
done
[ "${XLANG_ZIG_STRATEGY_RECORD:-0}" = "1" ] && DO_RECORD=1

die() {
  echo "zig-strategy FAIL: $*" >&2
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
    echo $((38600 + RANDOM % 2000))
  fi
}

# Run C echo server + client once.
zsd_run_net_echo_client() {
  local client="$1"
  local port="$2"
  local srv spid rc
  srv="$(mktemp /tmp/xlang_zsd_echo_srv.XXXXXX)"
  # PLATFORM: SHARED — server remapped with i03_ bench id.
  if ! cc -O2 bench/i03_net_echo_throughput_server.c -o "$srv" 2>/dev/null; then
    return 1
  fi
  "$srv" "$port" >/dev/null 2>&1 &
  spid=$!
  sleep 0.15
  rc=0
  "$client" "$port" >/dev/null 2>&1 || rc=$?
  kill "$spid" 2>/dev/null || true
  wait "$spid" 2>/dev/null || true
  rm -f "$srv"
  return "$rc"
}

zsd_median_net_client() {
  local client="$1"
  local runs="$2"
  local i vals med port
  vals=""
  [ -x "$client" ] || { echo "nan"; return; }
  for i in $(seq 1 "$runs"); do
    port=$(pick_free_port)
    vals=$( ( time zsd_run_net_echo_client "$client" "$port" >/dev/null ) 2>&1 \
      | zig_baseline_extract_real_sec; printf '\n%s' "$vals" )
  done
  med=$(printf '%s\n' "$vals" | sed '/^$/d' | sort -n | awk '{
    a[NR]=$1
  } END {
    if (NR==0) { print "nan"; exit }
    if (NR%2) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2
  }')
  echo "$med"
}

zsd_ensure_io_bench_file() {
  local f="bench/.io_mmap_bench_tmp"
  local mb="${XLANG_IO_BENCH_MB:-16}"
  if [ ! -f "$f" ]; then
    dd if=/dev/zero of="$f" bs=1M count="$mb" status=none 2>/dev/null || \
      dd if=/dev/zero of="$f" bs=1048576 count="$mb" 2>/dev/null || return 1
  fi
}

echo "=== PERF-011: Zig strategy dashboard ==="
zig_baseline_host_summary

if ! command -v zig >/dev/null 2>&1; then
  if [ -n "${XLANG:-}" ]; then
    resolve_shu >/dev/null || die "XLANG=${XLANG} not native (refuse soft SKIP→OK)"
  fi
  SKIP=1
  echo "zig-strategy dashboard SKIP: no zig"
  ok_report
  exit 0
fi

XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK / soft auto-make)"
export XLANG="$XLANG_BIN"
export XLANG_LINK_XLANG="$XLANG_BIN"
echo "zig-strategy: resolve=$XLANG_BIN"

MONTH="$(zsd_current_month)"
zsd_print_dashboard_header

while IFS=$'\t' read -r case_id category su_src zig_src target_pct notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*) continue ;; esac
  CASE_TOTAL=$((CASE_TOTAL + 1))

  su_path="${BENCH_ROOT}/${su_src}"
  zig_path="${BENCH_ROOT}/${zig_src}"
  if [ ! -f "$su_path" ] || [ ! -f "$zig_path" ]; then
    echo "zig-strategy OBS: $case_id missing bench source ($su_path / $zig_path)" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    continue
  fi

  if [ "$category" = "io" ]; then
    if ! zsd_ensure_io_bench_file; then
      echo "zig-strategy OBS: $case_id io bench file" >&2
      CASE_OBS=$((CASE_OBS + 1))
      OBS=1
      continue
    fi
  fi

  tag="zsd_${case_id}"
  xlang_out="/tmp/${tag}_shu"
  zig_out="/tmp/${tag}_zig"
  rm -f "$xlang_out" "$zig_out"

  XLANG_MED="nan"
  ZIG_MED="nan"

  if [ "$category" = "net" ]; then
    if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -L . "$su_path" -o "$xlang_out" 2>/dev/null \
      || ! zig_build_exe_o2 "$zig_path" "$zig_out"; then
      echo "zig-strategy OBS: $case_id compile (net)" >&2
      CASE_OBS=$((CASE_OBS + 1))
      OBS=1
      continue
    fi
    XLANG_MED=$(zsd_median_net_client "$xlang_out" "$RUNS")
    ZIG_MED=$(zsd_median_net_client "$zig_out" "$RUNS")
  else
    if ! XLANG="$XLANG_BIN" "$XLANG_BIN" -O2 "$su_path" -o "$xlang_out" 2>/dev/null; then
      echo "zig-strategy OBS: $case_id xlang compile" >&2
      CASE_OBS=$((CASE_OBS + 1))
      OBS=1
      continue
    fi
    if ! zig_build_exe_o2 "$zig_path" "$zig_out"; then
      echo "zig-strategy OBS: $case_id zig compile" >&2
      CASE_OBS=$((CASE_OBS + 1))
      OBS=1
      continue
    fi
    XLANG_MED=$(zig_baseline_median_real "$xlang_out" "$RUNS")
    ZIG_MED=$(zig_baseline_median_real "$zig_out" "$RUNS")
  fi

  AHEAD=$(zsd_ahead_pct "$XLANG_MED" "$ZIG_MED")
  STATUS=$(zsd_status "$AHEAD" "$target_pct")
  TREND=$(zsd_sparkline "$case_id" "$HISTORY")

  zsd_report_emit "$case_id" "$XLANG_MED" "$ZIG_MED" "$AHEAD" "$target_pct" "$STATUS" "$TREND"
  zsd_print_dashboard_row "$case_id" "$XLANG_MED" "$ZIG_MED" "$AHEAD" "$TREND" "$STATUS"

  if [ "$STATUS" = "ahead" ]; then
    CASE_OK=$((CASE_OK + 1))
    RUN_OK=1
  elif [ "$AHEAD" = "nan" ]; then
    echo "zig-strategy OBS: $case_id ahead=nan" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
  elif [ "$STATUS" = "behind" ] && [ "$category" = "microbench" ]; then
    echo "zig-strategy OBS: $case_id microbench behind (ahead=${AHEAD}% target=${target_pct})" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
    if [ "$FAIL_FLAG" = "1" ]; then
      die "$case_id microbench behind (XLANG_ZIG_STRATEGY_FAIL=1)"
    fi
  elif [ "$STATUS" = "behind" ]; then
    # IO/NET behind = product obs (not silent OK).
    echo "zig-strategy OBS: $case_id ${category} behind (ahead=${AHEAD}% target=${target_pct})" >&2
    CASE_OBS=$((CASE_OBS + 1))
    OBS=1
  fi

  if [ "$DO_RECORD" = "1" ] && [ "$AHEAD" != "nan" ]; then
    zsd_append_history "$MONTH" "$case_id" "$XLANG_MED" "$ZIG_MED" "$AHEAD" "$HISTORY"
    echo "zig-strategy RECORD: $MONTH $case_id ahead=${AHEAD}%"
  fi
done < "$CASES"

if [ "$CASE_TOTAL" -eq 0 ]; then
  die "no cases in $CASES"
fi

printf '\n'
echo "zig-strategy history months=$(zsd_history_months "$HISTORY") cases_run=${CASE_TOTAL} ahead_ok=${CASE_OK} obs_cases=${CASE_OBS}"
ok_report
echo "zig-strategy dashboard OK"
