#!/usr/bin/env bash
# MEM-D1：小 struct call SROA — main 内 make_pair 替换为栈复合字面量，运行正确。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
SHUX="${SHUX:-./compiler/shux-c}"
SRC="tests/mem/sroa_struct_call.sx"
OUT="/tmp/shux_sroa_struct_call"
C_OUT="/tmp/shux_sroa_struct_call.c"
rm -f "$OUT" "$C_OUT"
if ! "$SHUX" -E "$SRC" >"$C_OUT" 2>/tmp/shux_sroa_emit.log; then
  echo "sroa-gate FAIL: emit failed" >&2
  tail -8 /tmp/shux_sroa_emit.log 2>/dev/null || true
  exit 1
fi
MAIN_BODY=$(sed -n '/int main/,/^}/p' "$C_OUT")
if ! echo "$MAIN_BODY" | grep -qE 'struct Pair p = \(struct Pair\)\{'; then
  echo "sroa-gate FAIL: missing SROA struct compound literal in main" >&2
  exit 1
fi
if echo "$MAIN_BODY" | grep -qE 'make_pair\('; then
  echo "sroa-gate FAIL: make_pair call still present in main" >&2
  exit 1
fi
if echo "$MAIN_BODY" | grep -qE 'sum_pair\('; then
  echo "sroa-gate FAIL: sum_pair consumer call still present in main" >&2
  exit 1
fi
if ! echo "$MAIN_BODY" | grep -qE '\.a.*\+.*\.b'; then
  if ! echo "$MAIN_BODY" | grep -qE 'return 7;'; then
    echo "sroa-gate FAIL: missing inlined field sum or folded return 7 in main" >&2
    exit 1
  fi
fi
if SHUX_NO_SROA=1 "$SHUX" -E "$SRC" >"${C_OUT}.scalar" 2>/dev/null; then
  if ! grep -q 'make_pair(' "${C_OUT}.scalar"; then
    echo "sroa-gate WARN: SHUX_NO_SROA=1 did not preserve make_pair call" >&2
  fi
fi
SHUX_KEEP_C=1 "$SHUX" "$SRC" -o "$OUT" 2>/tmp/shux_sroa_run.log || {
  echo "sroa-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/shux_sroa_run.log 2>/dev/null || true
  exit 1
}
rc=0
"$OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "7" ]; then
  echo "sroa-gate FAIL: exit=$rc want 7 (3+4)" >&2
  exit 1
fi
echo "sroa-gate OK (MEM-D1 struct call SROA stack promotion)"

echo "=== MEM-D1.2: cross-module sroa_struct_cross ==="
CROSS_SRC="tests/mem/sroa_struct_cross.sx"
CROSS_OUT="/tmp/shux_sroa_struct_cross"
CROSS_C="/tmp/shux_sroa_struct_cross.c"
rm -f "$CROSS_OUT" "$CROSS_C"
if ! "$SHUX" -E "$CROSS_SRC" >"$CROSS_C" 2>/tmp/shux_sroa_cross_emit.log; then
  echo "sroa-cross-gate FAIL: emit failed" >&2
  exit 1
fi
CROSS_MAIN=$(sed -n '/int main/,/^}/p' "$CROSS_C")
if echo "$CROSS_MAIN" | grep -qE 'make_pair\(|stack_promote_lib_make_pair\('; then
  echo "sroa-cross-gate FAIL: make_pair call still in main" >&2
  exit 1
fi
if echo "$CROSS_MAIN" | grep -qE 'sum_pair\(|stack_promote_lib_sum_pair\('; then
  echo "sroa-cross-gate FAIL: sum_pair call still in main" >&2
  exit 1
fi
SHUX_KEEP_C=1 "$SHUX" "$CROSS_SRC" -o "$CROSS_OUT" 2>/dev/null || {
  echo "sroa-cross-gate FAIL: compile/run failed" >&2
  exit 1
}
rc=0
"$CROSS_OUT" >/dev/null 2>&1 || rc=$?
if [ "$rc" != "7" ]; then
  echo "sroa-cross-gate FAIL: exit=$rc want 7" >&2
  exit 1
fi
echo "sroa-cross-gate OK (cross-module SROA + consumer inline)"
