#!/usr/bin/env bash
# STD-007：std.compress hook
#
# 用法：./tests/run-std-compress.sh
set -e
cd "$(dirname "$0")/.."
chmod +x tests/run-std-compress-gate.sh
./tests/run-std-compress-gate.sh
echo "std-compress hook OK"
