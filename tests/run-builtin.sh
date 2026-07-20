#!/usr/bin/env bash
# 测试 core.builtin（placeholder、位运算、copy/min/max）
# G-01：无 core/builtin/builtin.c，C 后端经 codegen __builtin_* 映射。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler shux-c
# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# 产品轨：bstrict 注入的 SHUX/shux_asm 优先（可完整 -o + shux_panic_）。
# 仅当未显式指定 SHUX 且 basename 不是 shux_asm* 时，才回退 shux-c。
case "$(basename "${SHUX:-${RUN_SHUX:-}}")" in
  shux_asm|shux_asm2|shux_asm_stage1) ;;
  *)
    if [ -z "${SHUX:-}" ] && [ -x ./compiler/shux-c ]; then
      RUN_SHUX=./compiler/shux-c
    fi
    ;;
esac
# Alpine/musl：invoke_cc 最小链（G-01 无 core/*.o）。产品 shux_asm 路径勿强制。
case "$(basename "${RUN_SHUX}")" in
  shux-c|shux)
    export SHUX_MINIMAL_CC_LINK=1
    ;;
esac
export SHUX_OPT=0
export SHUX_NO_MARCH_NATIVE=1
export CI="${CI:-1}"

compile_out=""
compile_out=$($RUN_SHUX build -L . tests/builtin/main.x -o /tmp/shux_builtin 2>&1) || {
  gen_c=""
  gen_c=$(echo "$compile_out" | sed -n 's/.*keeping generated C: //p' | tail -1)
  if [ -z "$gen_c" ] || [ ! -f "$gen_c" ]; then
    gen_c=$(ls -t /tmp/shux_*.c 2>/dev/null | head -1)
  fi
  if [ -n "$gen_c" ] && [ -f "$gen_c" ]; then
    echo "run-builtin: invoke_cc failed, fallback gcc + runtime_panic ($gen_c)" >&2
    _panic_o=""
    if [ -f ./compiler/runtime_panic.o ]; then
      _panic_o=./compiler/runtime_panic.o
    fi
    # shellcheck disable=SC2086
    gcc -std=gnu11 -O0 -o /tmp/shux_builtin "$gen_c" $_panic_o -lc 2>/dev/null \
      || cc -std=gnu11 -O0 -o /tmp/shux_builtin "$gen_c" $_panic_o -lc || {
      echo "$compile_out" >&2
      echo "run-builtin FAIL: compile tests/builtin/main.x" >&2
      exit 1
    }
  else
    echo "$compile_out" >&2
    echo "run-builtin FAIL: compile tests/builtin/main.x" >&2
    exit 1
  fi
}
/tmp/shux_builtin || { echo "run-builtin FAIL: run exit=$?" >&2; exit 1; }
echo "builtin test OK"
