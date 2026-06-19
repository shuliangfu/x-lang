#!/usr/bin/env bash
# B-03 v1：#[repr(C)] C ABI layout 烟测（u8+u32 隐式 padding 须能 typeck/compile）。
# 用法：./tests/run-repr-c-layout-gate.sh
# 环境：SHUX_REPR_C_LAYOUT_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_REPR_C_LAYOUT_FAIL:-0}
GOOD="tests/lexer/repr_c_layout_smoke.sx"
BAD="/tmp/shux_repr_c_layout_bad.$$.sx"
OUT="/tmp/shux_repr_c_layout.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "repr-c-layout-gate: SKIP (no shux/shux-c)"
  exit 0
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

if "$SHUX" -o /dev/null "$BAD" 2>/tmp/shux_repr_c_layout_neg.log; then
  echo "repr-c-layout-gate FAIL: expected typeck error for struct without #[repr(C)]" >&2
  rm -f "$BAD" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rm -f "$OUT" "$BAD" 2>/dev/null || true

if ! "$SHUX" -o "$OUT" "$GOOD" 2>/tmp/shux_repr_c_layout.log; then
  echo "repr-c-layout-gate FAIL: compile $GOOD" >&2
  tail -n 8 /tmp/shux_repr_c_layout.log 2>/dev/null || true
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
