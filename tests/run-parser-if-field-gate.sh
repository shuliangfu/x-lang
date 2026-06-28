#!/usr/bin/env bash
# Parser 回归：if (struct.field) 后 return struct.field
#
# shux-c（C 解析器）须 check 通过；shux_asm_stage1（sx 解析器）同绿为加分项。
# 用法：./tests/run-parser-if-field-gate.sh
set -euo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

SRC="tests/parser/if_field_after_if.sx"
[ -f "$SRC" ] || { gate_progress "FAIL: missing $SRC"; exit 1; }

gate_progress "parser-if-field: shux-c check ..."
if ! ./compiler/shux-c check -L . "$SRC" >/tmp/parser_if_field_c.log 2>&1; then
  tail -5 /tmp/parser_if_field_c.log >&2
  gate_progress "FAIL: shux-c check"
  exit 1
fi
gate_progress "OK: shux-c check"

if [ -x ./compiler/shux_asm_stage1 ]; then
  gate_progress "parser-if-field: shux_asm_stage1 check ..."
  set +e
  out="$(SHUX_DEBUG_PIPE=1 ./compiler/shux_asm_stage1 check -L . "$SRC" 2>&1)"
  ec=$?
  set -e
  nf="$(echo "$out" | sed -n 's/.*driver_first_parse num_funcs=\([0-9-]*\).*/\1/p' | head -1)"
  if [ -z "$nf" ]; then
    nf="$(echo "$out" | sed -n 's/.*after_entry_parse num_funcs=\([0-9-]*\).*/\1/p' | head -1)"
  fi
  if [ "$nf" = "1" ]; then
    gate_progress "OK: shux_asm_stage1 parse num_funcs=1"
  else
    gate_progress "FAIL: shux_asm_stage1 parse num_funcs=${nf:-?}"
    exit 1
  fi
fi

gate_progress "parser-if-field-gate OK"
exit 0
