#!/usr/bin/env bash
# shux check compiler/src：产品编译器树须能通过 C 前端 typeck（-L . -L compiler/src 由 driver 注入）。
set -e
cd "$(dirname "$0")/.."
if [ -z "${SHUX_SKIP_SUBSCRIPT_MAKE:-}" ]; then
  make -C compiler -q 2>/dev/null || make -C compiler shux-c 2>/dev/null || make -C compiler relink-shux
fi
SHUX=${SHUX:-./compiler/shux}
ROOT=$(pwd)
case "$SHUX" in
  /*) SHUX_EXE="$SHUX" ;;
  *) SHUX_EXE="$ROOT/$SHUX" ;;
esac

# 分阶段门禁：先覆盖已稳定的编译器/核心模块（全量 compiler/src 仍有个别 import/折行待修）。
for f in \
  core/slice/mod.sx \
  core/option/mod.sx \
  compiler/asm_libroot/std/fs/mod.sx \
  compiler/src/ast/ast.sx \
  compiler/src/lexer/lexer.sx \
  compiler/src/parser/parser.sx \
  compiler/src/typeck/typeck.sx \
  compiler/src/codegen/codegen.sx \
  compiler/src/pipeline/pipeline.sx \
  compiler/src/asm/asm.sx \
  compiler/src/asm/backend.sx \
  compiler/src/preprocess/preprocess.sx \
  compiler/src/driver/compile.sx \
  compiler/src/driver/fmt.sx \
  compiler/src/driver/check.sx
do
  out=$("$SHUX_EXE" check "$f" 2>&1) || {
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
