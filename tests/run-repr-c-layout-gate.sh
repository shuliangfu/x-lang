#!/usr/bin/env bash
# B-03 v1：#[repr(C)] C ABI layout 烟测（u8+u32 隐式 padding 须能 typeck/compile）。
# 用法：./tests/run-repr-c-layout-gate.sh
# 环境：XLANG_REPR_C_LAYOUT_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

# 默认硬失败（禁止软绿 exit 0）；仅 XLANG_REPR_C_LAYOUT_FAIL=0 时软退。
FAIL=${XLANG_REPR_C_LAYOUT_FAIL:-1}
GOOD="tests/lexer/repr_c_layout_smoke.x"
BAD="/tmp/xlang_repr_c_layout_bad.$$.x"
OUT="/tmp/xlang_repr_c_layout.$$.out"
XLANG="${XLANG:-./compiler/xlang_asm}"

if [ ! -x "$XLANG" ]; then
  XLANG="./compiler/xlang"
fi
if [ ! -x "$XLANG" ]; then
  echo "repr-c-layout-gate FAIL: no product XLANG (xlang_asm/xlang)" >&2
  exit 1
fi

# 负例：无 repr(C)/allow(padding) 时 u8+u32 应 typeck 失败（隐式 padding）
cat > "$BAD" << 'EOF'
struct BadHeader {
  tag: u8
  len: u32
}
function main(): i32 {
  return 0;
}
EOF

if "$XLANG" build -o /dev/null "$BAD" 2>/tmp/xlang_repr_c_layout_neg.log; then
  echo "repr-c-layout-gate FAIL: expected typeck error for struct without #[repr(C)]" >&2
  rm -f "$BAD" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$OUT" "$BAD" 2>/dev/null || true

if ! "$XLANG" build -o "$OUT" "$GOOD" 2>/tmp/xlang_repr_c_layout.log; then
  echo "repr-c-layout-gate FAIL: compile $GOOD" >&2
  tail -n 8 /tmp/xlang_repr_c_layout.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "repr-c-layout-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 43 ]; then
  echo "repr-c-layout-gate FAIL: expected exit 43 (1+42), got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "repr-c-layout-gate OK (#[repr(C)] allows C padding + main returns 43)"
exit 0
