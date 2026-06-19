#!/usr/bin/env bash
# 无负载枚举：定义、Name.Variant / Name::Variant、match 分支
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}

$SHUX tests/enum/minimal.sx -o /tmp/shux_enum_min 2>&1
exitcode=0; /tmp/shux_enum_min >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (enum minimal), got $exitcode"; exit 1; }

$SHUX tests/enum/simple.sx -o /tmp/shux_enum_simple 2>&1
exitcode=0; /tmp/shux_enum_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (enum simple), got $exitcode"; exit 1; }

$SHUX tests/enum/match.sx -o /tmp/shux_enum_match 2>&1
exitcode=0; /tmp/shux_enum_match >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (enum match Color.Green), got $exitcode"; exit 1; }

echo "enum test OK"
