#!/bin/sh
# shux_compile_std_module.sh — 用 -E-extern + cc -c 编译 std 模块为 .o（F 闭合）
#
# 替代 *_import_alias.c C 桩。对每个 .x 文件生成瘦 C TU，cc -c 编译为 .o，
# 多文件时用 ld -r 合并。
#
# 用法：shux_compile_std_module.sh <out.o> <x1> [x2] [x3] ...
# 环境：SHUX=shux-c 路径（默认 ./shux-c）
set -e
out_o="$1"
shift
if [ -z "$out_o" ] || [ "$#" -lt 1 ]; then
  echo "usage: shux_compile_std_module.sh <out.o> <x1> [x2] ..." >&2
  exit 1
fi

SHUX_BIN="${SHUX:-./shux-c}"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./shux-c"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./shux_asm"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./shux"
[ -x "$SHUX_BIN" ] || { echo "shux_compile_std_module.sh: no shux-c/shux_asm/shux found" >&2; exit 1; }

# 【Why 根源】-E-extern 生成瘦 C TU（emit_c_only=1 + emit_extern_imports=1），
# import 用 extern 声明，不内联 deps。每个 .x 独立编译，ld -r 合并后符号自洽。
# CFLAGS 抑制 warning（-E-extern 生成的 C 有大量 extern 前向声明）。
CFLAGS="-I.. -I. -Iinclude -Isrc -fPIE -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits -Wno-visibility -Wno-incompatible-pointer-types -Wno-incompatible-pointer-types-discards-qualifiers"
if cc -v 2>&1 | grep -q clang; then
  CFLAGS="$CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses"
fi

tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t shuxmod)
trap 'rm -rf "$tmp_dir" 2>/dev/null || true' EXIT INT TERM

obj_files=""
idx=0
for x_path in "$@"; do
  # Makefile 在 compiler/ 下执行；输入须为 ../std/...（-L .. 不解析入口路径）
  case "$x_path" in
    std/*) x_path="../$x_path" ;;
  esac
  gen_c="$tmp_dir/mod_${idx}.c"
  obj="$tmp_dir/mod_${idx}.o"
  if ! "$SHUX_BIN" -E-extern -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
    echo "shux_compile_std_module.sh: shux-c -E-extern failed for $x_path" >&2
    cat "$tmp_dir/shuxc_${idx}.log" >&2
    exit 1
  fi
  if ! cc $CFLAGS -c "$gen_c" -o "$obj" 2>"$tmp_dir/cc_${idx}.log"; then
    echo "shux_compile_std_module.sh: cc -c failed for $x_path" >&2
    # 显示首个 error
    grep -m1 'error:' "$tmp_dir/cc_${idx}.log" >&2 || cat "$tmp_dir/cc_${idx}.log" >&2
    exit 1
  fi
  if [ -z "$obj_files" ]; then
    obj_files="$obj"
  else
    obj_files="$obj_files $obj"
  fi
  idx=$((idx + 1))
done

# 单文件直接移到输出；多文件 ld -r 合并
if [ "$idx" -eq 1 ]; then
  mv "$obj_files" "$out_o"
else
  # 【Why 根源】ld -r 合并多 .o 为一个可重定位 .o。
  # Linux GNU ld 用 --allow-multiple-definition 兼容 weak 符号重复定义；
  # macOS Mach-O ld 不支持此选项，用 -r 即可（符号不重复时正常合并）。
  LD_R_FLAGS="-r"
  if ld --help 2>&1 | grep -q 'allow-multiple-definition'; then
    LD_R_FLAGS="-r --allow-multiple-definition"
  fi
  ld $LD_R_FLAGS -o "$out_o" $obj_files 2>"$tmp_dir/ld.log" || {
    echo "shux_compile_std_module.sh: ld -r failed" >&2
    cat "$tmp_dir/ld.log" >&2
    exit 1
  }
fi

echo "shux_compile_std_module.sh: OK ($idx files -> $out_o)"
