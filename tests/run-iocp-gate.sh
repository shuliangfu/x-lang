#!/usr/bin/env bash
# IO-A6 Windows IOCP + registered buffer 一键门禁（MSYS2/MINGW 实跑；其它平台 SKIP exit 0）。
# 已收敛至 run-io-unified-gate.sh；本脚本保留兼容入口。
#
# 用法：
#   ./tests/run-iocp-gate.sh           # smoke
#   ./tests/run-iocp-gate.sh --perf    # smoke + pipe batch perf
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

chmod +x tests/run-io-unified-gate.sh
if [ "$DO_PERF" -eq 1 ]; then
  ./tests/run-io-unified-gate.sh --perf | tee /tmp/iocp_gate.log
else
  ./tests/run-io-unified-gate.sh | tee /tmp/iocp_gate.log
fi
grep -q 'io unified gate OK' /tmp/iocp_gate.log
echo "IO-A6 gate OK (via io-unified-gate)"
