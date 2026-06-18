#!/usr/bin/env bash
# STD-003：std.fs 稳定 API manifest 门禁 + 跨平台 smoke。
# 1) tests/baseline/std-fs-api.tsv 中每个符号须在 std/fs/mod.su 存在
# 2) tests/run-std-fs-crossplatform-gate.sh 三平台对齐烟测
#
# 用法：./tests/run-std-fs-api-gate.sh
set -e
cd "$(dirname "$0")/.."

BASELINE="tests/baseline/std-fs-api.tsv"
MOD="std/fs/mod.su"
MISS=0
N=0

if [ ! -f "$BASELINE" ]; then
  echo "std-fs-api gate FAIL: missing $BASELINE" >&2
  exit 1
fi
if [ ! -f "$MOD" ]; then
  echo "std-fs-api gate FAIL: missing $MOD" >&2
  exit 1
fi
if [ ! -f analysis/std-fs-api-v1.md ]; then
  echo "std-fs-api gate FAIL: missing analysis/std-fs-api-v1.md" >&2
  exit 1
fi

echo "=== STD-003: std.fs stable API manifest ==="
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  sym="$line"
  N=$((N + 1))
  if ! grep -qE "function ${sym}[[:space:](]" "$MOD"; then
    echo "std-fs-api gate FAIL: missing stable symbol function ${sym} in $MOD" >&2
    MISS=$((MISS + 1))
  fi
done < "$BASELINE"

if [ "$MISS" -gt 0 ]; then
  echo "std-fs-api gate FAIL: ${MISS}/${N} symbols missing" >&2
  exit 1
fi
echo "std-fs-api manifest OK (${N} symbols)"

echo "=== STD-003: std.fs cross-platform smoke ==="
chmod +x tests/run-std-fs-crossplatform-gate.sh
./tests/run-std-fs-crossplatform-gate.sh

echo "std-fs-api gate OK"
