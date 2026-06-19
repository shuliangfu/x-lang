#!/usr/bin/env bash
# M-3 Region 域标签 typeck 烟测（[]T<label> 越域 assign compile fail）
# 用法：./tests/run-typeck-region.sh
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
# CHECK_SHUX 可能是绝对路径（zc gate 传入），用 basename 识别 seed/asm 编译器。
_typeck_base=$(basename "$TYPECK_SHUX")
if [ "$_typeck_base" = "shux" ] || [ "$_typeck_base" = "shux_asm" ]; then
  if [ -x ./compiler/shux-c ]; then
    EMIT_SHUX=./compiler/shux-c
  else
    EMIT_SHUX="$TYPECK_SHUX"
  fi
else
  EMIT_SHUX="$TYPECK_SHUX"
fi

neg_err=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_mismatch.sx 2>&1) || true
echo "$neg_err" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in region_mismatch.sx" >&2
  echo "$neg_err" >&2
  exit 1
}

neg_escape=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_block_escape.sx 2>&1) || true
echo "$neg_escape" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in region_block_escape.sx" >&2
  echo "$neg_escape" >&2
  exit 1
}

neg_assign=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_assign_escape.sx 2>&1) || true
echo "$neg_assign" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in region_assign_escape.sx" >&2
  echo "$neg_assign" >&2
  exit 1
}

neg_ret=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_return_escape.sx 2>&1) || true
echo "$neg_ret" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in region_return_escape.sx" >&2
  echo "$neg_ret" >&2
  exit 1
}

neg_call=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_call_mismatch.sx 2>&1) || true
echo "$neg_call" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in region_call_mismatch.sx" >&2
  echo "$neg_call" >&2
  exit 1
}

neg_call_esc=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_call_escape.sx 2>&1) || true
echo "$neg_call_esc" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in region_call_escape.sx" >&2
  echo "$neg_call_esc" >&2
  exit 1
}

pos_out=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_same_ok.sx 2>&1) || {
  echo "region typeck FAIL: region_same_ok.sx should typeck" >&2
  echo "$pos_out" >&2
  exit 1
}
pos_out=$("$EMIT_SHUX" -E tests/typeck/slice_lifetime/region_same_ok.sx 2>&1) || {
  echo "region typeck FAIL: region_same_ok.sx should typeck" >&2
  echo "$pos_out" >&2
  exit 1
}
echo "$pos_out" | grep -q "return 0" || {
  echo "region typeck FAIL: region_same_ok.sx -E should emit main" >&2
  echo "$pos_out" >&2
  exit 1
}

pos_block=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_block_same.sx 2>&1) || {
  echo "region typeck FAIL: region_block_same.sx should typeck" >&2
  echo "$pos_block" >&2
  exit 1
}
pos_block=$("$EMIT_SHUX" -E tests/typeck/slice_lifetime/region_block_same.sx 2>&1) || {
  echo "region typeck FAIL: region_block_same.sx should typeck" >&2
  echo "$pos_block" >&2
  exit 1
}
echo "$pos_block" | grep -q "return 0" || {
  echo "region typeck FAIL: region_block_same.sx -E should emit main" >&2
  echo "$pos_block" >&2
  exit 1
}

pos_call=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/region_call_ok.sx 2>&1) || {
  echo "region typeck FAIL: region_call_ok.sx should typeck" >&2
  echo "$pos_call" >&2
  exit 1
}
pos_call=$("$EMIT_SHUX" -E tests/typeck/slice_lifetime/region_call_ok.sx 2>&1) || {
  echo "region typeck FAIL: region_call_ok.sx should typeck" >&2
  echo "$pos_call" >&2
  exit 1
}
echo "$pos_call" | grep -q "return 0" || {
  echo "region typeck FAIL: region_call_ok.sx -E should emit main" >&2
  echo "$pos_call" >&2
  exit 1
}

neg_rptr_esc=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/read_ptr_region_escape.sx 2>&1) || true
echo "$neg_rptr_esc" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in read_ptr_region_escape.sx" >&2
  echo "$neg_rptr_esc" >&2
  exit 1
}

neg_rptr_mis=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/read_ptr_region_mismatch.sx 2>&1) || true
echo "$neg_rptr_mis" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in read_ptr_region_mismatch.sx" >&2
  echo "$neg_rptr_mis" >&2
  exit 1
}

pos_rptr=$("$TYPECK_SHUX" check tests/typeck/slice_lifetime/read_ptr_region_ok.sx 2>&1) || {
  echo "region typeck FAIL: read_ptr_region_ok.sx should typeck" >&2
  echo "$pos_rptr" >&2
  exit 1
}
pos_rptr=$("$EMIT_SHUX" -E tests/typeck/slice_lifetime/read_ptr_region_ok.sx 2>&1) || {
  echo "region typeck FAIL: read_ptr_region_ok.sx should typeck" >&2
  echo "$pos_rptr" >&2
  exit 1
}
echo "$pos_rptr" | grep -q "return 0" || {
  echo "region typeck FAIL: read_ptr_region_ok.sx -E should emit main" >&2
  echo "$pos_rptr" >&2
  exit 1
}

echo "region typeck OK"
