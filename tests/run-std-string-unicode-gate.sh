#!/usr/bin/env bash
# STD-160：std.string Unicode 桥接门禁
#
# 用法：./tests/run-std-string-unicode-gate.sh
set -e
cd "$(dirname "$0")/.."

MOD="std/string/mod.x"
SMOKE="tests/string/unicode_bridge.x"

echo "=== STD-160: std.string unicode bridge ==="
for f in "$MOD" "$SMOKE"; do
  if [ ! -f "$f" ]; then
    echo "std-string-unicode gate FAIL: missing $f" >&2
    exit 1
  fi
done
for kw in string_view_case_fold string_view_is_valid_utf8 unicode_case_fold_buf_c; do
  if ! grep -qF "$kw" "$MOD" 2>/dev/null; then
    echo "std-string-unicode gate FAIL: mod missing '$kw'" >&2
    exit 1
  fi
done

XLANG_BIN=""
if [ -x ./compiler/xlang-c ]; then XLANG_BIN=./compiler/xlang-c; fi
if [ -n "$XLANG_BIN" ]; then
  if ! "$XLANG_BIN" check -L . "$SMOKE" >/dev/null 2>&1; then
    echo "std-string-unicode gate FAIL: typeck" >&2
    exit 1
  fi
fi
echo "std-string-unicode gate OK"
