#!/usr/bin/env bash
# PERF-003：网络并发对标 Zig 门禁（连接 accept + echo 吞吐 + mixed P99）
#
# 检查：
#   1) Shu client median ≤ Zig -O2（SHU_PERF_FAIL_ON_NET_ZIG=1）
#   2) Shu median ≤ tests/baseline/net-perf.tsv（SHU_PERF_FAIL_ON_NET_REGRESSION=1）
#   3) mixed P99 ≤ tests/baseline/net-perf-latency.tsv（SHU_PERF_FAIL_ON_NET_P99=1）
#
# 用法：./tests/run-perf-net-zig-gate.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/zig-baseline.sh
. "$(dirname "$0")/lib/zig-baseline.sh"

native_shu() {
  local f="$1"
  [ -n "$f" ] && [ -x "$f" ] || return 1
  case "$(uname -s)-$(uname -m 2>/dev/null)" in
    Darwin-arm64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*arm64' ;;
    Darwin-x86_64) file "$f" 2>/dev/null | grep -qE 'Mach-O.*x86_64' ;;
    Linux-x86_64|Linux-amd64) file "$f" 2>/dev/null | grep -qE 'ELF.*x86-64' ;;
    Linux-aarch64|Linux-arm64) file "$f" 2>/dev/null | grep -qE 'ELF.*aarch64|ELF.*ARM' ;;
    *) return 0 ;;
  esac
}

echo "=== PERF-003: net manifest ==="
for f in \
  analysis/perf-net-zig-v1.md \
  tests/baseline/net-perf.tsv \
  tests/baseline/net-perf-latency.tsv \
  tests/bench/net_echo_throughput.zig \
  tests/bench/net_mixed_conns_requests.c \
  tests/bench/net_mixed_conns_requests.zig \
  tests/bench/net_mixed_conns_requests.su \
  tests/bench/net_mixed_conns_requests_server.c; do
  if [ ! -f "$f" ]; then
    echo "perf-net-zig gate FAIL: missing $f" >&2
    exit 1
  fi
done
zig_baseline_validate_tsv "$ZIG_BASELINE_TSV"
echo "net-perf manifest OK"

SHU_BIN="${SHU:-}"
if [ -z "$SHU_BIN" ]; then
  for cand in ./compiler/shu-c ./compiler/shu; do
    if native_shu "$cand"; then
      SHU_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHU_BIN" ]; then
  echo "perf-net-zig gate SKIP bench (no native shu; run in Docker/Linux)" >&2
  exit 0
fi

echo "=== PERF-003: network throughput vs Zig (echo + mixed + P99) ==="
chmod +x tests/run-perf-net.sh
SHU="$SHU_BIN" \
  SHU_PERF_FAIL_ON_NET_ZIG=1 \
  SHU_PERF_FAIL_ON_NET_REGRESSION=1 \
  SHU_PERF_FAIL_ON_NET_P99=1 \
  ./tests/run-perf-net.sh --bench

echo "perf-net-zig gate OK"
