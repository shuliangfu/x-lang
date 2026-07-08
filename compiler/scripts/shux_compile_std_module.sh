#!/bin/sh
# shux_compile_std_module.sh — 用 -x -E + cc -c 编译 std 模块为 .o（F 闭合）
#
# 【Why 根源】G-02a 删除 C 前端后，-E-extern 模式不可用（runtime.c 在
# SHUX_NO_C_FRONTEND 定义时直接报 BLD001）。-x -E 走 .x pipeline 路径，
# 生成等价的瘦 C TU（含 extern 前向声明），功能等价于旧 -E-extern。
#
# 替代 *_import_alias.c C 桩。两种模块架构：
#   1. import binding 模式（heap/map/set）：mod.x 用 `const impl = import("std.module.libc")`，
#      impl .x 用路径提取前缀（std_heap_libc_*），不传 -lib-name。
#   2. extern function 模式（tar/csv/json/...）：mod.x 用 `extern function foo_c()`，
#      impl .x 用 -lib-name "" 产出裸符号（foo_c），匹配 mod.x 的 extern 调用。
#      需传 --bare-impl 参数启用此模式。
# cc -c 编译为 .o，多文件时用 ld -r 合并。
#
# 用法：shux_compile_std_module.sh [--bare-impl] <out.o> <x1> [x2] [x3] ...
# 约定：mod.x 编译为带前缀符号（std_<module>_*）。
#   --bare-impl：非 mod.x 文件用 -lib-name ""（裸符号）；否则用路径提取前缀。
# 环境：SHUX=编译器路径（默认 ./shux-c，回退 ./shux_asm → ./shux）
set -e

BARE_IMPL=0
if [ "$1" = "--bare-impl" ]; then
  BARE_IMPL=1
  shift
fi

out_o="$1"
shift
if [ -z "$out_o" ] || [ "$#" -lt 1 ]; then
  echo "usage: shux_compile_std_module.sh [--bare-impl] <out.o> <x1> [x2] ..." >&2
  exit 1
fi

# 【Why 根源】优先 ./shux（.x pipeline，支持 -x -E）；LEGACY shux-c 不支持 -x 选项。
# G-02a 后 -E-extern 不可用，必须用 -x -E 走 .x pipeline，故 ./shux 优先。
# SHUX 可能是项目根目录相对路径（./compiler/shux），Makefile 在 compiler/ 下执行时
# 该路径不存在，需回退到 compiler/ 本地的 ./shux。
SHUX_BIN="${SHUX:-./shux}"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./shux"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./shux_asm"
[ -x "$SHUX_BIN" ] || SHUX_BIN="./shux-c"
[ -x "$SHUX_BIN" ] || SHUX_BIN="../compiler/shux"
[ -x "$SHUX_BIN" ] || { echo "shux_compile_std_module.sh: no shux/shux_asm/shux-c found" >&2; exit 1; }

# 【Why 根源】-x -E 生成瘦 C TU（emit_c_only=1 + emit_extern_imports=1），
# import 用 extern 声明，不内联 deps。mod.x 带前缀产出 std_<module>_* 用户 API。
# --bare-impl 模式下 impl .x 用 -lib-name "" 产出裸符号（如 tar_read_header_c）；
# 否则 impl .x 用路径提取前缀（如 std_heap_libc_heap_arena64_alloc_c），匹配 import binding。
# CFLAGS 抑制 warning（-x -E 生成的 C 有大量 extern 前向声明）。
# -ffunction-sections -fdata-sections：配合 freestanding 链接的 --gc-sections，
# 移除 std/sys/linux.o 等模块中未被引用的 hosted libc 函数（open/mmap 等），
# 使 freestanding -nostdlib 链接不因 transitive libc 符号失败。
CFLAGS="-I.. -I. -Iinclude -Isrc -fPIE -ffunction-sections -fdata-sections -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-parentheses -Wno-sign-compare -Wno-ignored-qualifiers -Wno-unused-but-set-variable -Wno-type-limits -Wno-visibility -Wno-incompatible-pointer-types -Wno-incompatible-pointer-types-discards-qualifiers"
if cc -v 2>&1 | grep -q clang; then
  CFLAGS="$CFLAGS -Wno-logical-op-parentheses -Wno-bitwise-op-parentheses"
fi

tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t shuxmod)
trap 'rm -rf "$tmp_dir" 2>/dev/null || true' EXIT INT TERM

# 【Why 根源】旧 seed（bootstrap_shuxc）不支持 -lib-name flag（ treats it as a file path,
# outputs "io error: cannot read file '-lib-name'" and exits 0）。但其无前缀逻辑也产出裸符号
# （函数名本身已含 module_ 前缀），故不加 -lib-name 即可匹配 mod.x 的 extern 调用。
# 新编译器需 -lib-name "" 抑制 shux_entry_lib_name_from_path 的路径前缀，否则符号被双重前缀化。
LIB_NAME_SUPPORTED=0
probe_x="$tmp_dir/probe.x"
probe_c="$tmp_dir/probe.c"
printf 'function probe_fn(): i32 { return 0; }\n' > "$probe_x"
if "$SHUX_BIN" -x -E -lib-name "" "$probe_x" > "$probe_c" 2>/dev/null && grep -q 'probe_fn' "$probe_c"; then
  LIB_NAME_SUPPORTED=1
fi

obj_files=""
idx=0
for x_path in "$@"; do
  # Makefile 在 compiler/ 下执行；输入须为 ../std/...（-L .. 不解析入口路径）
  case "$x_path" in
    std/*) x_path="../$x_path" ;;
  esac
  gen_c="$tmp_dir/mod_${idx}.c"
  obj="$tmp_dir/mod_${idx}.o"
  # 【Why 根源】mod.x 是模块入口，编译为带前缀符号（std_<module>_*）。
  # --bare-impl 模式下，impl .x 用 -lib-name "" 产出裸符号（匹配 mod.x 的 extern 调用）；
  # 否则 impl .x 用路径提取前缀（匹配 mod.x 的 import binding 调用）。
  base_name=$(basename "$x_path")
  if [ "$base_name" = "mod.x" ]; then
    if ! "$SHUX_BIN" -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
      echo "shux_compile_std_module.sh: shux-c -x -E failed for $x_path" >&2
      cat "$tmp_dir/shuxc_${idx}.log" >&2
      exit 1
    fi
  else
    if [ "$BARE_IMPL" = "1" ]; then
      # 【Why 根源】-lib-name "" 让新编译器产出裸符号（匹配 mod.x 的 extern 调用）。
      # 旧 seed 不支持 -lib-name 但其无前缀逻辑也产出裸符号，故 LIB_NAME_SUPPORTED=0 时不加。
      if [ "$LIB_NAME_SUPPORTED" = "1" ]; then
        if ! "$SHUX_BIN" -x -E -lib-name "" -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
          echo "shux_compile_std_module.sh: shux-c -x -E -lib-name failed for $x_path" >&2
          cat "$tmp_dir/shuxc_${idx}.log" >&2
          exit 1
        fi
      else
        if ! "$SHUX_BIN" -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
          echo "shux_compile_std_module.sh: shux-c -x -E failed for $x_path" >&2
          cat "$tmp_dir/shuxc_${idx}.log" >&2
          exit 1
        fi
      fi
    else
      if ! "$SHUX_BIN" -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
        echo "shux_compile_std_module.sh: shux-c -x -E failed for $x_path" >&2
        cat "$tmp_dir/shuxc_${idx}.log" >&2
        exit 1
      fi
    fi
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
