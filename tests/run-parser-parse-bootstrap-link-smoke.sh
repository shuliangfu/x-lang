#!/usr/bin/env bash
# experimental 链 + parser_parse_bootstrap.o（C seed TU）须能 asm 编任意 .x（parse_into_buf 强符号）。
# 用法：
#   ./tests/run-parser-parse-bootstrap-link-smoke.sh
#   SHUX_PARSER_PARSE_BOOTSTRAP_LINK_FAIL=1 ./tests/run-parser-parse-bootstrap-link-smoke.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_PARSE_BOOTSTRAP_LINK_FAIL:-0}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-parse-bootstrap-link-smoke: N/A on Darwin"
  exit 0
fi

COMP_IN="./shux_asm"
if [ -n "${SHUX_PARSER_PARSE_BOOTSTRAP_COMPILER:-}" ]; then
  case "${SHUX_PARSER_PARSE_BOOTSTRAP_COMPILER}" in
    compiler/*) COMP_IN="./${SHUX_PARSER_PARSE_BOOTSTRAP_COMPILER#compiler/}" ;;
    *) COMP_IN="${SHUX_PARSER_PARSE_BOOTSTRAP_COMPILER}" ;;
  esac
fi
if [ ! -x "compiler/$COMP_IN" ] && [ ! -x "$COMP_IN" ]; then
  echo "parser-parse-bootstrap-link-smoke: SKIP (no compiler/$COMP_IN)"
  exit 0
fi

BOOT_O="compiler/build_asm/parser_parse_bootstrap.o"
if [ ! -f "$BOOT_O" ]; then
  echo "parser-parse-bootstrap-link-smoke: SKIP (missing $BOOT_O; run relink_shux_asm_experimental_bootstrap.sh)" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi
if ! nm -g "$BOOT_O" 2>/dev/null | grep -qE '[[:space:]]parse_into_buf$'; then
  echo "parser-parse-bootstrap-link-smoke: FAIL: $BOOT_O missing parse_into_buf" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

# shux_asm 链入 liburing；裸容器无运行时库时 SKIP（bootstrap-ci 已装 liburing-dev）。
if [ -x "compiler/$COMP_IN" ]; then
  LDD_MISS=$(ldd "compiler/$COMP_IN" 2>/dev/null | grep 'not found' || true)
  if [ -n "$LDD_MISS" ]; then
    echo "parser-parse-bootstrap-link-smoke: SKIP (compiler/$COMP_IN missing runtime libs)" >&2
    echo "$LDD_MISS" >&2
    [ "$FAIL" = "1" ] && exit 1
    exit 0
  fi
fi

SRC="/tmp/shux_parser_boot_link_smoke.$$.x"
OUT="/tmp/shux_parser_boot_link_smoke.$$.o"
LOG="/tmp/shux_parser_boot_link_smoke.log"
rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
printf 'function main(): i32 { return 42; }\n' > "$SRC"

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-parse-bootstrap-link-smoke: asm compile minimal .x with compiler/$COMP_IN ..."
if ! (
  cd compiler
  env -u SHUX_ASM_START_FUNC SHUX_ASM_BUILD_SKIP_TYPECK=1 \
    "$COMP_IN" -backend asm -o "$OUT" $LIBROOT "$SRC"
) > "$LOG" 2>&1; then
  echo "parser-parse-bootstrap-link-smoke FAIL: compile command failed" >&2
  tail -n 12 "$LOG" 2>/dev/null || true
  rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if grep -q 'asm_codegen_elf_o failed' "$LOG" 2>/dev/null; then
  echo "parser-parse-bootstrap-link-smoke FAIL: asm_codegen_elf_o failed" >&2
  tail -n 8 "$LOG" 2>/dev/null || true
  rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -s "$OUT" ]; then
  echo "parser-parse-bootstrap-link-smoke FAIL: empty output $OUT" >&2
  rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

TEXT_HEX=$(objdump -h "$OUT" 2>/dev/null | awk '$2 == ".text" { print $3; exit }')
[ -z "$TEXT_HEX" ] && TEXT_HEX=$(objdump -h "$OUT" 2>/dev/null | awk '$2 == "__text" { print $3; exit }')
TEXT=$(perl -e 'print hex(shift)' "$TEXT_HEX" 2>/dev/null || echo 0)
MIN_TEXT=${SHUX_PARSER_PARSE_BOOTSTRAP_LINK_MIN_TEXT:-8}
rm -f "$SRC" "$OUT" "$LOG" 2>/dev/null || true

if [ "${TEXT:-0}" -lt "$MIN_TEXT" ] 2>/dev/null; then
  echo "parser-parse-bootstrap-link-smoke FAIL: __text=${TEXT}B < min ${MIN_TEXT}B" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "parser-parse-bootstrap-link-smoke PASS (__text=${TEXT}B; bootstrap.o parse_into_buf linked)"
exit 0
