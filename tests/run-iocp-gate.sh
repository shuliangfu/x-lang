#!/usr/bin/env bash
# IO-A6 Windows IOCP + registered buffer 一键门禁（MSYS2/MINGW 实跑；其它平台 SKIP exit 0）。
# 用法：
#   ./tests/run-iocp-gate.sh           # smoke
#   ./tests/run-iocp-gate.sh --perf    # smoke + pipe batch perf（Windows CI 可选）
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
      echo "run-iocp-gate: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

chmod +x tests/run-iocp-smoke.sh tests/run-perf-iocp.sh 2>/dev/null || true

echo "=== IO-A6: IOCP batch + read_fixed smoke ==="
./tests/run-iocp-smoke.sh | tee /tmp/iocp_smoke.log

if grep -q "iocp smoke SKIP" /tmp/iocp_smoke.log; then
  echo "IO-A6 gate SKIP (non-Windows MSYS2)"
  exit 0
fi

grep -q "iocp smoke OK" /tmp/iocp_smoke.log

if [ "$DO_PERF" -eq 0 ]; then
  echo "IO-A6 gate OK (smoke)"
  exit 0
fi

echo "=== IO-A6: IOCP pipe batch perf ==="
SHU_PERF_FAIL_ON_IOCP_REGRESSION=1 SHU_IOCP_RUNS="${SHU_IOCP_RUNS:-1}" \
  ./tests/run-perf-iocp.sh --bench | tee /tmp/iocp_perf.log
grep -q 'iocp perf OK' /tmp/iocp_perf.log
echo "IO-A6 gate OK (smoke + perf)"
