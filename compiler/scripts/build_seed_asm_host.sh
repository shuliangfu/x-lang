#!/bin/sh
# build_seed_asm_host.sh — 用 shu-c -E 将 asm 后端编成宿主 .o，供 bootstrap-driver-seed 链入（无 weak 桩、无 runtime 回退）。
# 用法：在 compiler 目录 ./scripts/build_seed_asm_host.sh
# 依赖：./shu-c（make shu-c）

set -e
cd "$(dirname "$0")/.."
OUT_DIR=build_asm/seed_host
mkdir -p "$OUT_DIR"

SHU_E=./shu-c
if [ ! -x "$SHU_E" ]; then
  echo "build_seed_asm_host: 缺少 ./shu-c，请先 make shu-c" >&2
  exit 1
fi

CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -I. -Iinclude -Isrc -Wno-unused-variable -Wno-unused-parameter -Wno-unused-function -Wno-logical-op-parentheses -Wno-sign-compare"

LIB_ASM="-L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/asm -L src/preprocess -L src/pipeline -L src/codegen"

dedupe_slice() {
  perl -i -ne 'print unless /^struct shulang_slice_uint8_t/ && $seen++' "$1" 2>/dev/null || true
}

# asm.su 全量 -E：ld -r 仅导出 backend/peephole/platform 入口，避免与 pipeline_su.o / codegen_su.o 重复符号
ASM_FULL_C="$OUT_DIR/asm_full_gen.c"
ASM_FULL_O="$OUT_DIR/asm_full.o"
BACKEND_PARTIAL="$OUT_DIR/asm_backend_partial.o"
SYMS="$OUT_DIR/asm_backend_export.txt"

if [ ! -f "$BACKEND_PARTIAL" ] || [ "$ASM_FULL_C" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/asm.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/backend.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/arm64_enc.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/arm64.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/x86_64_enc.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/x86_64.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/riscv64_enc.su" -nt "$BACKEND_PARTIAL" ] || [ "src/asm/arch/riscv64.su" -nt "$BACKEND_PARTIAL" ]; then
  echo "build_seed_asm_host: asm.su 全量 -E ..."
  ASM_TMP="$OUT_DIR/asm_full_gen.c.tmp"
  # 须全量 -E（勿 -E-extern：仅 ~100 行 typeck/asm 桩，缺 backend/peephole/platform，cc 失败或沿用陈旧 x86_64 partial.o）。
  if ! "$SHU_E" $LIB_ASM -E src/asm/asm.su >"$ASM_TMP" 2>/dev/null; then
    if [ -f "$BACKEND_PARTIAL" ]; then
      echo "build_seed_asm_host: asm.su -E 失败，沿用已有 $BACKEND_PARTIAL" >&2
      rm -f "$ASM_TMP"
      exit 0
    fi
    rm -f "$ASM_TMP"
    echo "build_seed_asm_host: asm.su -E 失败且无已有 $BACKEND_PARTIAL" >&2
    exit 1
  fi
  mv -f "$ASM_TMP" "$ASM_FULL_C"
  dedupe_slice "$ASM_FULL_C"
  perl scripts/fix_slim_arena_gen_c.pl "$ASM_FULL_C"
  # shu-c -E 偶发插入自递归 stub，保留下方多 arch 真实现。
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
  nm "$ASM_FULL_O" | awk '/ T _backend_/ || / T _peephole_/ || / T _platform_elf/ || / T _platform_macho/ || / T _platform_coff/' \
    | awk '{print $3}' | sort -u >"$SYMS"
  for _extra in _arch_arm64_enc_enc_mov_imm32_to_w0 _arch_arm64_enc_enc_sub_rax_rbx \
      _arch_x86_64_enc_enc_ret_imm32 _arch_riscv64_enc_enc_ret_imm32; do
    if nm "$ASM_FULL_O" | awk -v s="$_extra" '$3==s {found=1} END{exit !found}'; then
      echo "$_extra" >>"$SYMS"
    fi
  done
  sort -u -o "$SYMS" "$SYMS"
  if ! grep -q '^_backend_asm_codegen_ast$' "$SYMS"; then
    echo "build_seed_asm_host: $ASM_FULL_O 缺少 _backend_asm_codegen_ast" >&2
    exit 1
  fi
  echo "  ld -r partial ($(wc -l <"$SYMS" | tr -d ' ') syms) -> $BACKEND_PARTIAL"
  if ! ld -r -exported_symbols_list "$SYMS" -o "$BACKEND_PARTIAL" "$ASM_FULL_O"; then
    if [ -f "$BACKEND_PARTIAL" ]; then
      echo "build_seed_asm_host: ld -r 失败，沿用已有 $BACKEND_PARTIAL" >&2
      exit 0
    fi
    echo "build_seed_asm_host: ld -r 失败且无已有 $BACKEND_PARTIAL" >&2
    exit 1
  fi
fi

echo "build_seed_asm_host OK ($OUT_DIR)"
