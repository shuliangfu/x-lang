#!/usr/bin/env bash
# M-4 Linear(T) use-once move typeck 烟测
# 用法：./tests/run-typeck-linear.sh
set -e
cd "$(dirname "$0")/.."

if [ -n "$SHU" ]; then
  TYPECK_SHU="$SHU"
elif [ -x ./compiler/shu-c ]; then
  TYPECK_SHU=./compiler/shu-c
elif [ -x ./compiler/shu ]; then
  TYPECK_SHU=./compiler/shu
else
  make -C compiler -q 2>/dev/null || make -C compiler
  TYPECK_SHU=./compiler/shu-c
fi

# relink 后 ./compiler/shu 的 -E 仅 parse/typeck 摘要；正例 C emit 用 shu-c 佐证。
if [ "$TYPECK_SHU" = "./compiler/shu" ] || [ "$TYPECK_SHU" = "./compiler/shu_asm" ]; then
  EMIT_SHU=./compiler/shu-c
else
  EMIT_SHU="$TYPECK_SHU"
fi

neg=$("$TYPECK_SHU" tests/typeck/linear/double_move.su -o /tmp/shu_linear_double 2>&1) || true
echo "$neg" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected double move error in double_move.su" >&2
  echo "$neg" >&2
  exit 1
}

neg_call=$("$TYPECK_SHU" tests/typeck/linear/call_double.su -o /tmp/shu_linear_call_double 2>&1) || true
echo "$neg_call" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected double move in call_double.su" >&2
  echo "$neg_call" >&2
  exit 1
}

neg_addr=$("$TYPECK_SHU" tests/typeck/linear/addr_of.su -o /tmp/shu_linear_addr 2>&1) || true
echo "$neg_addr" | grep -q "cannot take address of linear value" || {
  echo "linear typeck FAIL: expected addr_of error in addr_of.su" >&2
  echo "$neg_addr" >&2
  exit 1
}

neg_ret=$("$TYPECK_SHU" tests/typeck/linear/return_branch.su -o /tmp/shu_linear_return_branch 2>&1) || true
echo "$neg_ret" | grep -q "linear value used after move" || {
  echo "linear typeck FAIL: expected move error after return branch in return_branch.su" >&2
  echo "$neg_ret" >&2
  exit 1
}

pos=$("$TYPECK_SHU" check tests/typeck/linear/move_ok.su 2>&1) || {
  echo "linear typeck FAIL: move_ok.su should typeck" >&2
  echo "$pos" >&2
  exit 1
}
pos=$("$EMIT_SHU" -E tests/typeck/linear/move_ok.su 2>&1) || {
  echo "linear typeck FAIL: move_ok.su should typeck" >&2
  echo "$pos" >&2
  exit 1
}
echo "$pos" | grep -q "return 0" || {
  echo "linear typeck FAIL: move_ok.su -E should emit main" >&2
  echo "$pos" >&2
  exit 1
}

echo "linear typeck OK"
