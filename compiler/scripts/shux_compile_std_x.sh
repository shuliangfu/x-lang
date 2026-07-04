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
  if [ -x ./shux_asm ]; then
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
    exec env SHUX_ASM_WPO_DCE=0 "$shux_bin" -backend asm -L .. "$x_path" -o "$out_o"
    ;;
esac
