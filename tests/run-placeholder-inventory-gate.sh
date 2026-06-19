#!/usr/bin/env bash
# STD-168：placeholder() 清单冻结门禁
#
# 用法：./tests/run-placeholder-inventory-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/placeholder-inventory-v1.md"
MANIFEST="tests/baseline/placeholder-inventory.tsv"
LIB="tests/lib/placeholder-inventory.sh"
MAX_COUNT=40

# shellcheck source=tests/lib/placeholder-inventory.sh
. "$LIB"

echo "=== STD-168: placeholder inventory ==="
for f in "$DOC" "$MANIFEST" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "placeholder-inventory gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in max_count) MAX_COUNT="$c2" ;; esac
done < "$MANIFEST"

CNT="$(placeholder_count_repo)"
if [ "$CNT" -gt "$MAX_COUNT" ]; then
  placeholder_emit_report "fail" "$CNT" "$MAX_COUNT"
  echo "placeholder-inventory gate FAIL: count=$CNT > max=$MAX_COUNT" >&2
  exit 1
fi

if ! grep -qF 'tests/stdlib-import/main.sx' "$DOC" 2>/dev/null; then
  echo "placeholder-inventory gate FAIL: doc missing smoke ref" >&2
  exit 1
fi

placeholder_emit_report "ok" "$CNT" "$MAX_COUNT"
echo "placeholder-inventory gate OK (count=$CNT max=$MAX_COUNT)"
