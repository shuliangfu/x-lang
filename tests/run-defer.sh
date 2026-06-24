#!/usr/bin/env bash
# defer 块：解析与 codegen，块尾表达式为返回值
set -e
cd "$(dirname "$0")/.."
chmod +x tests/run-defer-gate.sh
./tests/run-defer-gate.sh
echo "defer test OK"
