#!/usr/bin/env bash
# 测试 core.builtin（placeholder、位运算、copy/min/max）
# G-01：无 core/builtin/builtin.c，C 后端经 codegen __builtin_* 映射。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler xlang-c
# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
# 产品轨：bstrict 注入的 XLANG/xlang_asm 优先（可完整 -o + xlang_panic_）。
# 仅当未显式指定 XLANG 且 basename 不是 xlang_asm* 时，才回退 xlang-c。
case "$(basename "${XLANG:-${RUN_XLANG:-}}")" in
  xlang_asm|xlang_asm2|xlang_asm_stage1) ;;
  *)
    if [ -z "${XLANG:-}" ] && [ -x ./compiler/xlang-c ]; then
      RUN_XLANG=./compiler/xlang-c
    fi
    ;;
esac
# Alpine/musl：invoke_cc 最小链（G-01 无 core/*.o）。产品 xlang_asm 路径勿强制。
case "$(basename "${RUN_XLANG}")" in
  xlang-c|xlang)
    export XLANG_MINIMAL_CC_LINK=1
    ;;
esac
export XLANG_OPT=0
export XLANG_NO_MARCH_NATIVE=1
export CI="${CI:-1}"

compile_out=""
compile_out=$($RUN_XLANG build -L . tests/builtin/main.x -o /tmp/xlang_builtin 2>&1) || {
  gen_c=""
  gen_c=$(echo "$compile_out" | sed -n 's/.*keeping generated C: //p' | tail -1)
  if [ -z "$gen_c" ] || [ ! -f "$gen_c" ]; then
    gen_c=$(ls -t /tmp/xlang_*.c 2>/dev/null | head -1)
  fi
  if [ -n "$gen_c" ] && [ -f "$gen_c" ]; then
    echo "run-builtin: invoke_cc failed, fallback gcc + runtime_panic ($gen_c)" >&2
    _panic_o=""
    if [ -f ./compiler/runtime_panic.o ]; then
      _panic_o=./compiler/runtime_panic.o
    fi
    # shellcheck disable=SC2086
    gcc -std=gnu11 -O0 -o /tmp/xlang_builtin "$gen_c" $_panic_o -lc 2>/dev/null \
      || cc -std=gnu11 -O0 -o /tmp/xlang_builtin "$gen_c" $_panic_o -lc || {
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
/tmp/xlang_builtin || { echo "run-builtin FAIL: run exit=$?" >&2; exit 1; }
echo "builtin test OK"
