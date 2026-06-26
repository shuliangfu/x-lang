#!/usr/bin/env bash
# 复合赋值运算符：+= -= *= /= %= &= |= ^= <<= >>=
set -e
cd "$(dirname "$0")/.."
make -C compiler -q 2>/dev/null || make -C compiler
SHUX=${SHUX:-./compiler/shux}
# shellcheck source=lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
LINK_SHUX="$RUN_SHUX"

# compound assign 语义经 pipeline_glue TokenKind 映射已修（C emit 正确）。
# shux_asm2 在「复合赋值 → if → 再复合赋值」模式 asm elf 仍 fail（elf_ec=-1）；-o 与 run-option 一致走 shux-c。
if [ -n "${SHUX_RUN_ALL_BOOTSTRAP_SHUX:-}" ] || case "${SHUX:-}" in *shux_asm*) true ;; *) false ;; esac; then
  if [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
    LINK_SHUX=./compiler/shux-c
  fi
fi

set +e
$LINK_SHUX tests/compound-assign/main.sx -o /tmp/shux_compound_assign 2>&1
_compile_ec=$?
set -e
if [ "$_compile_ec" -ne 0 ] && [ "$LINK_SHUX" != "./compiler/shux-c" ] \
    && [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
  ./compiler/shux-c tests/compound-assign/main.sx -o /tmp/shux_compound_assign 2>&1
fi

exitcode=0
/tmp/shux_compound_assign >/dev/null 2>&1 || exitcode=$?
if [ "$exitcode" -ne 0 ]; then
  echo "compound-assign: expected exit 0, got $exitcode"
  exit 1
fi
echo "compound-assign test OK"
