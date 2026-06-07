#!/usr/bin/env bash
# M-3 Region 域标签 typeck 烟测（[]T<label> 越域 assign compile fail）
# 用法：./tests/run-typeck-region.sh
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
# CHECK_SHU 可能是绝对路径（zc gate 传入），用 basename 识别 seed/asm 编译器。
_typeck_base=$(basename "$TYPECK_SHU")
if [ "$_typeck_base" = "shu" ] || [ "$_typeck_base" = "shu_asm" ]; then
  if [ -x ./compiler/shu-c ]; then
    EMIT_SHU=./compiler/shu-c
  else
    EMIT_SHU="$TYPECK_SHU"
  fi
else
  EMIT_SHU="$TYPECK_SHU"
fi

neg_err=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_mismatch.su 2>&1) || true
echo "$neg_err" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in region_mismatch.su" >&2
  echo "$neg_err" >&2
  exit 1
}

neg_escape=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_block_escape.su 2>&1) || true
echo "$neg_escape" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in region_block_escape.su" >&2
  echo "$neg_escape" >&2
  exit 1
}

neg_assign=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_assign_escape.su 2>&1) || true
echo "$neg_assign" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in region_assign_escape.su" >&2
  echo "$neg_assign" >&2
  exit 1
}

neg_ret=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_return_escape.su 2>&1) || true
echo "$neg_ret" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in region_return_escape.su" >&2
  echo "$neg_ret" >&2
  exit 1
}

neg_call=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_call_mismatch.su 2>&1) || true
echo "$neg_call" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in region_call_mismatch.su" >&2
  echo "$neg_call" >&2
  exit 1
}

neg_call_esc=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_call_escape.su 2>&1) || true
echo "$neg_call_esc" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in region_call_escape.su" >&2
  echo "$neg_call_esc" >&2
  exit 1
}

pos_out=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_same_ok.su 2>&1) || {
  echo "region typeck FAIL: region_same_ok.su should typeck" >&2
  echo "$pos_out" >&2
  exit 1
}
pos_out=$("$EMIT_SHU" -E tests/typeck/slice_lifetime/region_same_ok.su 2>&1) || {
  echo "region typeck FAIL: region_same_ok.su should typeck" >&2
  echo "$pos_out" >&2
  exit 1
}
echo "$pos_out" | grep -q "return 0" || {
  echo "region typeck FAIL: region_same_ok.su -E should emit main" >&2
  echo "$pos_out" >&2
  exit 1
}

pos_block=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_block_same.su 2>&1) || {
  echo "region typeck FAIL: region_block_same.su should typeck" >&2
  echo "$pos_block" >&2
  exit 1
}
pos_block=$("$EMIT_SHU" -E tests/typeck/slice_lifetime/region_block_same.su 2>&1) || {
  echo "region typeck FAIL: region_block_same.su should typeck" >&2
  echo "$pos_block" >&2
  exit 1
}
echo "$pos_block" | grep -q "return 0" || {
  echo "region typeck FAIL: region_block_same.su -E should emit main" >&2
  echo "$pos_block" >&2
  exit 1
}

pos_call=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/region_call_ok.su 2>&1) || {
  echo "region typeck FAIL: region_call_ok.su should typeck" >&2
  echo "$pos_call" >&2
  exit 1
}
pos_call=$("$EMIT_SHU" -E tests/typeck/slice_lifetime/region_call_ok.su 2>&1) || {
  echo "region typeck FAIL: region_call_ok.su should typeck" >&2
  echo "$pos_call" >&2
  exit 1
}
echo "$pos_call" | grep -q "return 0" || {
  echo "region typeck FAIL: region_call_ok.su -E should emit main" >&2
  echo "$pos_call" >&2
  exit 1
}

neg_rptr_esc=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/read_ptr_region_escape.su 2>&1) || true
echo "$neg_rptr_esc" | grep -q "slice region escape" || {
  echo "region typeck FAIL: expected slice region escape in read_ptr_region_escape.su" >&2
  echo "$neg_rptr_esc" >&2
  exit 1
}

neg_rptr_mis=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/read_ptr_region_mismatch.su 2>&1) || true
echo "$neg_rptr_mis" | grep -q "slice region mismatch" || {
  echo "region typeck FAIL: expected slice region mismatch in read_ptr_region_mismatch.su" >&2
  echo "$neg_rptr_mis" >&2
  exit 1
}

pos_rptr=$("$TYPECK_SHU" check tests/typeck/slice_lifetime/read_ptr_region_ok.su 2>&1) || {
  echo "region typeck FAIL: read_ptr_region_ok.su should typeck" >&2
  echo "$pos_rptr" >&2
  exit 1
}
pos_rptr=$("$EMIT_SHU" -E tests/typeck/slice_lifetime/read_ptr_region_ok.su 2>&1) || {
  echo "region typeck FAIL: read_ptr_region_ok.su should typeck" >&2
  echo "$pos_rptr" >&2
  exit 1
}
echo "$pos_rptr" | grep -q "return 0" || {
  echo "region typeck FAIL: read_ptr_region_ok.su -E should emit main" >&2
  echo "$pos_rptr" >&2
  exit 1
}

echo "region typeck OK"
