#!/usr/bin/env bash
# shu fmt 子命令：格式化 .su 后仍能通过 check。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler bootstrap-driver-seed
SHU=${SHU:-./compiler/shu}

cp tests/return-value/main.su /tmp/shu_fmt_cmd_test.su
$SHU fmt /tmp/shu_fmt_cmd_test.su 2>&1 | grep -qE "fmt OK|fmt unchanged"
$SHU check /tmp/shu_fmt_cmd_test.su 2>&1 | grep -q "check OK"
echo "fmt cmd test OK"
