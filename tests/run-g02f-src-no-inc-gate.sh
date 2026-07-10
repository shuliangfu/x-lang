#!/usr/bin/env bash
# G-02f-82：compiler/src 下不得再出现手写 .inc（f-81 里程碑锁定）。
# 用法：./tests/run-g02f-src-no-inc-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "=== G-02f: compiler/src has zero .inc ==="
n=$(find compiler/src -name '*.inc' -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$n" != "0" ]; then
  echo "g02f-src-no-inc FAIL: found $n .inc under compiler/src:" >&2
  find compiler/src -name '*.inc' -type f 2>/dev/null | head -50 >&2
  exit 1
fi
echo "g02f-src-no-inc OK (compiler/src/**/*.inc = 0)"
