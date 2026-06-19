#!/usr/bin/env bash
# 阶段 4 Hello World：编译 examples/hello.sx 并运行，检查输出含 "Hello World"
# run-all 默认用 C（RUN_ALL_USE_C=1）：父脚本会 export SHUX=./compiler/shux-c（若存在），走 C 流水线。
# 显式 SHUX=./compiler/shux 时走 seed / .sx 流水线（bootstrap 验证）。

set -e
cd "$(dirname "$0")/.."
SHUX=${SHUX:-./compiler/shux}

# 探测二进制是否支持 -sx（链 pipeline）；纯 C 前端 shux-c 会报 unknown option。
shux_cli_supports_sx() {
  local o
  o=$("$1" -sx 2>&1) || true
  case "$o" in
    *"unknown option"*) return 1 ;;
    *) return 0 ;;
  esac
}

HELLO_COMPILE_SHUX="$SHUX"
HELLO_BACKEND=""
# MSYS2：seed -o 挂起；与 bootstrap-link-shux / run-async 一致走 shux-c。
if [ -n "${MSYSTEM:-}" ] || case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*) true ;; *) false ;; esac; then
  if [ -x ./compiler/shux-c ]; then
    HELLO_COMPILE_SHUX=./compiler/shux-c
    HELLO_BACKEND=""
  fi
elif [ -n "${SHUX_LINK_SHUX:-}" ] && [ -x "${SHUX_LINK_SHUX}" ]; then
  HELLO_COMPILE_SHUX="${SHUX_LINK_SHUX}"
  HELLO_BACKEND=""
fi
case "${SHUX##*/}" in
  shux_stage1|shux_stage2)
    _hello_shux_dir=$(dirname "$SHUX")
    if [ -x "$_hello_shux_dir/shux-c" ]; then HELLO_COMPILE_SHUX="$_hello_shux_dir/shux-c"; fi
    ;;
esac
# bootstrap seed 默认 asm 后端在 ARM64 等会链入 x86_64 宿主 .o；非 x86_64 可执行链接优先 shux-c。
case "$(uname -m 2>/dev/null)" in
  x86_64|amd64) ;;
  *)
    if [ -x ./compiler/shux-c ]; then
      HELLO_COMPILE_SHUX=./compiler/shux-c
      HELLO_BACKEND=""
    else
      case "${HELLO_COMPILE_SHUX##*/}" in
        shux-c|shux_asm) ;;
        *) HELLO_BACKEND="-backend c" ;;
      esac
    fi
    ;;
esac
if [ -n "${RUN_ALL_USE_C:-}" ]; then
  # run-all 默认 C 流水线
  make -C compiler -q all 2>/dev/null || make -C compiler all
  if [ -x ./compiler/shux-c ]; then
    HELLO_COMPILE_SHUX=./compiler/shux-c
    HELLO_BACKEND=""
  fi
  $HELLO_COMPILE_SHUX $HELLO_BACKEND examples/hello.sx -o /tmp/shux_hello
else
  if [[ "$HELLO_COMPILE_SHUX" == *shux-c* ]] || ! shux_cli_supports_sx "$HELLO_COMPILE_SHUX"; then
    $HELLO_COMPILE_SHUX $HELLO_BACKEND -L . examples/hello.sx -o /tmp/shux_hello
  else
    # -o 链接走 driver 全路径；与 run-all-sx 一致带 -L .
    $HELLO_COMPILE_SHUX $HELLO_BACKEND -L . examples/hello.sx -o /tmp/shux_hello 1>/dev/null
  fi
fi
out=$(/tmp/shux_hello)
echo "$out" | grep -q "Hello World" || { echo "expected 'Hello World' in output, got: $out"; exit 1; }
echo "Hello World test OK"
