#!/usr/bin/env bash
# PERF-002：IO 吞吐对标 Zig 门禁（顺序 + 随机）
#
# 检查：
#   1) Shu median ≤ Zig -O2（SHUX_PERF_FAIL_ON_IO_ZIG=1）
#   2) Shu median ≤ tests/baseline/io-perf.tsv（SHUX_PERF_FAIL_ON_IO_REGRESSION=1）
#
# 用法：./tests/run-perf-io-zig-gate.sh
set -e
cd "$(dirname "$0")/.."

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

SHUX_BIN="${SHUX:-}"
if [ -z "$SHUX_BIN" ]; then
  for cand in ./compiler/shux-c ./compiler/shux; do
    if native_shu "$cand"; then
      SHUX_BIN="$cand"
      break
    fi
  done
fi

if [ -z "$SHUX_BIN" ]; then
  echo "perf-io-zig gate SKIP (no native shux; run in Docker/Linux)" >&2
  exit 0
fi

echo "=== PERF-002: IO throughput vs Zig (sequential + random) ==="
chmod +x tests/run-perf-io.sh
SHUX="$SHUX_BIN" \
  SHUX_PERF_FAIL_ON_IO_ZIG=1 \
  SHUX_PERF_FAIL_ON_IO_REGRESSION=1 \
  ./tests/run-perf-io.sh --bench

echo "perf-io-zig gate OK"
