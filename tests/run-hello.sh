#!/usr/bin/env bash
# 阶段 4 Hello World：编译 examples/hello.x 并运行，检查输出含 "Hello World"
# run-all 默认用 C（RUN_ALL_USE_C=1）：父脚本会 export XLANG=./compiler/xlang-c（若存在），走 C 流水线。
# 显式 XLANG=./compiler/xlang 时走 seed / .x 流水线（bootstrap 验证）。

set -e
cd "$(dirname "$0")/.."
XLANG=${XLANG:-./compiler/xlang}

# 探测二进制是否支持 -x（链 pipeline）；纯 C 前端 xlang-c 会报 unknown option。
xlang_cli_supports_x() {
  local o
  o=$("$1" -x 2>&1) || true
  case "$o" in
    *"unknown option"*) return 1 ;;
    *) return 0 ;;
  esac
}

HELLO_COMPILE_XLANG="$XLANG"
HELLO_BACKEND=""
# MSYS2：seed -o 挂起；与 bootstrap-link-xlang / run-async 一致走 xlang-c。
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/xlang-c ]; then
    HELLO_COMPILE_XLANG=./compiler/xlang-c
    HELLO_BACKEND=""
  fi
elif [ -n "${XLANG_LINK_XLANG:-}" ] && [ -x "${XLANG_LINK_XLANG}" ]; then
  # 产品冷链：XLANG 已是 xlang_asm→xlang 时勿改绑 pin xlang-c（bstrict 默认 XLANG_LINK_XLANG）。
  case "$(basename "${XLANG:-}")" in
    xlang|xlang_asm|xlang_asm2|xlang_asm_stage1)
      HELLO_COMPILE_XLANG="$XLANG"
      HELLO_BACKEND="-backend c"
      ;;
    *)
      HELLO_COMPILE_XLANG="${XLANG_LINK_XLANG}"
      HELLO_BACKEND=""
      ;;
  esac
fi
case "${XLANG##*/}" in
  xlang_stage1|xlang_stage2)
    _hello_xlang_dir=$(dirname "$XLANG")
    if [ -x "$_hello_xlang_dir/xlang-c" ]; then HELLO_COMPILE_XLANG="$_hello_xlang_dir/xlang-c"; fi
    ;;
esac
# bootstrap seed 默认 asm 后端在 ARM64 等会链入 x86_64 宿主 .o；非 x86_64 可执行链接优先 xlang-c。
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/xlang-c ]; then
      HELLO_COMPILE_XLANG=./compiler/xlang-c
      HELLO_BACKEND=""
    else
      case "${HELLO_COMPILE_XLANG##*/}" in
        xlang-c|xlang_asm) ;;
        *) HELLO_BACKEND="-backend c" ;;
      esac
    fi
    ;;
esac
if [ -n "${RUN_ALL_USE_C:-}" ]; then
  # run-all 默认 C 流水线；run-all 入口已 make 时跳过（XLANG_SKIP_SUBSCRIPT_MAKE=1），
  # 避免子脚本 `make all` 触发默认 xlang-c target（cp -f bootstrap_xlangc）覆盖真正 C 前端。
  if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
    make -C compiler -q all 2>/dev/null || make -C compiler all
  fi
  if [ -x ./compiler/xlang-c ]; then
    HELLO_COMPILE_XLANG=./compiler/xlang-c
    HELLO_BACKEND=""
  fi
  $HELLO_COMPILE_XLANG $HELLO_BACKEND examples/hello.x -o /tmp/xlang_hello
else
  if [[ "$HELLO_COMPILE_XLANG" == *xlang-c* ]] || ! xlang_cli_supports_x "$HELLO_COMPILE_XLANG"; then
    $HELLO_COMPILE_XLANG $HELLO_BACKEND -L . examples/hello.x -o /tmp/xlang_hello
  else
    # -o 链接走 driver 全路径；与 run-all-x 一致带 -L .
    # seed/xlang_asm：非 TTY stdout 重定向会挂起；须 tee|cat Drain（Codespace gold L5）。
    if ! $HELLO_COMPILE_XLANG $HELLO_BACKEND -L . examples/hello.x -o /tmp/xlang_hello 2>&1 | tee /tmp/xlang_hello_build.log | cat >/dev/null; then
      echo "hello compile failed (see /tmp/xlang_hello_build.log)" >&2
      exit 1
    fi
  fi
fi
if [ ! -x /tmp/xlang_hello ]; then
  echo "hello compile failed (no executable /tmp/xlang_hello)" >&2
  exit 1
fi
set +e
out=$(/tmp/xlang_hello)
rc=$?
set -e
echo "$out" | grep -q "Hello World" || { echo "expected 'Hello World' in output, got: $out"; exit 1; }
# void main → process exit 0 (Zig-like; examples/hello.x contract)
if [ "$rc" -ne 0 ]; then
  echo "expected hello exit 0, got $rc" >&2
  exit 1
fi
echo "Hello World test OK"
