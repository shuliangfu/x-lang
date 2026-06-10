#!/usr/bin/env bash
# run-io-unified-gate.sh — 统一 IO 后端门禁（Tier P + Tier B）。
#
# 同一套 .su 源码在全平台验证 std.io 批量读写；Linux 额外探测 io_uring ZC-1/multishot（无则 N/A）。
# Windows 上 .su 批量路径即 IOCP；可选 --perf 追加平台 perf（Linux ZC-1 / Windows IOCP pipe）。
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
# shellcheck source=tests/lib/bootstrap-link-shu.sh
. "$(dirname "$0")/lib/bootstrap-link-shu.sh"

make -C compiler -q 2>/dev/null || make -C compiler
make -C compiler ../std/fs/fs.o ../std/io/io.o ../std/process/process.o -q 2>/dev/null \
  || make -C compiler ../std/fs/fs.o ../std/io/io.o ../std/process/process.o

if [ -z "${SHU:-}" ]; then
  if [ -x ./compiler/shu-c ]; then
    SHU=./compiler/shu-c
  elif [ -x ./compiler/shu ]; then
    SHU=./compiler/shu
  else
    echo "run-io-unified-gate FAIL: no compiler" >&2
    exit 1
  fi
fi

# Linux 链 io.o 时编译器 invoke_cc 自动加 -luring（见 compiler/Makefile）。
rm -f tests/bench/.io_batch_rw_smoke_tmp

echo "=== IO unified: batch_rw_smoke.su ($(ci_host_summary)) ==="
$RUN_SHU -L . tests/io/batch_rw_smoke.su -o /tmp/shu_io_batch_rw_smoke 2>&1
ec=0
/tmp/shu_io_batch_rw_smoke || ec=$?
rm -f tests/bench/.io_batch_rw_smoke_tmp
if [ "$ec" -ne 0 ]; then
  echo "run-io-unified-gate FAIL: batch_rw_smoke exit=$ec" >&2
  exit 1
fi
echo "io batch_rw_smoke OK"

echo "=== IO unified: read_ptr_slice (M-5) ==="
chmod +x tests/run-io-read-ptr-slice.sh
SHU="$RUN_SHU" ./tests/run-io-read-ptr-slice.sh

echo "=== IO unified: std.io smoke (run-io.sh) ==="
chmod +x tests/run-io.sh
SHU="$RUN_SHU" ./tests/run-io.sh

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
  SHU_PERF_FAIL_ON_IO_REGRESSION=1 ./tests/run-perf-io.sh --bench | tee /tmp/io_unified_perf.log
else
  ./tests/run-perf-io.sh --bench | tee /tmp/io_unified_perf.log
fi
grep -q 'io perf OK' /tmp/io_unified_perf.log

if ci_is_linux && ci_io_uring_available; then
  echo "=== IO unified: ZC-1 net perf (Linux io_uring) ==="
  chmod +x tests/run-zc1-gate.sh
  ./tests/run-zc1-gate.sh --perf | tee /tmp/io_unified_zc1_perf.log
  grep -qE 'ZC-1 gate OK|provided buffers N/A' /tmp/io_unified_zc1_perf.log
else
  echo "io ZC-1 perf N/A ($(ci_host_summary))"
fi

if iocp_backend_expected; then
  echo "=== IO unified: IOCP pipe perf (Windows) ==="
  chmod +x tests/run-perf-iocp.sh
  SHU_IOCP_RUNS="${SHU_IOCP_RUNS:-1}" SHU_IOCP_BENCH_ROUNDS="${SHU_IOCP_BENCH_ROUNDS:-32768}" \
    SHU_PERF_FAIL_ON_IOCP_REGRESSION=1 ./tests/run-perf-iocp.sh --bench | tee /tmp/io_unified_iocp_perf.log
  grep -q 'iocp perf OK' /tmp/io_unified_iocp_perf.log
else
  echo "io IOCP perf N/A ($(ci_host_summary))"
fi

echo "io unified gate OK (smoke + perf)"
