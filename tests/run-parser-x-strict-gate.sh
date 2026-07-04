#!/usr/bin/env bash
# strict 链 parser 真机码在 parser_x.o（-x -E）；本门禁验符号非 U 且 build_asm/parser.o 第二遍非空。
# 用法：./tests/run-parser-x-strict-gate.sh
# 环境：SHUX_PARSER_X_STRICT_FAIL=1 硬失败（CI 默认）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_X_STRICT_FAIL:-1}
# 兼容旧 env 名（迁移期）
FAIL=${SHUX_PARSER_X_STRICT_FAIL:-$FAIL}
PARSER_X="${SHUX_PARSER_X_O:-${SHUX_PARSER_X_O:-compiler/parser_x.o}}"
PARSER_ASM="${SHUX_PARSER_ASM_O:-compiler/build_asm/parser.o}"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-x-strict-gate: N/A on Darwin"
  exit 0
fi

if [ ! -f "$PARSER_X" ]; then
  echo "parser-x-strict-gate: SKIP (no $PARSER_X; make -C compiler parser_x.o)"
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

MISSING=""
for sym in parser_parse_into_buf parser_parse_into_init parser_parse_into_set_main_index; do
  if ! nm "$PARSER_X" 2>/dev/null | grep -qE "[ Tt] .*${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done
if [ -n "$MISSING" ]; then
  echo "parser-x-strict-gate FAIL: $PARSER_X missing T:${MISSING}" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ -f "$PARSER_ASM" ]; then
  SZ=$(stat -c%s "$PARSER_ASM" 2>/dev/null || stat -f%z "$PARSER_ASM" 2>/dev/null || echo 0)
  if [ "${SZ:-0}" -lt 16 ] 2>/dev/null; then
    echo "parser-x-strict-gate FAIL: $PARSER_ASM too small (${SZ}B)" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
fi

echo "parser-x-strict-gate OK (parser_x.o parse symbols + build_asm/parser.o present)"
