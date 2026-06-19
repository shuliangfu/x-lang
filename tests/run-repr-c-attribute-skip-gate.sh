#!/usr/bin/env bash
# B-03 v0：#[repr(C)] 词法跳过烟测（parse/typeck + 运行）；Darwin/Linux 可用 shux-c。
# 用法：./tests/run-repr-c-attribute-skip-gate.sh
# 环境：SHUX_REPR_C_ATTR_SKIP_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_REPR_C_ATTR_SKIP_FAIL:-0}
SU="tests/lexer/repr_c_attribute_skip.sx"
OUT="/tmp/shux_repr_c_attr_skip.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "repr-c-attribute-skip-gate: SKIP (no shux/shux-c)"
  exit 0
fi

rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -o "$OUT" "$SU" 2>/tmp/shux_repr_c_attr_skip.log; then
  echo "repr-c-attribute-skip-gate FAIL: compile $SU" >&2
  tail -n 8 /tmp/shux_repr_c_attr_skip.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "repr-c-attribute-skip-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne 10 ]; then
  echo "repr-c-attribute-skip-gate FAIL: expected exit 10 (4+6), got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "repr-c-attribute-skip-gate OK (#[repr(C)] lex skip + main returns 10)"
exit 0
