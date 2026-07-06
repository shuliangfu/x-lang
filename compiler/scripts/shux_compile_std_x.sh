#!/bin/sh
# shux_compile_std_x.sh — 编译 std/*.x 为 .o（Makefile std-objs 规则共用）
#
# shux-c 仅 C 前端，不接受 -backend；seed/shux_asm 走 -backend asm。
# 用法：shux_compile_std_x.sh <shux-bin|auto> <x-path> <out.o>
# auto：优先 shux_asm → shux → shux-c（库模块须 asm 出 .o，勿优先 shux-c）。
set -e
shux_bin="$1"
x_path="$2"
out_o="$3"
if [ -z "$shux_bin" ] || [ -z "$x_path" ] || [ -z "$out_o" ]; then
  echo "usage: shux_compile_std_x.sh <shux|auto> <file.x> <out.o>" >&2
  exit 1
fi
# Makefile 在 compiler/ 下执行；输入须为 ../std/...（-L .. 不解析入口路径）
case "$x_path" in
  std/*) x_path="../$x_path" ;;
esac
if [ "$shux_bin" = "auto" ]; then
  # 【Why 根源】run-all 批量回归时 SHUX_COMPILE_STD_USE_C=1 强制走 shux-c：
  # shux_asm/shux（seed）在 macOS -backend asm 对部分 .x 产出 code_len=0 或语义错误 .o，
  # 且 exit=0 不回退，污染 std/*.o 导致单独通过批量失败。
  # 设此变量后优先 shux-c，确保 .o 与测试程序同源（都用 C 前端）。
  if [ -n "${SHUX_COMPILE_STD_USE_C:-}" ] && [ -x ./shux-c ]; then
    shux_bin=./shux-c
  elif [ -x ./shux_asm ]; then
    shux_bin=./shux_asm
  elif [ -x ./shux ]; then
    shux_bin=./shux
  elif [ -x ./shux-c ]; then
    shux_bin=./shux-c
  else
    echo "shux_compile_std_x.sh: need shux_asm, shux, or shux-c in compiler/" >&2
    exit 1
  fi
fi
case "$(basename "$shux_bin")" in
  shux-c)
    exec "$shux_bin" -L .. "$x_path" -o "$out_o"
    ;;
  *)
    # 【Why 根源】Darwin 的 bootstrap-driver-seed 使用 asm_backend_partial.o 中的
    # seed_mega 桩（仅 14 个弱符号返回 0），真实 ARM64 指令发射器未被 -E 编入。
    # 因此 -backend asm 在 macOS 上产出 code_len=0，所有 std/*.o 编译失败。
    # 【修复】-backend asm 失败时回退到 shux-c（-E + cc -c），保证 std .o 可用。
    if env SHUX_ASM_WPO_DCE=0 "$shux_bin" -backend asm -L .. "$x_path" -o "$out_o" 2>/dev/null; then
      :
    else
      if [ -x ./shux-c ]; then
        gen_c="$out_o.gen.c"
        ./shux-c -E -L .. "$x_path" > "$gen_c" || { rm -f "$gen_c"; exit 1; }
        if grep -q '^#include' "$gen_c"; then
          last_inc_line=$(grep -n '^#include' "$gen_c" | tail -1 | cut -d: -f1)
          if [ -n "$last_inc_line" ]; then
            sed -i.bak "${last_inc_line}a\\
#undef htonl\\
#undef htons\\
#undef ntohl\\
#undef ntohs" "$gen_c"
            rm -f "$gen_c.bak"
          fi
        fi
        cc -Wall -Wextra -I. -Iinclude -Isrc -c -o "$out_o" "$gen_c" || { rm -f "$gen_c"; exit 1; }
        rm -f "$gen_c"
      else
        exit 1
      fi
    fi
    ;;
esac
