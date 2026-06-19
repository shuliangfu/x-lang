#!/usr/bin/env bash
# 测试 core.builtin（placeholder、位运算、copy/min/max）
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
make -C compiler -q ../core/builtin/builtin.o 2>/dev/null || make -C compiler ../core/builtin/builtin.o
# main 入口写 shux_process_argc/argv，minimal 链须 std/process/process.o。
make -C compiler -q ../std/process/process.o 2>/dev/null || make -C compiler ../std/process/process.o
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# -o 可执行须走 C 前端（Docker/musl 上 seed shux asm 链会 cc failed）。
if [ -x ./compiler/shux-c ]; then
  RUN_SHUX=./compiler/shux-c
fi
# Alpine/musl：invoke_cc 仅链已按需推入的 core/*.o，避免全量 std/*.o ld 挂起（CORE-009）。
export SHUX_MINIMAL_CC_LINK=1
export SHUX_OPT=0
export SHUX_NO_MARCH_NATIVE=1
export CI="${CI:-1}"

$RUN_SHUX -L . tests/builtin/main.sx -o /tmp/shux_builtin 2>&1 || { echo "run-builtin FAIL: compile tests/builtin/main.sx" >&2; exit 1; }
exitcode=0; /tmp/shux_builtin >/dev/null 2>&1 || exitcode=$?
[ "$exitcode" -ne 0 ] && { echo "expected exit 0 (core.builtin placeholder), got $exitcode"; exit 1; }

echo "builtin test OK"
