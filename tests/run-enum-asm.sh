#!/usr/bin/env bash
# B-strict 子集：无负载 enum 定义 + Color.Green 变体（不含 return match，见 tests/enum/match.sx）。
set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux_asm}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"

$LINK_SHUX tests/enum/minimal.sx -o /tmp/shux_enum_min 2>&1
exitcode=0; /tmp/shux_enum_min >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected 0 (enum minimal), got $exitcode"; exit 1; }

$LINK_SHUX tests/enum/simple.sx -o /tmp/shux_enum_simple 2>&1
exitcode=0; /tmp/shux_enum_simple >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 1 ] && { echo "expected 1 (enum simple), got $exitcode"; exit 1; }

echo "enum-asm test OK"
