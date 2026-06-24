#!/usr/bin/env bash
# parser_parse_bootstrap.o 轨道门禁：C seed slice 独立 TU 须导出 parse_into_buf（替代 SX PARSE_BOOTSTRAP_EMIT 139）。
# 用法：
#   ./tests/run-parser-parse-bootstrap-gate.sh
#   SHUX_PARSER_PARSE_BOOTSTRAP_FAIL=1 ./tests/run-parser-parse-bootstrap-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_PARSE_BOOTSTRAP_FAIL:-0}
CC=${CC:-cc}
CFLAGS="-Wall -Wextra -Icompiler -Icompiler/include -Icompiler/src"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-parse-bootstrap-gate: N/A on Darwin"
  exit 0
fi

BOOT_SRC="compiler/src/asm/parser_asm_parse_bootstrap_obj.c"
BOOT_O="/tmp/shux_parser_parse_bootstrap_gate.$$.o"
rm -f "$BOOT_O" 2>/dev/null || true

echo "parser-parse-bootstrap-gate: cc parser_asm_parse_bootstrap_obj.c ..."
if ! $CC $CFLAGS -c -o "$BOOT_O" "$BOOT_SRC" > /tmp/shux_parser_boot_gate.log 2>&1; then
  echo "parser-parse-bootstrap-gate FAIL: cc compile" >&2
  tail -n 12 /tmp/shux_parser_boot_gate.log 2>/dev/null || true
  rm -f "$BOOT_O" /tmp/shux_parser_boot_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! nm -g "$BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
  echo "parser-parse-bootstrap-gate FAIL: missing global parse_into_buf" >&2
  nm -g "$BOOT_O" 2>/dev/null | grep -E 'parse_into' || true
  rm -f "$BOOT_O" /tmp/shux_parser_boot_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if ! nm -g "$BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parser_parse_into_buf$'; then
  echo "parser-parse-bootstrap-gate FAIL: missing global parser_parse_into_buf" >&2
  rm -f "$BOOT_O" /tmp/shux_parser_boot_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TEXT=$(objdump -h "$BOOT_O" 2>/dev/null | awk '/\.text/ {print $3; exit}')
TEXT_DEC=0
if [ -n "$TEXT" ]; then
  TEXT_DEC=$((16#$TEXT))
fi
MIN_TEXT=${SHUX_PARSER_PARSE_BOOTSTRAP_MIN_TEXT:-512}
if [ "$TEXT_DEC" -lt "$MIN_TEXT" ]; then
  echo "parser-parse-bootstrap-gate FAIL: .text=$TEXT_DEC < min=$MIN_TEXT" >&2
  rm -f "$BOOT_O" /tmp/shux_parser_boot_gate.log 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "parser-parse-bootstrap-gate PASS: parse_into_buf .text=${TEXT_DEC}B"
rm -f "$BOOT_O" /tmp/shux_parser_boot_gate.log 2>/dev/null || true
exit 0
