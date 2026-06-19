#!/usr/bin/env bash
# B-01 v1：#[cfg(...)] 语义剪枝烟测（parse/typeck + 运行）；Darwin/Linux 可用 shux-c。
# 用法：./tests/run-cfg-attribute-skip-gate.sh
# 环境：SHUX_CFG_ATTR_SKIP_FAIL=1 失败时硬退出
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_CFG_ATTR_SKIP_FAIL:-0}
SU="tests/lexer/cfg_attribute_skip.sx"
OUT="/tmp/shux_cfg_attr_skip.$$.out"
SHUX="${SHUX:-./compiler/shux-c}"

if [ ! -x "$SHUX" ]; then
  SHUX="./compiler/shux"
fi
if [ ! -x "$SHUX" ]; then
  echo "cfg-attribute-skip-gate: SKIP (no shux/shux-c)"
  exit 0
fi

# 按 host OS + arch 期望 exit code（macos=5/7 + aarch64=11/x86_64=22）
EXPECT=0
ARCH="$(uname -m 2>/dev/null || echo unknown)"
case "$(uname -s):$ARCH" in
  Darwin:arm64|Darwin:aarch64) EXPECT=16 ;;
  Darwin:x86_64) EXPECT=27 ;;
  Linux:x86_64) EXPECT=29 ;;
  Linux:aarch64|Linux:arm64) EXPECT=18 ;;
  *)
    echo "cfg-attribute-skip-gate: SKIP (unsupported host $(uname -s)/$ARCH)"
    exit 0
    ;;
esac

rm -f "$OUT" 2>/dev/null || true

if ! "$SHUX" -o "$OUT" "$SU" 2>/tmp/shux_cfg_attr_skip.log; then
  echo "cfg-attribute-skip-gate FAIL: compile $SU" >&2
  tail -n 8 /tmp/shux_cfg_attr_skip.log 2>/dev/null || true
  rm -f "$OUT" 2>/dev/null || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ ! -x "$OUT" ]; then
  echo "cfg-attribute-skip-gate FAIL: no executable $OUT" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

rc=0
"$OUT" || rc=$?
rm -f "$OUT" 2>/dev/null || true

if [ "$rc" -ne "$EXPECT" ]; then
  echo "cfg-attribute-skip-gate FAIL: expected exit $EXPECT (host $(uname -s)), got $rc" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

echo "cfg-attribute-skip-gate OK (#[cfg] prune + main returns $EXPECT on $(uname -s))"
exit 0
