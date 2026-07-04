#!/usr/bin/env bash
# P0-4 / MEM-CTFE：i64 大整数字面量与 INT64_MIN 折叠回归门禁。
#
# 验证 `0 - 9223372036854775807 - 1` 运行时不等于 0（防 fmt_i64_min 类 silent wrong code）。
# 用法：./tests/run-i64-ctfe-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/安全与性能.md"
SRC="tests/typeck/ctfe/i64_min_not_zero.x"
BASELINE="tests/baseline/i64-ctfe.tsv"

echo "=== P0-4: i64/CTFE regression manifest ==="
for f in "$DOC" "$SRC" "$BASELINE"; do
  if [ ! -f "$f" ]; then
    echo "i64-ctfe gate FAIL: missing $f" >&2
    exit 1
  fi
done
if ! grep -qF "i64_min_not_zero.x" "$BASELINE" 2>/dev/null; then
  echo "i64-ctfe gate FAIL: baseline missing i64_min_not_zero.x" >&2
  exit 1
fi
echo "i64-ctfe manifest OK"

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
# shellcheck source=tests/lib/min-asm-gcc-link.sh
. "$(dirname "$0")/lib/min-asm-gcc-link.sh"
# P0 typeck：优先 B-strict relink 的 shux（含最新 typeck_x）；无则 shux-c seed。
SHUX_BIN="${SHUX:-${TYPECK_SHUX:-./compiler/shux}}"
if [ ! -x "$SHUX_BIN" ] && [ -x ./compiler/shux-c ]; then
  SHUX_BIN=./compiler/shux-c
fi
if [ ! -x "$SHUX_BIN" ]; then
  make -C compiler -q shux 2>/dev/null || make -C compiler shux
  SHUX_BIN=./compiler/shux
fi

if ! "$SHUX_BIN" check -L . "$SRC" >/dev/null 2>&1; then
  echo "i64-ctfe gate FAIL: typeck $SRC" >&2
  "$SHUX_BIN" check -L . "$SRC" 2>&1 | tail -12 >&2 || true
  exit 1
fi

EXE="/tmp/shux_i64_ctfe_$$"
LINK_SHUX="${SHUX_LINK_SHUX:-$SHUX_BIN}"
if ! min_link_exe "$LINK_SHUX" "$SRC" "$EXE" 2>&1; then
  echo "i64-ctfe gate FAIL: compile $SRC" >&2
  rm -f "$EXE"
  exit 1
fi
EC=0
"$EXE" >/dev/null 2>&1 || EC=$?
rm -f "$EXE"
if [ "$EC" -ne 42 ]; then
  echo "i64-ctfe gate FAIL: expected exit 42 (INT64_MIN != 0), got $EC" >&2
  exit 1
fi

echo "i64-ctfe gate OK"
