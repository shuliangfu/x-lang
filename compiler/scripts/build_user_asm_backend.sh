#!/bin/sh
# build_user_asm_backend.sh — 为 bootstrap seed shu 准备 build_asm 用户程序 asm 最小 .o 集
# 用法：在 compiler 目录 ./scripts/build_user_asm_backend.sh
# 依赖：./shu_asm（优先）或 ./shu；与 build_shu_asm.sh 的 LIBROOT 一致。

set -e
cd "$(dirname "$0")/.."
BUILD_DIR=build_asm
mkdir -p "$BUILD_DIR"

TAB=$(printf '\t')
LIBROOT=""
if [ -f src/asm/asm_build_list.su ]; then
  LIBROOT=$(grep '^// LIBROOT:' src/asm/asm_build_list.su | sed "s|^// LIBROOT:${TAB}||")
fi
[ -z "$LIBROOT" ] && LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

SHU=./shu_asm
if [ ! -x "$SHU" ]; then
  SHU=./shu
fi
if [ ! -x "$SHU" ]; then
  echo "build_user_asm_backend: 无 ./shu_asm 或 ./shu，跳过（须先 make bootstrap-driver-seed）" >&2
  exit 0
fi

compile_one() {
  out="$BUILD_DIR/$1"
  src="$2"
  if [ -f "$out" ] && [ "$out" -nt "$src" ]; then
    echo "  skip $out (up to date)"
    return 0
  fi
  echo "  $SHU -backend asm -> $out ($src)"
  if env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 \
    "$SHU" -backend asm -o "$out" $LIBROOT "$src"; then
    return 0
  fi
  echo "build_user_asm_backend: 编译 $src 失败" >&2
  return 1
}

echo "build_user_asm_backend: SHU=$SHU"
compile_one types.o src/asm/types.su
compile_one platform_elf.o src/asm/platform/elf.su
compile_one arm64.o src/asm/arch/arm64.su
compile_one arm64_enc.o src/asm/arch/arm64_enc.su
compile_one peephole.o src/asm/peephole.su
compile_one macho.o src/asm/platform/macho.su
compile_one backend.o src/asm/backend.su

echo "build_user_asm_backend OK (USER_ASM_LINK 可用)"
