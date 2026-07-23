#!/usr/bin/env bash
# Parser 回归：if (struct.field) 后 return struct.field
#
# xlang-c（C 解析器）须 check 通过；xlang_asm_stage1（x 解析器）同绿为加分项。
# 用法：./tests/run-parser-if-field-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

SRC="tests/parser/if_field_after_if.x"
[ -f "$SRC" ] || { gate_progress "FAIL: missing $SRC"; exit 1; }

gate_progress "parser-if-field: xlang-c check ..."
if ! ./compiler/xlang-c check -L . "$SRC" >/tmp/parser_if_field_c.log 2>&1; then
  tail -5 /tmp/parser_if_field_c.log >&2
  gate_progress "FAIL: xlang-c check"
  exit 1
fi
gate_progress "OK: xlang-c check"

if [ -x ./compiler/xlang_asm_stage1 ]; then
  gate_progress "parser-if-field: xlang_asm_stage1 check ..."
  set +e
  out="$(XLANG_DEBUG_PIPE=1 ./compiler/xlang_asm_stage1 check -L . "$SRC" 2>&1)"
  ec=$?
  set -e
  nf="$(echo "$out" | sed -n 's/.*driver_first_parse num_funcs=\([0-9-]*\).*/\1/p' | head -1)"
  if [ -z "$nf" ]; then
    nf="$(echo "$out" | sed -n 's/.*after_entry_parse num_funcs=\([0-9-]*\).*/\1/p' | head -1)"
  fi
  if [ "$nf" = "1" ]; then
    gate_progress "OK: xlang_asm_stage1 parse num_funcs=1"
  else
    gate_progress "FAIL: xlang_asm_stage1 parse num_funcs=${nf:-?}"
    exit 1
  fi
fi

gate_progress "parser-if-field-gate OK"
exit 0
