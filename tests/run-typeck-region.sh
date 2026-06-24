#!/usr/bin/env bash
# M-3 Region 域标签 typeck 烟测（T[]<label> 越域 assign compile fail）
# 用法：./tests/run-typeck-region.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

if [ -n "$SHUX" ]; then
  TYPECK_SHUX="$SHUX"
elif [ -x ./compiler/shux-c ]; then
  TYPECK_SHUX=./compiler/shux-c
elif [ -x ./compiler/shux ]; then
  TYPECK_SHUX=./compiler/shux
else
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  TYPECK_SHUX=./compiler/shux-c
fi

# relink 后 ./compiler/shux 的 -E 仅 parse/typeck 摘要；正例 C emit 用 shux-c 佐证。
# CHECK_SHUX 可能是绝对路径（zc gate 传入），用 basename 识别 seed/asm 编译器。
_typeck_base=$(basename "$TYPECK_SHUX")
if [ "$_typeck_base" = "shux" ] || [ "$_typeck_base" = "shux_asm" ]; then
  if [ -x ./compiler/shux-c ] && ci_native_shu ./compiler/shux-c; then
    EMIT_SHUX=./compiler/shux-c
  else
    EMIT_SHUX="$TYPECK_SHUX"
  fi
else
  EMIT_SHUX="$TYPECK_SHUX"
fi

# 正例：check 走 TYPECK_SHUX（W3 用 shux）；-E 优先 shux-c，seed 解析失败时仅 WARN（不阻断 typeck）。
region_pos_check_and_emit() {
  local sx="$1"
  local label="$2"
  local chk emit
  chk=$("$TYPECK_SHUX" check "$sx" 2>&1) || {
    echo "region typeck FAIL: ${label} should typeck (check)" >&2
    echo "$chk" >&2
    exit 1
  }
  if [ "$EMIT_SHUX" = "$TYPECK_SHUX" ]; then
    return 0
  fi
  emit=$("$EMIT_SHUX" -E "$sx" 2>&1) || {
    echo "region typeck WARN: ${label} -E skipped ($EMIT_SHUX failed; check OK)" >&2
    return 0
  }
  echo "$emit" | grep -q "return 0" || {
    echo "region typeck FAIL: ${label} -E should emit main" >&2
    echo "$emit" >&2
    exit 1
  }
}

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

region_pos_check_and_emit tests/typeck/slice_lifetime/region_same_ok.sx region_same_ok.sx
region_pos_check_and_emit tests/typeck/slice_lifetime/region_block_same.sx region_block_same.sx
region_pos_check_and_emit tests/typeck/slice_lifetime/region_call_ok.sx region_call_ok.sx

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

region_pos_check_and_emit tests/typeck/slice_lifetime/read_ptr_region_ok.sx read_ptr_region_ok.sx

echo "region typeck OK"
