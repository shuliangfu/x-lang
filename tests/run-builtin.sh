#!/usr/bin/env bash
# 测试 core.builtin（placeholder、位运算、copy/min/max）
# G-01：无 core/builtin/builtin.c，C 后端经 codegen __builtin_* 映射。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# -o 可执行须走 C 前端（Docker/musl 上 seed shux asm 链会 cc failed）。
if [ -x ./compiler/shux-c ]; then
  RUN_SHUX=./compiler/shux-c
fi
# Alpine/musl：invoke_cc 最小链（G-01 无 core/*.o）。
export SHUX_MINIMAL_CC_LINK=1
export SHUX_OPT=0
export SHUX_NO_MARCH_NATIVE=1
export CI="${CI:-1}"

compile_out=""
compile_out=$($RUN_SHUX -L . tests/builtin/main.sx -o /tmp/shux_builtin 2>&1) || {
  gen_c=""
  gen_c=$(echo "$compile_out" | sed -n 's/.*keeping generated C: //p' | tail -1)
  if [ -z "$gen_c" ] || [ ! -f "$gen_c" ]; then
    gen_c=$(ls -t /tmp/shux_*.c 2>/dev/null | head -1)
  fi
  if [ -n "$gen_c" ] && [ -f "$gen_c" ]; then
    echo "run-builtin: invoke_cc failed, fallback gcc minimal link ($gen_c)" >&2
    gcc -std=gnu11 -O0 -o /tmp/shux_builtin "$gen_c" -lc 2>/dev/null \
      || cc -std=gnu11 -O0 -o /tmp/shux_builtin "$gen_c" -lc || {
      echo "$compile_out" >&2
      echo "run-builtin FAIL: compile tests/builtin/main.sx" >&2
      exit 1
    }
  else
    echo "$compile_out" >&2
    echo "run-builtin FAIL: compile tests/builtin/main.sx" >&2
    exit 1
  fi
}
/tmp/shux_builtin || { echo "run-builtin FAIL: run exit=$?" >&2; exit 1; }
echo "run-builtin OK"
