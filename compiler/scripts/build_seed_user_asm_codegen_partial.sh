#!/bin/sh
# build_seed_user_asm_codegen_partial.sh — 从 gen_driver/pipeline_x.o 抽出 asm 四入口，供 seed shux 链入（无需 cp shux_asm）
# 用法：在 compiler 目录执行；须先有 build_asm/gen_driver/pipeline_x.o（含 backend_asm_codegen_ast T 符号）。
# 通常由 SHUX=./shux ./scripts/build_shux_asm.sh 一次产出；或 shux-c -E pipeline.x 编出大 pipeline_x.o 后复制到 gen_driver/。

set -e
cd "$(dirname "$0")/.."
BUILD_DIR=build_asm
GEN_SUO="$BUILD_DIR/gen_driver/pipeline_x.o"
PARTIAL="$BUILD_DIR/pipeline_asm_codegen_only_partial.o"
SYMS="$BUILD_DIR/pipeline_asm_codegen_only_export.txt"
PLATFORM_OBJS="build_asm/platform_elf.o build_asm/macho.o build_asm/arm64.o build_asm/arm64_enc.o build_asm/types.o build_asm/peephole.o"

if [ ! -f "$GEN_SUO" ]; then
  echo "build_seed_user_asm_codegen_partial: 缺少 $GEN_SUO（先运行 build_shux_asm 或 make gen-x-driver-objs 并复制大 pipeline_x.o）" >&2
  exit 1
fi

if ! nm "$GEN_SUO" 2>/dev/null | grep -q ' T _backend_asm_codegen_ast'; then
  echo "build_seed_user_asm_codegen_partial: $GEN_SUO 无 T _backend_asm_codegen_ast（当前为 -E-extern 瘦 pipeline，须用 shux-c -E 全量 pipeline 或 build_shux_asm）" >&2
  exit 1
fi

cat > "$SYMS" <<'EOF'
_asm_asm_codegen_ast
_asm_asm_codegen_elf_o
_backend_asm_codegen_ast
_backend_asm_codegen_ast_to_elf
EOF

echo "  ld -r -exported_symbols_list $SYMS -> $PARTIAL"
ld -r -exported_symbols_list "$SYMS" -o "$PARTIAL" "$GEN_SUO"

# 平台 .o 供 elf_o 路径（若缺失则尝试 build_user_asm_backend.sh）
for o in $PLATFORM_OBJS; do
  if [ ! -f "$o" ]; then
    echo "build_seed_user_asm_codegen_partial: 缺少 $o，运行 scripts/build_user_asm_backend.sh ..."
  fi
done
if [ -x ./shux_asm ] || [ -x ./shux ]; then
  ./scripts/build_user_asm_backend.sh 2>/dev/null || true
fi

echo "build_seed_user_asm_codegen_partial OK: $PARTIAL"
