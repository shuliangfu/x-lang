#!/usr/bin/env bash
# BOOT-022：mega7 B1 lead + 全量 emit 晋升波次 runner
#
# 对 7 个 mega 函数各跑一次 SHU_ASM_PARSER_MEGA_BISECT，B1 优先输出。
# 用法：./tests/run-parser-mega7-emit-wave.sh
set -e
cd "$(dirname "$0")/.."

WAVE="${SHU_BOOT022_WAVE_TSV:-tests/baseline/parser-mega7-emit-wave.tsv}"
MIN_DELTA="${SHU_PARSER_MEGA_BISECT_MIN_DELTA:-8192}"
LIBROOT="-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm"
COMP_IN="./shu_asm"
LEAD=""
MEGAS=()

if [ "$(uname -s 2>/dev/null)" = "Darwin" ]; then
  echo "parser-mega7-emit-wave SKIP (Darwin N/A)"
  exit 0
fi
if [ -x "./compiler/shu_asm.experimental" ]; then
  COMP_IN="./shu_asm.experimental"
elif [ ! -x "./compiler/shu_asm" ]; then
  echo "parser-mega7-emit-wave SKIP (no compiler/shu_asm)"
  exit 0
fi

while IFS=$'\t' read -r emit_id mega_fn role _hook _notes; do
  [ -z "${emit_id:-}" ] && continue
  case "$emit_id" in \#*|min_*) continue ;; esac
  if [ "$role" = "lead" ]; then
    LEAD="$mega_fn"
  fi
  MEGAS+=("$mega_fn")
done < "$WAVE"

if [ "${#MEGAS[@]}" -lt 7 ]; then
  echo "parser-mega7-emit-wave FAIL: wave rows=${#MEGAS[@]} < 7" >&2
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
  local out="/tmp/shu_mega_emit_${name}.$$.o"
  local ec text
  rm -f "$out" 2>/dev/null || true
  set +e
  (
    cd compiler
    env -u SHU_ASM_START_FUNC SHU_ASM_ENTRY_MODULE_ONLY=1 SHU_ASM_BUILD_SKIP_TYPECK=1 \
      SHU_ASM_ENTRY_EMIT_HEAVY=1 SHU_ASM_WPO_DCE=0 \
      ${name:+SHU_ASM_PARSER_MEGA_BISECT=$name} \
      "$COMP_IN" -backend asm -o "$out" $LIBROOT src/parser/parser.su
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
echo "parser-mega7-emit-wave: baseline text=${BASE_TEXT}B ec=${BASE_EC} lead=${LEAD:-none}"

EMIT_N=0
EMIT_LEAD=""
ORDER=()
if [ -n "$LEAD" ]; then
  ORDER+=("$LEAD")
fi
for name in "${MEGAS[@]}"; do
  if [ "$name" = "$LEAD" ]; then
    continue
  fi
  ORDER+=("$name")
done

for name in "${ORDER[@]}"; do
  read -r EC TEXT <<<"$(compile_one "$name")"
  DELTA=$((TEXT - BASE_TEXT))
  STATUS=stub
  if [ "$EC" -ne 0 ]; then
    STATUS=fail
  elif [ "$DELTA" -ge "$MIN_DELTA" ]; then
    STATUS=emit
    EMIT_N=$((EMIT_N + 1))
    if [ -z "$EMIT_LEAD" ]; then
      EMIT_LEAD="$name"
    fi
  fi
  echo "${name}	ec=${EC}	text=${TEXT}	delta=${DELTA}	status=${STATUS}"
done

echo "parser-mega7-emit-wave OK (targets=${#ORDER[@]} emit=${EMIT_N} lead=${EMIT_LEAD:-none})"
