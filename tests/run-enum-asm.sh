#!/usr/bin/env bash
# B-strict 子集：无负载 enum 定义 + Color.Green 变体（不含 return match，见 tests/enum/match.su）。
set -e
cd "$(dirname "$0")/.."
SHU=${SHU:-./compiler/shu_asm}

$SHU tests/enum/minimal.su -o /tmp/shu_enum_min 2>&1
exitcode=0; /tmp/shu_enum_min >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (enum minimal), got $exitcode"; exit 1; }

$SHU tests/enum/simple.su -o /tmp/shu_enum_simple 2>&1
exitcode=0; /tmp/shu_enum_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (enum simple), got $exitcode"; exit 1; }

echo "enum-asm test OK"
