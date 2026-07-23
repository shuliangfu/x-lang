#!/usr/bin/env bash
# xlang check compiler/src：产品编译器树须能通过 C 前端 typeck（-L . -L compiler/src 由 driver 注入）。
set -e
cd "$(dirname "$0")/.."
if [ -z "${XLANG_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler xlang-c 2>/dev/null || make -C compiler relink-xlang
fi
XLANG=${XLANG:-./compiler/xlang}
ROOT=$(pwd)
case "$XLANG" in
  /*) XLANG_EXE="$XLANG" ;;
  *) XLANG_EXE="$ROOT/$XLANG" ;;
esac

# 分阶段门禁：先覆盖已稳定的编译器/核心模块（全量 compiler/src 仍有个别 import/折行待修）。
for f in \
  core/slice/mod.x \
  core/option/mod.x \
  compiler/asm_libroot/std/fs/mod.x \
  compiler/src/ast/ast.x \
  compiler/src/lexer/lexer.x \
  compiler/src/parser/parser.x \
  compiler/src/typeck/typeck.x \
  compiler/src/codegen/codegen.x \
  compiler/src/pipeline/pipeline.x \
  compiler/src/asm/asm.x \
  compiler/src/asm/backend.x \
  compiler/src/preprocess/preprocess.x \
  compiler/src/driver/compile.x \
  compiler/src/driver/fmt.x \
  compiler/src/driver/check.x
do
  out=$("$XLANG_EXE" check "$f" 2>&1) || {
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
