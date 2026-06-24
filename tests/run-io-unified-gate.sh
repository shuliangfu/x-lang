#!/usr/bin/env bash
# run-io-unified-gate.sh — 统一 IO 后端门禁（Tier P + Tier B）。
#
# 同一套 .sx 源码在全平台验证 std.io 批量读写；Linux 额外探测 io_uring ZC-1/multishot（无则 N/A）。
# Windows 上 .sx 批量路径即 IOCP；可选 --perf 追加平台 perf（Linux ZC-1 / Windows IOCP pipe）。
#
# 用法：
#   ./tests/run-io-unified-gate.sh           # smoke（全平台必过部分）
#   ./tests/run-io-unified-gate.sh --perf    # smoke + 平台 perf 子集
set -e
cd "$(dirname "$0")/.."

DO_PERF=0
for arg in "$@"; do
  case "$arg" in
    --perf) DO_PERF=1 ;;
    -h|--help)
      echo "Usage: $0 [--perf]"
      exit 0
      ;;
    *)
      echo "run-io-unified-gate: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"

make -C compiler -q 2>/dev/null || make -C compiler
# F-03 v2/v3：io 已纯 .sx，不再 build ../std/io/io.o
make -C compiler ../std/process/process.o -q 2>/dev/null \
  || make -C compiler ../std/process/process.o

if [ -z "${SHUX:-}" ]; then
  if [ -x ./compiler/shux-c ]; then
    SHUX=./compiler/shux-c
  elif [ -x ./compiler/shux ]; then
    SHUX=./compiler/shux
  else
    echo "run-io-unified-gate FAIL: no compiler" >&2
    exit 1
  fi
fi

# Linux 链 io.o 时编译器 invoke_cc 自动加 -luring（见 compiler/Makefile）。
rm -f tests/bench/.io_batch_rw_smoke_tmp

echo "=== IO unified: batch_rw_smoke.sx ($(ci_host_summary)) ==="
$RUN_SHUX -L . tests/io/batch_rw_smoke.sx -o /tmp/shux_io_batch_rw_smoke 2>&1
ec=0
/tmp/shux_io_batch_rw_smoke || ec=$?
rm -f tests/bench/.io_batch_rw_smoke_tmp
if [ "$ec" -ne 0 ]; then
  echo "run-io-unified-gate FAIL: batch_rw_smoke exit=$ec" >&2
  exit 1
fi
echo "io batch_rw_smoke OK"

echo "=== IO unified: read_ptr_slice (M-5) ==="
chmod +x tests/run-io-read-ptr-slice.sh
SHUX="$RUN_SHUX" ./tests/run-io-read-ptr-slice.sh

echo "=== IO unified: std.io smoke (run-io.sh) ==="
chmod +x tests/run-io.sh
SHUX="$RUN_SHUX" ./tests/run-io.sh

# Tier B：Linux io_uring 专有能力（无内核支持则 N/A exit 0）。
if ci_is_linux; then
  echo "=== IO unified: ZC-1 provided buffers (Linux) ==="
  chmod +x tests/run-provided-buffers.sh tests/lib/io-uring-probe.sh
  ./tests/run-provided-buffers.sh | tee /tmp/io_unified_zc1.log
  if grep -q "provided buffers smoke FAIL" /tmp/io_unified_zc1.log; then
    echo "run-io-unified-gate FAIL: provided buffers smoke" >&2
    exit 1
  fi
  if grep -q "provided buffers smoke OK" /tmp/io_unified_zc1.log; then
    echo "io provided buffers OK"
  else
    echo "io provided buffers N/A ($(ci_host_summary))"
  fi

  echo "=== IO unified: multishot accept (Linux) ==="
  chmod +x tests/run-io-multishot.sh
  ./tests/run-io-multishot.sh | tee /tmp/io_unified_multishot.log
  if grep -q "io multishot FAIL" /tmp/io_unified_multishot.log; then
    echo "run-io-unified-gate FAIL: multishot" >&2
    exit 1
  fi
  grep -qE 'io multishot accept OK|io multishot: N/A' /tmp/io_unified_multishot.log
else
  echo "io ZC-1/multishot N/A ($(ci_host_summary): io_uring requires Linux)"
fi

if [ "$DO_PERF" -eq 0 ]; then
  echo "io unified gate OK (smoke)"
  exit 0
fi

echo "=== IO unified: perf baseline (run-perf-io) ==="
chmod +x tests/run-perf-io.sh
if ci_is_linux; then
  # 默认 regression；CI 原生 Linux x86_64 可经 env 追加 SHUX_PERF_FAIL_ON_IO_ZIG=1（L1 ≥ Zig）
  IO_PERF_REGRESS="${SHUX_PERF_FAIL_ON_IO_REGRESSION:-1}"
  IO_PERF_ZIG="${SHUX_PERF_FAIL_ON_IO_ZIG:-0}"
  SHUX_PERF_FAIL_ON_IO_REGRESSION="$IO_PERF_REGRESS" \
    SHUX_PERF_FAIL_ON_IO_ZIG="$IO_PERF_ZIG" \
    ./tests/run-perf-io.sh --bench | tee /tmp/io_unified_perf.log
else
  ./tests/run-perf-io.sh --bench | tee /tmp/io_unified_perf.log
fi
grep -q 'io perf OK' /tmp/io_unified_perf.log

if ci_is_linux && ci_io_uring_available; then
  echo "=== IO unified: ZC-1 net perf (Linux io_uring) ==="
  chmod +x tests/run-zc1-gate.sh
  ZC1_ENV="SHUX_PERF_FAIL_ON_NET_REGRESSION=1 SHUX_PERF_FAIL_ON_ZC1=1"
  if [ -n "${SHUX_CI_REQUIRE_ZC1:-}" ]; then
    ZC1_ENV="${ZC1_ENV} SHUX_CI_REQUIRE_ZC1=1"
  fi
  # shellcheck disable=SC2086
  env ${ZC1_ENV} ./tests/run-zc1-gate.sh --perf | tee /tmp/io_unified_zc1_perf.log
  grep -qE 'ZC-1 gate OK|provided buffers N/A' /tmp/io_unified_zc1_perf.log
  grep -q 'ZC-1 provided vs batch OK' /tmp/io_unified_zc1_perf.log || {
    if [ -n "${SHUX_CI_REQUIRE_ZC1:-}" ]; then
      echo "run-io-unified-gate FAIL: ZC-1 -10% required (SHUX_CI_REQUIRE_ZC1=1)" >&2
      exit 1
    fi
    echo "io ZC-1 perf stretch N/A (no -10% on this runner)"
  }
else
  echo "io ZC-1 perf N/A ($(ci_host_summary))"
fi

if iocp_backend_expected; then
  echo "=== IO unified: IOCP pipe perf (Windows) ==="
  chmod +x tests/run-perf-iocp.sh
  SHUX_IOCP_RUNS="${SHUX_IOCP_RUNS:-1}" SHUX_IOCP_BENCH_ROUNDS="${SHUX_IOCP_BENCH_ROUNDS:-32768}" \
    SHUX_PERF_FAIL_ON_IOCP_REGRESSION=1 ./tests/run-perf-iocp.sh --bench | tee /tmp/io_unified_iocp_perf.log
  grep -q 'iocp perf OK' /tmp/io_unified_iocp_perf.log
else
  echo "io IOCP perf N/A ($(ci_host_summary))"
fi

echo "io unified gate OK (smoke + perf)"
