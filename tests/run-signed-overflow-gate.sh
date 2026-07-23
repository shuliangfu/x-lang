#!/usr/bin/env bash
# P1-2：有符号溢出策略门禁 — 文档 manifest + 无符号 wrapping 烟测。
#
# 用法：./tests/run-signed-overflow-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/UB与未定义行为.md"
MANIFEST="tests/baseline/signed-overflow.tsv"
CASE="tests/ub/unsigned_wrap_ok.x"

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
if ! grep -qF "unsigned_wrap_ok.x" "$MANIFEST" 2>/dev/null; then
  echo "signed-overflow gate FAIL: baseline missing case" >&2
  exit 1
fi
echo "signed-overflow manifest OK"

# shellcheck source=tests/lib/bootstrap-link-xlang.sh
. "$(dirname "$0")/lib/bootstrap-link-xlang.sh"
XLANG_BIN="${XLANG:-${RUN_XLANG:-./compiler/xlang-c}}"
if [ ! -x "$XLANG_BIN" ]; then
  make -C compiler -q xlang-c 2>/dev/null || make -C compiler xlang-c
  XLANG_BIN=./compiler/xlang-c
fi

if ! "$XLANG_BIN" check -L . "$CASE" >/dev/null 2>&1; then
  echo "signed-overflow gate FAIL: typeck $CASE" >&2
  exit 1
fi
EXE="/tmp/xlang_unsigned_wrap_$$"
if ! "$XLANG_BIN" -L . "$CASE" -o "$EXE" >/dev/null 2>&1; then
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
