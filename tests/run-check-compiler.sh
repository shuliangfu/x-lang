#!/usr/bin/env bash
# shu check compiler/src：产品编译器树须能通过 C 前端 typeck（-L . -L compiler/src 由 driver 注入）。
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHULANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler shu-c 2>/dev/null || make -C compiler relink-shu
fi
SHU=${SHU:-./compiler/shu}
ROOT=$(pwd)
case "$SHU" in
  /*) SHU_EXE="$SHU" ;;
  *) SHU_EXE="$ROOT/$SHU" ;;
esac

# 分阶段门禁：先覆盖已稳定的编译器/核心模块（全量 compiler/src 仍有个别 import/折行待修）。
for f in \
  core/slice/mod.su \
  core/option/mod.su \
  compiler/asm_libroot/std/fs/mod.su \
  compiler/src/ast/ast.su \
  compiler/src/lexer/lexer.su \
  compiler/src/parser/parser.su \
  compiler/src/typeck/typeck.su \
  compiler/src/codegen/codegen.su \
  compiler/src/pipeline/pipeline.su \
  compiler/src/asm/asm.su \
  compiler/src/asm/backend.su \
  compiler/src/preprocess/preprocess.su \
  compiler/src/driver/compile.su \
  compiler/src/driver/fmt.su \
  compiler/src/driver/check.su
do
  out=$("$SHU_EXE" check "$f" 2>&1) || {
    echo "$out"
    echo "run-check-compiler: failed on $f"
    exit 1
  }
  if [ -n "$out" ]; then
    echo "expected silent check on $f, got: $out"
    exit 1
  fi
done
echo "check compiler/core subset OK (silent)"
