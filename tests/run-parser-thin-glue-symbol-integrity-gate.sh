#!/usr/bin/env bash
# parser_asm_thin_glue.o 符号完整性门禁：校验关键 C glue / stretch 符号存在，不依赖体积 ratchet。
# 用法：
#   ./tests/run-parser-thin-glue-symbol-integrity-gate.sh
#   SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL=1 ./tests/run-parser-thin-glue-symbol-integrity-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_THIN_GLUE_SYMBOL_INTEGRITY_FAIL:-0}
BASELINE="${SHUX_PARSER_THIN_GLUE_SYMBOL_BASELINE:-tests/baseline/parser-thin-glue-symbols.tsv}"
THIN_SRC="compiler/src/asm/parser_asm_thin_c.inc"
GLUE_OBJ="compiler/parser_asm_thin_glue.o"
NM_LIST="/tmp/shux_parser_thin_glue_syms.$$.txt"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-thin-glue-symbol-integrity-gate: N/A on Darwin"
  exit 0
fi

if [ ! -f "$THIN_SRC" ]; then
  echo "parser-thin-glue-symbol-integrity-gate: SKIP (missing $THIN_SRC)"
  exit 0
fi

if ! command -v cc >/dev/null 2>&1 || ! command -v nm >/dev/null 2>&1; then
  echo "parser-thin-glue-symbol-integrity-gate: SKIP (need cc and nm)"
  exit 0
fi

if [ ! -f "$GLUE_OBJ" ] || [ "$THIN_SRC" -nt "$GLUE_OBJ" ]; then
  echo "parser-thin-glue-symbol-integrity-gate: cc -c $THIN_SRC -> $GLUE_OBJ"
  cc -Wall -Icompiler -Icompiler/include -Icompiler/src -Icompiler/src/lexer \
    -c -o "$GLUE_OBJ" "$THIN_SRC"
fi

# 提取 thin_glue.o 中已定义的全局符号（linux/amd64 GNU nm）。
nm -g --defined-only "$GLUE_OBJ" 2>/dev/null | awk '{print $3}' | sort -u >"$NM_LIST"

GATE_FAIL=0
MISSING=0

if [ ! -f "$BASELINE" ]; then
  echo "parser-thin-glue-symbol-integrity-gate FAIL: missing baseline $BASELINE" >&2
  rm -f "$NM_LIST" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

MIN_STRETCH=$(awk -F'\t' '$1=="min_stretch_defined" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)
MIN_GLUE=$(awk -F'\t' '$1=="min_glue_defined" && $1 !~ /^#/ { print $2; exit }' "$BASELINE" 2>/dev/null)

STRETCH_CNT=$(grep -c '^parser_asm_stretch_' "$NM_LIST" 2>/dev/null || echo 0)
GLUE_CNT=$(grep -c '_glue$' "$NM_LIST" 2>/dev/null || echo 0)

if [ -n "$MIN_STRETCH" ] && [ "${STRETCH_CNT:-0}" -lt "$MIN_STRETCH" ] 2>/dev/null; then
  echo "parser-thin-glue-symbol-integrity-gate FAIL: stretch_defined=${STRETCH_CNT} < min ${MIN_STRETCH}" >&2
  GATE_FAIL=1
fi
if [ -n "$MIN_GLUE" ] && [ "${GLUE_CNT:-0}" -lt "$MIN_GLUE" ] 2>/dev/null; then
  echo "parser-thin-glue-symbol-integrity-gate FAIL: glue_defined=${GLUE_CNT} < min ${MIN_GLUE}" >&2
  GATE_FAIL=1
fi

while IFS=$'\t' read -r kind sym _rest; do
  [ "$kind" = "symbol" ] || continue
  [ -n "$sym" ] || continue
  if ! grep -qx "$sym" "$NM_LIST" 2>/dev/null; then
    echo "parser-thin-glue-symbol-integrity-gate FAIL: missing symbol $sym" >&2
    MISSING=$((MISSING + 1))
    GATE_FAIL=1
  fi
done <"$BASELINE"

rm -f "$NM_LIST" 2>/dev/null || true

if [ "$GATE_FAIL" -eq 1 ]; then
  echo "parser-thin-glue-symbol-integrity-gate FAIL: missing=${MISSING} stretch=${STRETCH_CNT} glue=${GLUE_CNT}" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "parser-thin-glue-symbol-integrity-gate OK (required symbols present, stretch=${STRETCH_CNT}, glue=${GLUE_CNT})"
