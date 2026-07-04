#!/usr/bin/env bash
# MEM-A2 BCE v1：循环内 arr[i] 证明在界内时 codegen 省略 shux_panic_ 边界检查。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/bce_array.x"
OUT="/tmp/shux_bce_array"
C_OUT="/tmp/shux_bce_array.c"
rm -f "$OUT" "$C_OUT"
if ! "$SHUX" -E "$SRC" >"$C_OUT" 2>/tmp/shux_bce_emit.log; then
  echo "bce-gate FAIL: emit failed" >&2
  tail -8 /tmp/shux_bce_emit.log 2>/dev/null || true
  exit 1
fi
if grep -qE '\) >= [0-9]+ \? \(shux_panic_|length \? \(shux_panic_' "$C_OUT"; then
  echo "bce-gate FAIL: generated C still contains index bounds check (shux_panic_ guard)" >&2
  grep -E '\) >= [0-9]+ \? \(shux_panic_|length \? \(shux_panic_' "$C_OUT" | head -3 >&2 || true
  exit 1
fi
SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" 2>/tmp/shux_bce_run.log || {
  echo "bce-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_bce_run.log 2>/dev/null || true
  exit 1
}
echo "bce-gate OK (BCE eliminated array index bounds check)"
