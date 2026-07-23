#!/usr/bin/env bash
# M-4 Linear(T) use-once move typeck 烟测
# 用法：./tests/run-typeck-linear.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$XLANG" ]; then
  TYPECK_XLANG="$XLANG"
elif [ -x ./compiler/xlang-c ]; then
  TYPECK_XLANG=./compiler/xlang-c
elif [ -x ./compiler/xlang ]; then
  TYPECK_XLANG=./compiler/xlang
else
  make -C compiler -q 2>/dev/null || make -C compiler
  TYPECK_XLANG=./compiler/xlang-c
fi

# relink 后 ./compiler/xlang 的 -E 仅 parse/typeck 摘要；正例 C emit 用 xlang-c 佐证。
if [ "$TYPECK_XLANG" = "./compiler/xlang" ] || [ "$TYPECK_XLANG" = "./compiler/xlang_asm" ]; then
  EMIT_XLANG=./compiler/xlang-c
else
  EMIT_XLANG="$TYPECK_XLANG"
fi

neg=$("$TYPECK_XLANG" check tests/typeck/linear/double_move.x 2>&1) || true
echo "$neg" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected double move error in double_move.x" >&2
  echo "$neg" >&2
  exit 1
}

neg_call=$("$TYPECK_XLANG" check tests/typeck/linear/call_double.x 2>&1) || true
echo "$neg_call" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected double move in call_double.x" >&2
  echo "$neg_call" >&2
  exit 1
}

neg_addr=$("$TYPECK_XLANG" check tests/typeck/linear/addr_of.x 2>&1) || true
echo "$neg_addr" | grep -q "cannot take address of linear value" || {
  echo "linear typeck FAIL: expected addr_of error in addr_of.x" >&2
  echo "$neg_addr" >&2
  exit 1
}

neg_ret=$("$TYPECK_XLANG" check tests/typeck/linear/return_branch.x 2>&1) || true
echo "$neg_ret" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected move error after return branch in return_branch.x" >&2
  echo "$neg_ret" >&2
  exit 1
}

pos=$("$TYPECK_XLANG" check tests/typeck/linear/move_ok.x 2>&1) || {
  echo "linear typeck FAIL: move_ok.x should typeck" >&2
  echo "$pos" >&2
  exit 1
}

echo "linear typeck OK"
