#!/bin/sh
# build_seed_asm_host.sh — 用 shux-c -E 将 asm 后端编成宿主 .o，供 bootstrap-driver-seed 链入（无 weak 桩、无 runtime 回退）。
# 用法：在 compiler 目录 ./scripts/build_seed_asm_host.sh
# 依赖：./shux-c（make shux-c）

set -e
cd "$(dirname "$0")/.."
OUT_DIR=build_asm/seed_host
mkdir -p "$OUT_DIR"

SHUX_E=./shux-c
if [ ! -x "$SHUX_E" ]; then
  echo "build_seed_asm_host: 缺少 ./shux-c，请先 make shux-c" >&2
  exit 1
fi

CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-sign-compare"
if $CC --version 2>/dev/null | grep -qi clang; then
  CFLAGS="$CFLAGS -Wno-logical-op-parentheses"
fi

LIB_ASM="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -L src/pipeline -L src/codegen"

dedupe_slice() {
  perl -i -ne 'print unless /^struct shux_slice_uint8_t/ && $seen++' "$1" 2>/dev/null || true
}

# Mach-O nm 带前导 _；ELF (Linux/Alpine) 不带。统一检测符号是否存在。
has_nm_sym() {
  _obj="$1"
  _want="$2"
  _bare="${_want#_}"
  nm "$_obj" 2>/dev/null | awk -v w="$_bare" '{
    s = $3
    sub(/^_/, "", s)
    if (s == w) found = 1
  } END { exit !found }'
}

# 从 .o 收集 backend/peephole/platform 导出符号名（保留 nm 原样：Darwin 带 _，ELF 不带）。
collect_backend_export_syms() {
  _obj="$1"
  _out="$2"
  nm "$_obj" | awk '/ T / {
    s=$3
    if (s ~ /^_?(backend_|peephole_|platform_elf|platform_macho|platform_coff)/) print s
  }' | sort -u >"$_out"
}

# GNU ld -r + version script 不会把未列出符号降为 local；objcopy 逐个 localize，避免与 seed 其它 .o 重复定义。
localize_elf_partial_non_exported() {
  _out_o="$1"
  _syms="$2"
  command -v objcopy >/dev/null 2>&1 || return 0
  nm "$_out_o" 2>/dev/null | awk '/ T / {print $3}' | while read -r _sym; do
    [ -z "$_sym" ] && continue
    _bare="${_sym#_}"
    if grep -qxF "$_sym" "$_syms" 2>/dev/null || grep -qxF "$_bare" "$_syms" 2>/dev/null; then
      continue
    fi
    objcopy --localize-symbol="$_bare" "$_out_o" 2>/dev/null || objcopy --localize-symbol="$_sym" "$_out_o" 2>/dev/null || true
  done
}

# 按宿主 ld 能力做 partial export：Darwin -exported_symbols_list；GNU ld --version-script。
ld_partial_export() {
  _syms="$1"
  _out_o="$2"
  _in_o="$3"
  _ver="$OUT_DIR/asm_backend_export.ver"
  if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
    # Mach-O：符号表须带前导 _
    _macho_syms="$OUT_DIR/asm_backend_export_macho.txt"
    : >"$_macho_syms"
    while read -r _s; do
      [ -z "$_s" ] && continue
      case "$_s" in _*) echo "$_s" >>"$_macho_syms" ;; *) echo "_$_s" >>"$_macho_syms" ;; esac
    done < "$_syms"
    ld -r -exported_symbols_list "$_macho_syms" -o "$_out_o" "$_in_o"
    return $?
  fi
  # GNU ld (Alpine/Linux)：version script 标记 global；再 objcopy 把其余 T 符号降为 local
  {
    echo "{"
    echo "  global:"
    while read -r _s; do
      [ -z "$_s" ] && continue
      echo "    ${_s#_};"
    done < "$_syms"
    echo "  local: *;"
    echo "};"
  } >"$_ver"
  ld -r --version-script="$_ver" -o "$_out_o" "$_in_o"
  localize_elf_partial_non_exported "$_out_o" "$_syms"
}

# asm.sx 全量 -E：ld -r 仅导出 backend/peephole/platform 入口，避免与 pipeline_sx.o / codegen_su.o 重复符号
ASM_FULL_C="$OUT_DIR/asm_full_gen.c"
ASM_FULL_O="$OUT_DIR/asm_full.o"
BACKEND_PARTIAL="$OUT_DIR/asm_backend_partial.o"
SYMS="$OUT_DIR/asm_backend_export.txt"

if [ ! -f "$BACKEND_PARTIAL" ] || [ "$ASM_FULL_C" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/asm.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/backend.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/peephole.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/platform/elf.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/arm64_enc.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/arm64.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/x86_64_enc.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/x86_64.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/riscv64_enc.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/riscv64.sx" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/backend_enc_dispatch.o" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/backend_arch_emit_dispatch.o" -nt "$BACKEND_PARTIAL" ]; then
  echo "build_seed_asm_host: asm.sx 全量 -E ..."
  ASM_TMP="$OUT_DIR/asm_full_gen.c.tmp"
  # 须全量 -E（勿 -E-extern：仅 ~100 行 typeck/asm 桩，缺 backend/peephole/platform，cc 失败或沿用陈旧 x86_64 partial.o）。
  if ! "$SHUX_E" $LIB_ASM -E src/asm/asm.sx >"$ASM_TMP" 2>"$OUT_DIR/asm_full_gen.err"; then
    if [ -s "$OUT_DIR/asm_full_gen.err" ]; then
      tail -20 "$OUT_DIR/asm_full_gen.err" >&2
    fi
    if [ -f "$BACKEND_PARTIAL" ]; then
      echo "build_seed_asm_host: asm.sx -E 失败，沿用已有 $BACKEND_PARTIAL" >&2
      rm -f "$ASM_TMP"
      exit 0
    fi
    rm -f "$ASM_TMP"
    echo "build_seed_asm_host: asm.sx -E 失败且无已有 $BACKEND_PARTIAL" >&2
    exit 1
  fi
  mv -f "$ASM_TMP" "$ASM_FULL_C"
  dedupe_slice "$ASM_FULL_C"
  perl scripts/fix_slim_arena_gen_c.pl "$ASM_FULL_C"
  perl scripts/fix_backend_enc_recursive_gen_c.pl "$ASM_FULL_C"
  # shux-c -E 偶发插入自递归 stub，保留下方多 arch 真实现。
  perl -i -0777 -pe 's/int32_t backend_enc_lea_rbp_to_rax_arch\(struct platform_elf_ElfCodegenCtx \* elf_ctx, int32_t offset, int32_t ta\) \{\n  return backend_enc_lea_rbp_to_rax_arch\(elf_ctx, offset, ta\);\n\}\n//s' "$ASM_FULL_C" 2>/dev/null || true
  if ! $CC $CFLAGS -c "$ASM_FULL_C" -o "$ASM_FULL_O"; then
    if [ -f "$BACKEND_PARTIAL" ]; then
      echo "build_seed_asm_host: cc asm_full_gen.c 失败，沿用已有 $BACKEND_PARTIAL" >&2
      exit 0
    fi
    echo "build_seed_asm_host: cc asm_full_gen.c 失败且无已有 $BACKEND_PARTIAL" >&2
    exit 1
  fi
  # 从 asm_full.o 导出 backend_/peephole_/platform_{elf,macho,coff}_*，供 codegen_su.o 与 seed bridge 解析。
  # 剔除 backend_*_dispatch.c 已提供的符号，避免与 USER_ASM_LINK 重复定义（须四份 dispatch .o 均已编译）。
  collect_backend_export_syms "$ASM_FULL_O" "$SYMS"
  : >"$OUT_DIR/asm_dispatch_syms.txt"
  for _dof in src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o \
              src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o \
              src/asm/pipeline_abi_f32_xmm.o; do
    if [ ! -f "$_dof" ]; then
      echo "build_seed_asm_host: missing $_dof (make bootstrap-driver-seed 须先编 dispatch TU)" >&2
      exit 1
    fi
    nm "$_dof" 2>/dev/null \
      | awk '/ T / && $3 ~ /^_?(backend_|arch_|pipeline_asm_abi|pipeline_asm_emit)/ {print $3}' >>"$OUT_DIR/asm_dispatch_syms.txt"
  done
  sort -u -o "$OUT_DIR/asm_dispatch_syms.txt" "$OUT_DIR/asm_dispatch_syms.txt"
  if [ -s "$OUT_DIR/asm_dispatch_syms.txt" ]; then
    grep -v -F -f "$OUT_DIR/asm_dispatch_syms.txt" "$SYMS" >"$SYMS.tmp" || true
    mv -f "$SYMS.tmp" "$SYMS"
  fi
  for _extra in arch_arm64_enc_enc_mov_imm32_to_w0 arch_arm64_enc_enc_sub_rax_rbx \
      arch_x86_64_enc_enc_ret_imm32 arch_riscv64_enc_enc_ret_imm32; do
    if has_nm_sym "$ASM_FULL_O" "$_extra"; then
      echo "$_extra" >>"$SYMS"
    fi
  done
  # backend_enc_dispatch.c 依赖 arch_*_enc_enc_*，backend_arch_emit_dispatch.c 依赖 arch_*_emit_*。
  nm "$ASM_FULL_O" | awk '/ T / && $3 ~ /^_?arch_(arm64|x86_64|riscv64)_enc_enc_/ {print $3}' >>"$SYMS"
  nm "$ASM_FULL_O" | awk '/ T / && $3 ~ /^_?arch_(arm64|x86_64|riscv64)_emit_/ {print $3}' >>"$SYMS"
  sort -u -o "$SYMS" "$SYMS"
  # dispatch .o 已提供的 arch_*（如 enc_cdqe_rax）勿再从 partial 导出，避免重复定义。
  if [ -s "$OUT_DIR/asm_dispatch_syms.txt" ]; then
    grep -v -F -f "$OUT_DIR/asm_dispatch_syms.txt" "$SYMS" >"$SYMS.tmp" || cp "$SYMS" "$SYMS.tmp"
    mv -f "$SYMS.tmp" "$SYMS"
  fi
  if ! has_nm_sym "$ASM_FULL_O" "backend_asm_codegen_ast_seed_mega"; then
    echo "build_seed_asm_host: $ASM_FULL_O 缺少 backend_asm_codegen_ast_seed_mega" >&2
    exit 1
  fi
  echo "  ld partial export ($(wc -l <"$SYMS" | tr -d ' ') syms) -> $BACKEND_PARTIAL"
  if ! ld_partial_export "$SYMS" "$BACKEND_PARTIAL" "$ASM_FULL_O"; then
    if [ -f "$BACKEND_PARTIAL" ]; then
      echo "build_seed_asm_host: ld -r 失败，沿用已有 $BACKEND_PARTIAL" >&2
      exit 0
    fi
    echo "build_seed_asm_host: ld -r 失败且无已有 $BACKEND_PARTIAL" >&2
    exit 1
  fi
fi

echo "build_seed_asm_host OK ($OUT_DIR)"
