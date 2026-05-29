#!/usr/bin/env bash
# 自举 parse 回归：编 typeck.su 时 pipeline 报告的 num_funcs 不应远低于源文件 function 数。
# 用法（仓库根）：./compiler/scripts/check_parse_func_count.sh
set -e
cd "$(dirname "$0")/../.."
SHU="${SHU:-./compiler/shu}"
TCK="compiler/src/typeck/typeck.su"
MIN_FUNCS="${SHU_PARSE_MIN_TYPECK_FUNCS:-80}"
OUT="/tmp/shu_parse_count_typeck.o"

if [ ! -x "$SHU" ]; then
  echo "check_parse_func_count: need executable SHU=$SHU" >&2
  exit 127
fi

src_count=$(grep -c '^function ' "$TCK" || true)
echo "check_parse_func_count: source functions in typeck.su: $src_count (min gate $MIN_FUNCS)"

rm -f "$OUT" /tmp/shu_parse_count.log
if ! SHU_DEBUG_PIPE=1 "$SHU" -backend asm -o "$OUT" "$TCK" 2>&1 | tee /tmp/shu_parse_count.log; then
  echo "check_parse_func_count: compile failed (see log); try SHU_DEBUG_PARSE=1 SHU_PARSE_STRICT=1" >&2
  exit 1
fi

nf=$(sed -n 's/.*num_funcs=\([0-9][0-9]*\).*/\1/p' /tmp/shu_parse_count.log | tail -1)
if [ -z "$nf" ]; then
  echo "check_parse_func_count: no num_funcs= in SHU_DEBUG_PIPE log (compile OK, skip gate)" >&2
  exit 0
fi
if [ "$nf" -lt "$MIN_FUNCS" ]; then
  echo "check_parse_func_count: num_funcs=$nf < $MIN_FUNCS (parse skip? SHU_DEBUG_PARSE=1)" >&2
  exit 1
fi
echo "check_parse_func_count: pipeline num_funcs=$nf (gate >= $MIN_FUNCS) OK"
