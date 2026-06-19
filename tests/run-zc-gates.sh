#!/usr/bin/env bash
# 零拷贝统一门禁：ZC-1 provided buffers + ZC-2 read_ptr 绝对视图 + ZC-3 slice 域 + ZC-4 String + ZC-5 splice。
# 用法：
#   ./tests/run-zc-gates.sh
#   ./tests/run-zc-gates.sh --perf   # ZC-1 追加 net perf -10%（Linux io_uring 实锤）
#   SHUX=./compiler/shux_asm ./tests/run-zc-gates.sh
set -e
cd "$(dirname "$0")/.."

DO_ZC1_PERF=0
for arg in "$@"; do
  case "$arg" in
    --perf) DO_ZC1_PERF=1 ;;
    -h|--help)
      echo "Usage: $0 [--perf]"
      exit 0
      ;;
    *)
      echo "run-zc-gates: unknown arg: $arg" >&2
      exit 2
      ;;
  esac
done

echo "=== ZC gates: ZC-1 → ZC-2 → ZC-3 → ZC-4 → ZC-5 ==="

chmod +x tests/run-zc1-gate.sh tests/run-zc2-gate.sh tests/run-zc3-gate.sh \
  tests/run-zc4-gate.sh tests/run-zc5-gate.sh

if [ "$DO_ZC1_PERF" -eq 1 ]; then
  SHUX="${SHUX:-}" ./tests/run-zc1-gate.sh --perf
else
  SHUX="${SHUX:-}" ./tests/run-zc1-gate.sh
fi

SHUX="${SHUX:-}" ./tests/run-zc2-gate.sh
SHUX="${SHUX:-}" ./tests/run-zc3-gate.sh
SHUX="${SHUX:-}" ./tests/run-zc4-gate.sh
SHUX="${SHUX:-}" ./tests/run-zc5-gate.sh

echo "zc gates OK"
