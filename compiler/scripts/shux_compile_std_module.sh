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
probe_err="$tmp_dir/probe.err"
printf 'function probe_fn(): i32 { return 0; }\n' > "$probe_x"
# 产品 x-pipeline 当前不识别 -lib-name（会当文件路径 → IO001）；仅 C 前端 RUN_CC 支持。
# 误判会把 -lib-name 传给 x 路径，或跳过 bare 后处理 → 双前缀符号（std_sync_sync_mutex_*）。
if "$SHUX_BIN" -x -E -lib-name "" "$probe_x" >"$probe_c" 2>"$probe_err" \
  && grep -q 'probe_fn' "$probe_c" \
  && ! grep -q 'cannot read file' "$probe_err" \
  && ! grep -q 'IO001' "$probe_err"; then
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
  # 【Why 根源】产品 -x -E 对无 main 库模块常中途截断 out_buf（4KiB 对齐截断、
  # 半个函数体）。-o *.o 路径 emit 完整 C（cc 可能因 Arena64 标签失败，但 SHUX_KEEP_C
  # 保留完整源）。优先 -o + KEEP_C，失败再回退 -E。
  emit_ok=0
  use_direct_o=0
  # 产品 std .o：Linux 默认 asm 对 string 等库模块体不完整（运行时 SIGSEGV）；强制 -backend c。
  # -o 无 main 时链失败但 SHUX_KEEP_C 保留完整 C；再 cc -c 落地。
  BACKEND_ARGS=""
  if [ -n "${SHUX_FORCE_LINK_BACKEND:-}" ]; then
    BACKEND_ARGS="-backend ${SHUX_FORCE_LINK_BACKEND}"
  else
    case "$(uname -s 2>/dev/null)" in
      Linux|Darwin) BACKEND_ARGS="-backend c" ;;
    esac
  fi
  # shellcheck: empty -lib-name needs quoted empty string
  rm -f /tmp/shux_shux_x.*.c 2>/dev/null || true
  if [ "$base_name" != "mod.x" ] && [ "$BARE_IMPL" = "1" ] && [ "$LIB_NAME_SUPPORTED" = "1" ]; then
    SHUX_KEEP_C=1 "$SHUX_BIN" $BACKEND_ARGS -L .. -lib-name "" -o "$tmp_dir/try_${idx}.o" "$x_path" \
      >"$tmp_dir/shuxc_${idx}.log" 2>&1 || true
  else
    SHUX_KEEP_C=1 "$SHUX_BIN" $BACKEND_ARGS -L .. -o "$tmp_dir/try_${idx}.o" "$x_path" \
      >"$tmp_dir/shuxc_${idx}.log" 2>&1 || true
  fi
  # 优先：-o 已直接产出可用 .o（无 Arena64 冲突时）。
  # bare-impl 且无 -lib-name：
  #   - 产品 C 后端 -o/KEEP_C 常带路径前缀（std_crypto_core_*）→ 须 gen_c 剥前缀
  #   - 若 KEEP_C 完整则优先 C 路径；asm 裸 .o 仅作次选
  # 旧逻辑一律拒绝 direct .o 再走 -x -E，而 -E 对 preamble 在 ~20KiB 处截断 → crypto.o 假死。
  # bare-impl 子文件（core.x 等）：mod.x 以裸名 crypto_mem_eq_c 声明，
  # 产品 C 后端常仍 emit 路径前缀 std_crypto_core_*（即便 -lib-name "" / LIB_NAME_SUPPORTED）。
  # 必须剥前缀，否则 ld 得 U crypto_mem_eq_c 与 T std_crypto_core_crypto_mem_eq_c 双轨。
  bare_need_strip=0
  if [ "$base_name" != "mod.x" ] && [ "$BARE_IMPL" = "1" ]; then
    bare_need_strip=1
  fi
  # 先认 KEEP_C 完整源（-backend c 库模块常无 main → 链失败但 C 齐）
  kept0=$(ls -t /tmp/shux_shux_x.*.c 2>/dev/null | head -1)
  if [ -n "$kept0" ] && [ -f "$kept0" ] && [ -s "$kept0" ] && tail -c 80 "$kept0" | grep -q '}'; then
    cp "$kept0" "$gen_c"
    emit_ok=1
  fi
  if [ "$emit_ok" != "1" ] && [ -f "$tmp_dir/try_${idx}.o" ] && [ -s "$tmp_dir/try_${idx}.o" ]; then
    if [ "$bare_need_strip" = "1" ]; then
      strip_pref_probe=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|\.x$||' -e 's|/|_|g')
      has_prefixed=0
      if [ -n "$strip_pref_probe" ] && command -v nm >/dev/null 2>&1; then
        if nm "$tmp_dir/try_${idx}.o" 2>/dev/null | grep -q " T ${strip_pref_probe}_"; then
          has_prefixed=1
        fi
      fi
      if [ "$has_prefixed" != "1" ]; then
        # 已是裸符号（asm -o）或无可检测前缀：直接用 .o
        bare_need_strip=0
        use_direct_o=1
        emit_ok=1
        obj="$tmp_dir/try_${idx}.o"
      fi
      # has_prefixed=1：保留 bare_need_strip，走下方 KEEP_C / -E 剥前缀
    else
      use_direct_o=1
      emit_ok=1
      obj="$tmp_dir/try_${idx}.o"
    fi
  fi
  # mod.x 用户 API 须为 std_<module>_*（import 调用约定）。
  # 产品 Linux asm -o 常产裸名 mem_eq；objcopy 重命名为 std_crypto_mem_eq，与 mac C 路径对齐。
  if [ "$use_direct_o" = "1" ] && [ "$base_name" = "mod.x" ] \
     && [ -f "$obj" ] && command -v nm >/dev/null 2>&1; then
    mod_leaf=$(basename "$(dirname "$x_path")")
    case "$mod_leaf" in
      ''|.) mod_leaf=$(basename "$x_path" .x) ;;
    esac
    mod_pref="std_${mod_leaf}_"
    if [ -n "$mod_leaf" ] && ! nm "$obj" 2>/dev/null | grep -q " T ${mod_pref}"; then
      if command -v objcopy >/dev/null 2>&1; then
        nm "$obj" 2>/dev/null | awk '/ [TDB] / { print $3 }' | while IFS= read -r sym; do
          [ -n "$sym" ] || continue
          case "$sym" in
            "${mod_pref}"*) continue ;;
            _"${mod_pref}"*) continue ;;
            # 跳过 C 内部/编译器符号
            _Z*|.L*|L0*|__*) continue ;;
          esac
          # Mach-O 可能带前导 _
          bare="$sym"
          case "$sym" in
            _*) bare="${sym#_}" ;;
          esac
          case "$bare" in
            "${mod_pref}"*) continue ;;
          esac
          if [ "$bare" != "$sym" ]; then
            objcopy --redefine-sym "${sym}=_${mod_pref}${bare}" "$obj" 2>/dev/null || true
          else
            objcopy --redefine-sym "${sym}=${mod_pref}${bare}" "$obj" 2>/dev/null || true
          fi
        done
      fi
      if ! nm "$obj" 2>/dev/null | grep -q " T ${mod_pref}"; then
        # 重命名失败：放弃 direct .o，改走 C/KEEP_C 前缀路径
        use_direct_o=0
        emit_ok=0
        obj="$tmp_dir/mod_${idx}.o"
      fi
    fi
  fi
  if [ "$emit_ok" != "1" ]; then
    kept=$(ls -t /tmp/shux_shux_x.*.c 2>/dev/null | head -1)
    if [ -n "$kept" ] && [ -f "$kept" ] && [ -s "$kept" ]; then
      if tail -c 80 "$kept" | grep -q '}' ; then
        cp "$kept" "$gen_c"
        emit_ok=1
      fi
    fi
  fi
  # bare-impl 需剥前缀且无完整 C：再试 -backend c KEEP_C
  if [ "$emit_ok" != "1" ] && [ "$bare_need_strip" = "1" ]; then
    rm -f /tmp/shux_shux_x.*.c 2>/dev/null || true
    SHUX_KEEP_C=1 "$SHUX_BIN" -backend c -L .. -o "$tmp_dir/try_c_${idx}.o" "$x_path" \
      >"$tmp_dir/shuxc_c_${idx}.log" 2>&1 || true
    kept=$(ls -t /tmp/shux_shux_x.*.c 2>/dev/null | head -1)
    if [ -n "$kept" ] && [ -f "$kept" ] && [ -s "$kept" ]; then
      if tail -c 80 "$kept" | grep -q '}' ; then
        cp "$kept" "$gen_c"
        emit_ok=1
      fi
    fi
  fi
  if [ "$emit_ok" != "1" ]; then
    # 回退 -E：拒绝明显截断（尾部无 } 或半截 token）
    if [ "$base_name" != "mod.x" ] && [ "$BARE_IMPL" = "1" ] && [ "$LIB_NAME_SUPPORTED" = "1" ]; then
      if ! "$SHUX_BIN" -backend c -x -E -lib-name "" -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
        if ! "$SHUX_BIN" -x -E -lib-name "" -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
          echo "shux_compile_std_module.sh: -o and -x -E failed for $x_path" >&2
          cat "$tmp_dir/shuxc_${idx}.log" >&2
          exit 1
        fi
      fi
    else
      if ! "$SHUX_BIN" -backend c -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
        if ! "$SHUX_BIN" -x -E -L .. "$x_path" >"$gen_c" 2>"$tmp_dir/shuxc_${idx}.log"; then
          echo "shux_compile_std_module.sh: -o and -x -E failed for $x_path" >&2
          cat "$tmp_dir/shuxc_${idx}.log" >&2
          exit 1
        fi
      fi
    fi
    if [ -s "$gen_c" ] && tail -c 80 "$gen_c" | grep -q '}'; then
      # 拒绝半截 struct/标识符（历史 20KiB 截断）
      if ! tail -c 1 "$gen_c" | grep -q '[[:space:];}]' \
         && ! tail -c 40 "$gen_c" | grep -qE '([;}][[:space:]]*)$'; then
        echo "shux_compile_std_module.sh: -E output looks truncated for $x_path" >&2
        exit 1
      fi
      emit_ok=1
    elif [ -s "$gen_c" ]; then
      echo "shux_compile_std_module.sh: -E output incomplete (no closing brace) for $x_path" >&2
      exit 1
    fi
  fi
  # bare-impl：产品 x-pipeline 无 -lib-name 时，codegen 用路径导出前缀
  # （std/base64/base64.x → std_base64_base64_…）。mod.x 的 extern 是裸名
  # base64_encode_standard_c。在 gen_c 齐备后剥前缀（须在 -E 回退之后）。
  if [ "$bare_need_strip" = "1" ] && [ -f "$gen_c" ] && [ -s "$gen_c" ]; then
    strip_pref=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|\.x$||' -e 's|/|_|g')
    if [ -n "$strip_pref" ]; then
      perl -i -pe "s/\\b\Q${strip_pref}_\E//g" "$gen_c" 2>/dev/null || \
        sed -i.bak "s/${strip_pref}_//g" "$gen_c" 2>/dev/null || true
      dir_pref=$(printf '%s' "$x_path" | sed -e 's|^\.\./||' -e 's|/[^/]*$||' -e 's|/|_|g')
      if [ -n "$dir_pref" ] && [ "$dir_pref" != "$strip_pref" ]; then
        perl -i -pe "s/\\b\Q${dir_pref}_\E//g" "$gen_c" 2>/dev/null || \
          sed -i.bak "s/${dir_pref}_//g" "$gen_c" 2>/dev/null || true
      fi
      rm -f "${gen_c}.bak" 2>/dev/null || true
    fi
  fi
  # 已有直接 .o：跳过 gen_c 后处理与二次 cc
  if [ "$use_direct_o" = "1" ]; then
    if [ -z "$obj_files" ]; then
      obj_files="$obj"
    else
      obj_files="$obj_files $obj"
    fi
    idx=$((idx + 1))
    continue
  fi
  # 【Why 根源】-E 对跨模块 struct（如 heap_libc_Arena64）常只在「形参列表内」
  # 写出 `struct Foo`，未给文件级 forward。C 规定形参内的 struct 标签作用域仅限该
  # 声明 → 原型与定义各得一个不同 incomplete 类型 → conflicting types for 'fn'。
  # 在首个非预处理行前注入 `struct Foo;` 使整 TU 共享同一标签。
  # codegen 对 dep struct 正确 emit forward 后本段可删。
  if command -v perl >/dev/null 2>&1; then
    fwd_tmp="$tmp_dir/fwd_${idx}.h"
    perl -ne 'while (/struct\s+([A-Za-z_][A-Za-z0-9_]*)/g) { print "$1\n" if $1 ne "std_io_driver_Buffer" }' \
      "$gen_c" 2>/dev/null | sort -u >"$tmp_dir/structs_${idx}.txt" || true
    if [ -s "$tmp_dir/structs_${idx}.txt" ]; then
      : >"$fwd_tmp"
      while IFS= read -r sn; do
        [ -n "$sn" ] || continue
        # 已有完整定义或已有文件级 forward 则跳过
        if grep -E "struct[[:space:]]+${sn}[[:space:]]*[{;]" "$gen_c" >/dev/null 2>&1; then
          continue
        fi
        # 仅当只在形参/指针处出现（无 { 体）时补 forward
        if grep -E "struct[[:space:]]+${sn}[[:space:]]*\*" "$gen_c" >/dev/null 2>&1; then
          printf 'struct %s;\n' "$sn" >>"$fwd_tmp"
        fi
      done <"$tmp_dir/structs_${idx}.txt"
      # 双名对齐：entry 形参常 emit `struct heap_libc_Arena64`，dep 体为
      # `struct std_heap_libc_LibcArena64`。#define 标签别名使 `struct heap_libc_Arena64`
      # 展开为同一标签，避免 GCC 14 incompatible pointer types 当 error。
      if grep -q 'std_heap_libc_LibcArena64' "$gen_c" \
         && grep -q 'heap_libc_Arena64' "$gen_c"; then
        # 勿再 emit incomplete `struct heap_libc_Arena64;`（会与 #define 冲突）
        if [ -f "$fwd_tmp" ]; then
          grep -v '^struct heap_libc_Arena64;$' "$fwd_tmp" >"$fwd_tmp.f" 2>/dev/null || true
          mv "$fwd_tmp.f" "$fwd_tmp" 2>/dev/null || true
        fi
        printf '%s\n' \
          '/* shux_compile_std_module: Arena64 tag alias (import path vs short) */' \
          '#define heap_libc_Arena64 std_heap_libc_LibcArena64' \
          >>"$fwd_tmp"
      fi
      if [ -s "$fwd_tmp" ]; then
        # 插在最后一个 #include 之后；若无 include 则插文件首
        merged="$tmp_dir/gen_fwd_${idx}.c"
        if grep -q '^#include' "$gen_c"; then
          # 在最后一个 #include 行后插入
          awk -v fwd="$fwd_tmp" '
            /^#include/ { last=NR }
            { lines[NR]=$0 }
            END {
              for (i=1;i<=NR;i++) {
                print lines[i]
                if (i==last) {
                  while ((getline l < fwd) > 0) print l
                  close(fwd)
                }
              }
            }' "$gen_c" >"$merged" && mv "$merged" "$gen_c"
        else
          cat "$fwd_tmp" "$gen_c" >"$merged" && mv "$merged" "$gen_c"
        fi
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

# 【Why 根源】-x -E 对 std/*/mod.x 当前常产出裸符号 free/open/close 等，链入用户
# exe 后覆盖 libc 同名符号（hello 在 hash_sip_free_c↔free 无限递归 SIGSEGV）。
# 在 .o 落地后把与 libc 冲突的裸符号重命名为 std_<leaf>_*_api，避免污染。
# 与上方 pre-cc 改名双保险：若某路径未走 pre-cc（旧 gen）仍可后处理。
# 真前缀收敛后（codegen 对 entry 正确应用 path lib_name）本段可删。
if command -v nm >/dev/null 2>&1 && command -v objcopy >/dev/null 2>&1 && [ -f "$out_o" ]; then
  leaf=$(basename "$(dirname "$out_o")")
  case "$leaf" in
    ''|.) leaf=$(basename "$out_o" .o) ;;
  esac
  for clash in free open close malloc realloc calloc getcwd chdir pipe exit getenv setenv unsetenv getpid getppid waitpid exec; do
    if nm "$out_o" 2>/dev/null | grep -q " T ${clash}$"; then
      objcopy --redefine-sym "${clash}=std_${leaf}_${clash}_api" "$out_o" 2>/dev/null || true
    fi
  done
  # heap import-binding：impl 常产出裸 heap_alloc_c，用户/co-emit 与 http.o 等要
  # std_heap_libc_heap_alloc_c。只要 .o 有 T heap_alloc_c 且缺 std 前缀名就补别名
  # （勿仅依赖本 TU 的 U 引用——单文件 heap.o 落地时往往没有 U）。
  if nm "$out_o" 2>/dev/null | grep -q " T heap_alloc_c$" \
     && ! nm "$out_o" 2>/dev/null | grep -q " T std_heap_libc_heap_alloc_c$"; then
    alias_c="$tmp_dir/heap_alloc_alias.c"
    alias_o="$tmp_dir/heap_alloc_alias.o"
    printf '%s\n' \
      '#include <stddef.h>' \
      '#include <stdint.h>' \
      'extern uint8_t *heap_alloc_c(size_t size);' \
      'uint8_t *std_heap_libc_heap_alloc_c(size_t size) { return heap_alloc_c(size); }' \
      >"$alias_c"
    if cc -fPIE -c "$alias_c" -o "$alias_o" 2>/dev/null; then
      merged="$tmp_dir/heap_merged.o"
      if ld -r -o "$merged" "$out_o" "$alias_o" 2>/dev/null; then
        mv "$merged" "$out_o"
      fi
    fi
  fi
fi

echo "shux_compile_std_module.sh: OK ($idx files -> $out_o)"
