#!/usr/bin/env bash
# shu test 子命令：跑轻量脚本（非全量 run-all，避免 CI 重复）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
SHU=${SHU:-./compiler/shu}

$SHU test tests/run-echo-test.sh 2>&1 | grep -q "echo test OK"
echo "test cmd OK"
