#!/usr/bin/env bash
# P1-2：有符号溢出策略门禁 — 文档 manifest + 无符号 wrapping 烟测。
#
# 用法：./tests/run-signed-overflow-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/UB与未定义行为.md"
MANIFEST="tests/baseline/signed-overflow.tsv"
CASE="tests/ub/unsigned_wrap_ok.sx"

echo "=== P1-2: signed overflow policy manifest ==="
for f in "$DOC" "$MANIFEST" "$CASE"; do
  if [ ! -f "$f" ]; then
    echo "signed-overflow gate FAIL: missing $f" >&2
    exit 1
  fi
done
for kw in "有符号溢出" "无符号整数" "wrapping"; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "signed-overflow gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done
if ! grep -qF "unsigned_wrap_ok.sx" "$MANIFEST" 2>/dev/null; then
  echo "signed-overflow gate FAIL: baseline missing case" >&2
  exit 1
fi
echo "signed-overflow manifest OK"

# shellcheck source=tests/lib/bootstrap-link-shux.sh
. "$(dirname "$0")/lib/bootstrap-link-shux.sh"
SHUX_BIN="${SHUX:-${RUN_SHUX:-./compiler/shux-c}}"
if [ ! -x "$SHUX_BIN" ]; then
  make -C compiler -q shux-c 2>/dev/null || make -C compiler shux-c
  SHUX_BIN=./compiler/shux-c
fi

if ! "$SHUX_BIN" check -L . "$CASE" >/dev/null 2>&1; then
  echo "signed-overflow gate FAIL: typeck $CASE" >&2
  exit 1
fi
EXE="/tmp/shux_unsigned_wrap_$$"
if ! "$SHUX_BIN" -L . "$CASE" -o "$EXE" >/dev/null 2>&1; then
  echo "signed-overflow gate FAIL: compile $CASE" >&2
  rm -f "$EXE"
  exit 1
fi
EC=0
"$EXE" >/dev/null 2>&1 || EC=$?
rm -f "$EXE"
if [ "$EC" -ne 42 ]; then
  echo "signed-overflow gate FAIL: expected exit 42, got $EC" >&2
  exit 1
fi

echo "signed-overflow gate OK"
