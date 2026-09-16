#!/usr/bin/env bash
# PERF-003: network concurrency vs Zig gate (accept + echo + mixed P99).
#
# Honesty: soft SKIP→OK when no native xlang / CI timeout retired as bare
# exit 0. Prefer product xlang_asm. Default FAIL_ON soft path reports obs
# via runner (opt-in XLANG_PERF_FAIL_ON_NET_*=1 still hard). CI non-Linux
# or timeout = skip=1 (honest N/A). Report run=/obs=/skip=.
#
# Usage: ./tests/run-perf-net-zig-gate.sh
# PLATFORM: SHARED archaeology (Ubuntu gold).
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh
# shellcheck source=tests/lib/dod-native-exe.sh
. tests/lib/dod-native-exe.sh
# shellcheck source=tests/lib/zig-baseline.sh
. tests/lib/zig-baseline.sh

PREFIX="xlang: [XLANG_PERF_NET_ZIG]"
RUN_OK=0
OBS=0
SKIP=0

die() {
  echo "perf-net-zig gate FAIL: $*" >&2
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

DOC="${XLANG_PERF_NET_ZIG_DOC:-analysis/archive/perf/perf-net-zig-v1.md}"

# Refuse resurrecting top-level DOC (archive is authority).
if [ -f analysis/perf-net-zig-v1.md ]; then
  die "refuse top-level analysis/perf-net-zig-v1.md (use archive/perf)"
fi

echo "=== PERF-003: net manifest ==="
# Resolve compiler first so explicit-bad XLANG hard-dies (refuse soft SKIP→OK).
XLANG_BIN="$(resolve_shu)" || die "no native xlang_asm/xlang-c/xlang (refuse soft SKIP→OK)"

for f in \
  "$DOC" \
  tests/baseline/net-perf.tsv \
  tests/baseline/net-perf-latency.tsv \
  bench/i03_net_echo_throughput.zig \
  bench/i04_net_mixed_conns_requests.c \
  bench/i04_net_mixed_conns_requests.zig \
  bench/i04_net_mixed_conns_requests.x \
  bench/i04_net_mixed_conns_requests_server.c; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -q '^## Gate$' "$DOC" 2>/dev/null; then
  die "doc missing ## Gate ($DOC)"
fi
zig_baseline_validate_tsv "$ZIG_BASELINE_TSV"
echo "net-perf manifest OK"

# CI non-Linux x86_64: shared-runner timing unreliable — skip=1 (honest N/A).
if [ -n "${CI:-}" ] && ! ci_is_linux_x64; then
  SKIP=1
  echo "perf-net-zig gate SKIP bench (CI non-Linux-x86_64; skip=1)"
  ok_report
  exit 0
fi

echo "=== PERF-003: network throughput vs Zig (echo + mixed + P99) ==="
chmod +x tests/run-perf-net.sh

NET_BENCH_CONNS="${XLANG_NET_BENCH_CONNS:-$([ -n "${CI:-}" ] && echo 256 || echo 256)}"
NET_UDP_PKTS="${XLANG_NET_UDP_PKTS:-$([ -n "${CI:-}" ] && echo 256 || echo 256)}"
# Light default for archaeology honesty; override for full P1.
NET_RUNS="${XLANG_NET_RUNS:-1}"

run_net_bench() {
  env XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
    XLANG_PERF_FAIL_ON_NET_ZIG="${XLANG_PERF_FAIL_ON_NET_ZIG:-0}" \
    XLANG_PERF_FAIL_ON_NET_REGRESSION="${XLANG_PERF_FAIL_ON_NET_REGRESSION:-0}" \
    XLANG_PERF_FAIL_ON_NET_P99="${XLANG_PERF_FAIL_ON_NET_P99:-0}" \
    XLANG_NET_BENCH_CONNS="$NET_BENCH_CONNS" \
    XLANG_NET_UDP_PKTS="$NET_UDP_PKTS" \
    XLANG_NET_RUNS="$NET_RUNS" \
    ./tests/run-perf-net.sh --bench
}

set +e
if [ -n "${CI:-}" ] && ci_is_linux_x64 && command -v timeout >/dev/null 2>&1; then
  out="$(
    timeout 180 env XLANG="$XLANG_BIN" XLANG_LINK_XLANG="$XLANG_BIN" \
      XLANG_PERF_FAIL_ON_NET_ZIG="${XLANG_PERF_FAIL_ON_NET_ZIG:-0}" \
      XLANG_PERF_FAIL_ON_NET_REGRESSION="${XLANG_PERF_FAIL_ON_NET_REGRESSION:-0}" \
      XLANG_PERF_FAIL_ON_NET_P99="${XLANG_PERF_FAIL_ON_NET_P99:-0}" \
      XLANG_NET_BENCH_CONNS="$NET_BENCH_CONNS" \
      XLANG_NET_UDP_PKTS="$NET_UDP_PKTS" \
      XLANG_NET_RUNS="$NET_RUNS" \
      ./tests/run-perf-net.sh --bench 2>&1
  )"
  bench_ec=$?
else
  out="$(run_net_bench 2>&1)"
  bench_ec=$?
fi
set -e
printf '%s\n' "$out"
if [ "${bench_ec:-0}" -eq 124 ]; then
  SKIP=1
  echo "perf-net-zig gate SKIP bench (CI timeout 180s; skip=1)"
  ok_report
  exit 0
fi
if [ "$bench_ec" -ne 0 ]; then
  die "run-perf-net --bench rc=$bench_ec"
fi
RUN_OK=1
if echo "$out" | grep -qE 'OBS:|obs=[1-9]'; then
  OBS=1
fi
echo "perf-net-zig gate OK"
ok_report
exit 0
