#!/usr/bin/env bash
# BOOT-021：mega7 B1–B7 逐项 bisect 晋升波次 runner
#
# 对 7 个 mega 函数各跑一次 SHUX_ASM_PARSER_MEGA_BISECT，记录 ec/text/delta/status。
# 用法：./tests/run-parser-mega7-promote-wave.sh
set -e
cd "$(dirname "$0")/.."

WAVE="${SHUX_BOOT021_WAVE_TSV:-tests/baseline/parser-mega7-promote-wave.tsv}"
MIN_DELTA="${SHUX_PARSER_MEGA_BISECT_MIN_DELTA:-8192}"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
COMP_IN="./shux_asm"
MEGAS=()

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-mega7-promote-wave SKIP (Darwin N/A)"
  exit 0
fi
if [ -x "./compiler/shux_asm.experimental" ]; then
  COMP_IN="./shux_asm.experimental"
elif [ ! -x "./compiler/shux_asm" ]; then
  echo "parser-mega7-promote-wave SKIP (no compiler/shux_asm)"
  exit 0
fi

while IFS=$'\t' read -r promote_id mega_fn _phase _hook _notes; do
  [ -z "${promote_id:-}" ] && continue
  case "$promote_id" in \#*|min_*) continue ;; esac
  MEGAS+=("$mega_fn")
done < "$WAVE"

if [ "${#MEGAS[@]}" -lt 7 ]; then
  echo "parser-mega7-promote-wave FAIL: wave rows=${#MEGAS[@]} < 7" >&2
  exit 1
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
  local out="/tmp/shux_mega_promote_${name}.$$.o"
  local ec text
  rm -f "$out" 2>/dev/null || true
  set +e
  (
    cd compiler
    env -u SHUX_ASM_START_FUNC SHUX_ASM_ENTRY_MODULE_ONLY=1 SHUX_ASM_BUILD_SKIP_TYPECK=1 \
      SHUX_ASM_ENTRY_EMIT_HEAVY=1 SHUX_ASM_WPO_DCE=0 \
      ${name:+SHUX_ASM_PARSER_MEGA_BISECT=$name} \
      "$COMP_IN" -backend asm -o "$out" $LIBROOT src/parser/parser.x
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
echo "parser-mega7-promote-wave: baseline text=${BASE_TEXT}B ec=${BASE_EC}"

WAVE_LOG="/tmp/parser_mega7_promote_wave_$$.log"
: > "$WAVE_LOG"
EMIT_N=0
for name in "${MEGAS[@]}"; do
  read -r EC TEXT <<<"$(compile_one "$name")"
  DELTA=$((TEXT - BASE_TEXT))
  STATUS=stub
  if [ "$EC" -ne 0 ]; then
    STATUS=fail
  elif [ "$DELTA" -ge "$MIN_DELTA" ]; then
    STATUS=emit
    EMIT_N=$((EMIT_N + 1))
  fi
  echo "${name}	ec=${EC}	text=${TEXT}	delta=${DELTA}	status=${STATUS}"
  printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$EC" "$TEXT" "$DELTA" "$STATUS" >> "$WAVE_LOG"
done

echo "parser-mega7-promote-wave OK (targets=${#MEGAS[@]} emit=${EMIT_N})"
rm -f "$WAVE_LOG" 2>/dev/null || true
