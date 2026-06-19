#!/usr/bin/env bash
# 文件职责：阶段 1 词法测试——对 tests/lexer/main.sx 运行 shux，将输出与 tests/lexer/expected.txt 逐行比对。
# 与其它文件的关系：由 compiler/Makefile 的 test 目标调用；依赖 compiler/shux、tests/lexer/main.sx、tests/lexer/expected.txt。
# 使用 shux-c（C 版编译器）以保证无 -o 时输出 token 列表 + parse/typeck OK；若当前 shux 为 pipeline 版则无该行为。
# 当 SHU 已设置（test_sx/run-all-sx）时仅用 compiler/shux（shux_sx），不构建 shux-c，并跳过依赖 token 输出的比对。

set -e
cd "$(dirname "$0")/.."
if [ -n "$SHUX" ]; then
  # test_c 传 SHUX=./compiler/shux-c 时用其跑负例；test_sx 传 SHUX=./compiler/shux 时用 shux_sx
  LEXER_SHUX="$SHUX"
  out=$(mktemp)
  # bootstrap-driver-seed / stage 的 shux 走 .sx 单文件 -o 时可能不跑完整 C 前端，lexer 负例会误成功；有 shux-c 时非法字符负例仍用 shux-c，与 Makefile test_c 一致。
  NEG_SHUX="$SHUX"
  if [ -x ./compiler/shux-c ] && [ "${SHUX##*/}" != "shux-c" ]; then
    NEG_SHUX=./compiler/shux-c
  fi
  "$NEG_SHUX" tests/lexer/invalid_char.sx -o /tmp/shux_lexer_fail 2>/dev/null && { echo "lexer: expected compile failure for invalid char"; exit 1; }
  rm -f "$out"
else
  make -C compiler shux-c 2>/dev/null || true
  if [ -f ./compiler/shux-c ]; then
    LEXER_SHUX=./compiler/shux-c
  else
    make -C compiler
    LEXER_SHUX=./compiler/shux
  fi
  out=$(mktemp)
  "$LEXER_SHUX" tests/lexer/main.sx > "$out"
  diff -u --strip-trailing-cr tests/lexer/expected.txt "$out" || exit 1
  "$LEXER_SHUX" tests/lexer/comments.sx > "$out"
  diff -u --strip-trailing-cr tests/lexer/expected-comments.txt "$out" || exit 1
  rm -f "$out"
  "$LEXER_SHUX" tests/lexer/invalid_char.sx -o /tmp/shux_lexer_fail 2>/dev/null && { echo "lexer: expected compile failure for invalid char"; exit 1; }
fi
echo "lexer test OK"
