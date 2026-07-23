#!/usr/bin/env bash
# VEC-V1 + MEM-A2：autovec 点积路径无 xlang_panic_ 边界检查（BCE/指针索引）。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
XLANG="${XLANG:-./compiler/xlang-c}"
SRC="tests/vec/autovec_dot_loop.x"
C_OUT="/tmp/xlang_autovec_bce.c"
rm -f "$C_OUT"
if ! "$XLANG" build -E "$SRC" >"$C_OUT" 2>/tmp/xlang_autovec_bce_emit.log; then
  echo "autovec-bce-gate FAIL: emit failed" >&2
  exit 1
fi
if grep -qE '\) >= [0-9]+ \? \(xlang_panic_|length \? \(xlang_panic_|>= \(.*\)->length \? \(xlang_panic_' "$C_OUT"; then
  echo "autovec-bce-gate FAIL: autovec path still contains index bounds xlang_panic_ guard" >&2
  grep 'xlang_panic_' "$C_OUT" | head -3 >&2 || true
  exit 1
fi
if ! grep -q 'xlang_autovec_dot_f32' "$C_OUT"; then
  echo "autovec-bce-gate FAIL: missing autovec helper" >&2
  exit 1
fi
echo "autovec-bce-gate OK (autovec dot + no bounds panic in TU)"
