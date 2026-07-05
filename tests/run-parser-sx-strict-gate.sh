#!/usr/bin/env bash
# strict 链 parser 真机码在 parser_sx.o（-sx -E）；本门禁验符号非 U 且 build_asm/parser.o 第二遍非空。
# 用法：./tests/run-parser-sx-strict-gate.sh
# 环境：SHUX_PARSER_SX_STRICT_FAIL=1 硬失败（CI 默认）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_SX_STRICT_FAIL:-1}
# 兼容旧 env 名（迁移期）
FAIL=${SHUX_PARSER_SX_STRICT_FAIL:-$FAIL}
PARSER_SX="${SHUX_PARSER_SX_O:-${SHUX_PARSER_SX_O:-compiler/parser_sx.o}}"
PARSER_ASM="${SHUX_PARSER_ASM_O:-compiler/build_asm/parser.o}"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-sx-strict-gate: N/A on Darwin"
  exit 0
fi

if [ ! -f "$PARSER_SX" ]; then
  echo "parser-sx-strict-gate: SKIP (no $PARSER_SX; make -C compiler parser_sx.o)"
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

MISSING=""
for sym in parser_parse_into_buf parser_parse_into_init parser_parse_into_set_main_index; do
  if ! nm "$PARSER_SX" 2>/dev/null | grep -qE "[ Tt] .*${sym}$"; then
    MISSING="${MISSING} ${sym}"
  fi
done
if [ -n "$MISSING" ]; then
  echo "parser-sx-strict-gate FAIL: $PARSER_SX missing T:${MISSING}" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ -f "$PARSER_ASM" ]; then
  SZ=$(stat -c%s "$PARSER_ASM" 2>/dev/null || stat -f%z "$PARSER_ASM" 2>/dev/null || echo 0)
  if [ "${SZ:-0}" -lt 16 ] 2>/dev/null; then
    echo "parser-sx-strict-gate FAIL: $PARSER_ASM too small (${SZ}B)" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
fi

echo "parser-sx-strict-gate OK (parser_sx.o parse symbols + build_asm/parser.o present)"
