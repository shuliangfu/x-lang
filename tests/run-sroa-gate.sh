#!/usr/bin/env bash
# MEM-D1：小 struct call SROA — main 内 make_pair 替换为栈复合字面量，运行正确。
set -e
cd "$(dirname "$0")/.."
make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
XLANG="${XLANG:-./compiler/xlang-c}"
SRC="tests/mem/sroa_struct_call.x"
OUT="/tmp/xlang_sroa_struct_call"
C_OUT="/tmp/xlang_sroa_struct_call.c"
rm -f "$OUT" "$C_OUT"
if ! "$XLANG" build -E "$SRC" >"$C_OUT" 2>/tmp/xlang_sroa_emit.log; then
  echo "sroa-gate FAIL: emit failed" >&2
  tail -8 /tmp/xlang_sroa_emit.log 2>/dev/null || true
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
if XLANG_NO_SROA=1 "$XLANG" build -E "$SRC" >"${C_OUT}.scalar" 2>/dev/null; then
  if ! grep -q 'make_pair(' "${C_OUT}.scalar"; then
    echo "sroa-gate WARN: XLANG_NO_SROA=1 did not preserve make_pair call" >&2
  fi
fi
XLANG_KEEP_C=1 "$XLANG" build "$SRC" -o "$OUT" 2>/tmp/xlang_sroa_run.log || {
  echo "sroa-gate FAIL: compile/run failed" >&2
  tail -8 /tmp/xlang_sroa_run.log 2>/dev/null || true
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
CROSS_SRC="tests/mem/sroa_struct_cross.x"
CROSS_OUT="/tmp/xlang_sroa_struct_cross"
CROSS_C="/tmp/xlang_sroa_struct_cross.c"
rm -f "$CROSS_OUT" "$CROSS_C"
if ! "$XLANG" build -E "$CROSS_SRC" >"$CROSS_C" 2>/tmp/xlang_sroa_cross_emit.log; then
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
XLANG_KEEP_C=1 "$XLANG" build "$CROSS_SRC" -o "$CROSS_OUT" 2>/dev/null || {
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
