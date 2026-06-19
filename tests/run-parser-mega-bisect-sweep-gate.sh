#!/usr/bin/env bash
# mega 7 项 bisect 扫描：逐项 SHUX_ASM_PARSER_MEGA_BISECT=<name>，记录 ec 与 __text delta（track-only）。
# 用法：
#   ./tests/run-parser-mega-bisect-sweep-gate.sh
#   SHUX_PARSER_MEGA_BISECT_SWEEP_FAIL=1 ./tests/run-parser-mega-bisect-sweep-gate.sh
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_PARSER_MEGA_BISECT_SWEEP_FAIL:-0}
MIN_DELTA=${SHUX_PARSER_MEGA_BISECT_MIN_DELTA:-8192}
BASELINE="${SHUX_PARSER_MEGA_BISECT_BASELINE:-tests/baseline/parser-mega-bisect.tsv}"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
MEGAS=(parse_into_buf parse_into parse parse_one_function_impl parse_expr_into parse_block_into parse_body_lets_into)

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-mega-bisect-sweep-gate: N/A on Darwin"
  exit 0
fi

COMP_IN="./shux_asm"
if [ ! -x "compiler/$COMP_IN" ]; then
  echo "parser-mega-bisect-sweep-gate: SKIP (no compiler/$COMP_IN)"
  exit 0
fi

text_bytes() {
  local f="$1"
  local h
  h=$(objdump -h "$f" 2>/dev/null | awk '/\.text/ {gsub(/\./,""); print $3; exit}')
  [ -z "$h" ] && echo 0 && return
  echo $((16#$h))
}

compile_one() {
  local name="$1"
  local out="/tmp/shux_mega_sweep_${name}.$$.o"
  local ec text
  rm -f "$out" 2>/dev/null || true
  set +e
  (
    cd compiler
    env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      ${name:+SHUX_ASM_PARSER_MEGA_BISECT=$name} \
      "$COMP_IN" -backend asm -o "$out" $LIBROOT src/parser/parser.sx
  ) >/dev/null 2>&1
  ec=$?
  set -e
  text=0
  [ -s "$out" ] && text=$(text_bytes "$out")
  rm -f "$out" 2>/dev/null || true
  echo "$ec $text"
}

ulimit -s 65532 2>/dev/null || ulimit -s hard 2>/dev/null || true

read -r BASE_EC BASE_TEXT <<<"$(compile_one "")"
echo "parser-mega-bisect-sweep-gate: baseline text=${BASE_TEXT}B ec=${BASE_EC}"

TMP_BASELINE="/tmp/parser_mega_bisect_sweep.$$.tsv"
{
  echo "# parser mega bisect sweep (linux/amd64 experimental shux_asm)"
  echo "baseline_text	${BASE_TEXT}"
  echo "min_delta_pass	${MIN_DELTA}"
} > "$TMP_BASELINE"

ANY_EMIT=0
for name in "${MEGAS[@]}"; do
  read -r EC TEXT <<<"$(compile_one "$name")"
  DELTA=$((TEXT - BASE_TEXT))
  STATUS=stub
  if [ "$EC" -ne 0 ]; then
    STATUS=fail
  elif [ "$DELTA" -ge "$MIN_DELTA" ]; then
    STATUS=emit
    ANY_EMIT=1
  fi
  echo "${name}	ec=${EC}	text=${TEXT}	delta=${DELTA}	status=${STATUS}"
  printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$EC" "$TEXT" "$DELTA" "$STATUS" >> "$TMP_BASELINE"
done

if [ -f "$BASELINE" ]; then
  if ! diff -q "$BASELINE" "$TMP_BASELINE" >/dev/null 2>&1; then
    echo "parser-mega-bisect-sweep-gate: baseline drift (see $BASELINE)" >&2
    diff -u "$BASELINE" "$TMP_BASELINE" 2>/dev/null | tail -n 20 || true
    [ "$FAIL" = "1" ] && rm -f "$TMP_BASELINE" && exit 1
  fi
else
  cp "$TMP_BASELINE" "$BASELINE"
  echo "parser-mega-bisect-sweep-gate: wrote $BASELINE"
fi
rm -f "$TMP_BASELINE" 2>/dev/null || true

if [ "$ANY_EMIT" = "1" ]; then
  echo "parser-mega-bisect-sweep-gate NOTE: at least one mega bisect showed emit delta >= ${MIN_DELTA}B"
  [ "$FAIL" = "1" ] && exit 1
fi
echo "parser-mega-bisect-sweep-gate PASS (all mega items stub/fail path)"
exit 0
