#!/usr/bin/env bash
# M-4 Linear(T) use-once move typeck 烟测
# 用法：./tests/run-typeck-linear.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$SHUX" ]; then
  TYPECK_SHUX="$SHUX"
elif [ -x ./compiler/shux-c ]; then
  TYPECK_SHUX=./compiler/shux-c
elif [ -x ./compiler/shux ]; then
  TYPECK_SHUX=./compiler/shux
else
  make -C compiler -q 2>/dev/null || make -C compiler
  TYPECK_SHUX=./compiler/shux-c
fi

# relink 后 ./compiler/shux 的 -E 仅 parse/typeck 摘要；正例 C emit 用 shux-c 佐证。
if [ "$TYPECK_SHUX" = "./compiler/shux" ] || [ "$TYPECK_SHUX" = "./compiler/shux_asm" ]; then
  EMIT_SHUX=./compiler/shux-c
else
  EMIT_SHUX="$TYPECK_SHUX"
fi

neg=$("$TYPECK_SHUX" tests/typeck/linear/double_move.sx -o /tmp/shux_linear_double 2>&1) || true
echo "$neg" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected double move error in double_move.sx" >&2
  echo "$neg" >&2
  exit 1
}

neg_call=$("$TYPECK_SHUX" tests/typeck/linear/call_double.sx -o /tmp/shux_linear_call_double 2>&1) || true
echo "$neg_call" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected double move in call_double.sx" >&2
  echo "$neg_call" >&2
  exit 1
}

neg_addr=$("$TYPECK_SHUX" tests/typeck/linear/addr_of.sx -o /tmp/shux_linear_addr 2>&1) || true
echo "$neg_addr" | grep -q "cannot take address of linear value" || {
  echo "linear typeck FAIL: expected addr_of error in addr_of.sx" >&2
  echo "$neg_addr" >&2
  exit 1
}

neg_ret=$("$TYPECK_SHUX" tests/typeck/linear/return_branch.sx -o /tmp/shux_linear_return_branch 2>&1) || true
echo "$neg_ret" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected move error after return branch in return_branch.sx" >&2
  echo "$neg_ret" >&2
  exit 1
}

pos=$("$TYPECK_SHUX" check tests/typeck/linear/move_ok.sx 2>&1) || {
  echo "linear typeck FAIL: move_ok.sx should typeck" >&2
  echo "$pos" >&2
  exit 1
}
pos=$("$EMIT_SHUX" -E tests/typeck/linear/move_ok.sx 2>&1) || {
  echo "linear typeck FAIL: move_ok.sx should typeck" >&2
  echo "$pos" >&2
  exit 1
}
echo "$pos" | grep -q "return 0" || {
  echo "linear typeck FAIL: move_ok.sx -E should emit main" >&2
  echo "$pos" >&2
  exit 1
}

echo "linear typeck OK"
