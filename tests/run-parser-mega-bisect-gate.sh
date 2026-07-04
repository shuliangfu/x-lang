#!/usr/bin/env bash
# mega 单项 bisect 门禁：SHUX_ASM_PARSER_MEGA_BISECT=parse_into 时跳过 ret0 桩，探测 X 真 emit 是否可链。
# 判定：与无 bisect 基线比 __text 增量 <8KB 视为仍桩化/不可迁（PASS）；编译失败亦 PASS。
# 用法：
#   ./tests/run-parser-mega-bisect-gate.sh
#   SHUX_PARSER_MEGA_BISECT_FAIL=1 ./tests/run-parser-mega-bisect-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_MEGA_BISECT_FAIL:-0}
TARGET=${SHUX_PARSER_MEGA_BISECT_TARGET:-parse_into}
MIN_DELTA=${SHUX_PARSER_MEGA_BISECT_MIN_DELTA:-8192}
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-mega-bisect-gate: N/A on Darwin"
  exit 0
fi

COMP_IN="./shux_asm"
if [ -n "${SHUX_PARSER_MEGA_BISECT_COMPILER:-}" ]; then
  case "${SHUX_PARSER_MEGA_BISECT_COMPILER}" in
    compiler/*) COMP_IN="./${SHUX_PARSER_MEGA_BISECT_COMPILER#compiler/}" ;;
    *) COMP_IN="${SHUX_PARSER_MEGA_BISECT_COMPILER}" ;;
  esac
fi
if [ ! -x "compiler/$COMP_IN" ] && [ ! -x "$COMP_IN" ]; then
  echo "parser-mega-bisect-gate: SKIP (no compiler/$COMP_IN)"
  exit 0
fi

text_bytes() {
  local f="$1"
  local h
  h=$(objdump -h "$f" 2>/dev/null | awk '/\.text/ {gsub(/\./,""); print $3; exit}')
  if [ -z "$h" ]; then
    echo 0
    return
  fi
  echo $((16#$h))
}

compile_parser_o() {
  local mega_bisect="$1"
  local out="/tmp/shux_parser_mega_bisect_${mega_bisect:-base}.$$.o"
  local log="/tmp/shux_parser_mega_bisect_${mega_bisect:-base}.log"
  local ec text
  rm -f "$out" "$log" 2>/dev/null || true
  set +e
  (
    cd compiler
    env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      ${mega_bisect:+SHUX_ASM_PARSER_MEGA_BISECT=$mega_bisect} \
      "$COMP_IN" -backend asm -o "$out" $LIBROOT src/parser/parser.x
  ) > "$log" 2>&1
  ec=$?
  set -e
  text=0
  if [ -s "$out" ]; then
    text=$(text_bytes "$out")
  fi
  rm -f "$out" "$log" 2>/dev/null || true
  echo "$ec $text"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

echo "parser-mega-bisect-gate: baseline (no MEGA_BISECT) ..."
read -r BASE_EC BASE_TEXT <<<"$(compile_parser_o "")"
echo "parser-mega-bisect-gate: MEGA_BISECT=$TARGET ..."
read -r BISECT_EC BISECT_TEXT <<<"$(compile_parser_o "$TARGET")"

DELTA=$((BISECT_TEXT - BASE_TEXT))
echo "parser-mega-bisect-gate: baseline text=${BASE_TEXT}B bisect text=${BISECT_TEXT}B delta=${DELTA}B ec=${BISECT_EC}"

if [ "$BISECT_EC" -ne 0 ]; then
  echo "parser-mega-bisect-gate PASS (known: mega $TARGET compile fail ec=$BISECT_EC)"
  exit 0
fi

if [ "$DELTA" -lt "$MIN_DELTA" ]; then
  echo "parser-mega-bisect-gate PASS (mega $TARGET bisect delta=${DELTA}B < ${MIN_DELTA}B — still ret0/stub path)"
  exit 0
fi

echo "parser-mega-bisect-gate NOTE: mega $TARGET bisect delta=${DELTA}B — consider promoting from ret0 stub"
if [ "$FAIL" = "1" ]; then
  echo "parser-mega-bisect-gate FAIL: unexpected mega bisect emit (set FAIL=0 to track-only)" >&2
  exit 1
fi
exit 0
