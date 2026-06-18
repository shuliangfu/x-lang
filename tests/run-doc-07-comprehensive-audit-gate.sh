#!/usr/bin/env bash
# STD-168：docs/07 全面审计门禁（STD-156～167 / CORE-018～020 关键词 + Cookbook）
#
# 用法：./tests/run-doc-07-comprehensive-audit-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/doc-07-comprehensive-audit-v1.md"
MANIFEST="tests/baseline/doc-07-comprehensive-audit.tsv"
DOC07="docs/07-内置与标准库.md"
MIN_KW=18
PREFIX="shu: [SHU_DOC07_COMPREHENSIVE]"

echo "=== STD-168: docs/07 comprehensive audit ==="
for f in "$DOC" "$MANIFEST" "$DOC07"; do
  if [ ! -f "$f" ]; then
    echo "doc-07-comprehensive-audit gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in min_keywords) MIN_KW="$c2" ;; esac
done < "$MANIFEST"

MISS=0
KW_N=0
while IFS=$'\t' read -r item_id kind anchor target _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    keyword)
      KW_N=$((KW_N + 1))
      if ! grep -qF "$anchor" "$DOC07" 2>/dev/null; then
        echo "doc-07-comprehensive-audit FAIL: docs/07 missing keyword '$anchor'" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "doc-07-comprehensive-audit FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$KW_N" -lt "$MIN_KW" ]; then
  echo "doc-07-comprehensive-audit FAIL: keywords=$KW_N < min $MIN_KW" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "${PREFIX} status=fail miss=${MISS}"
  exit 1
fi

for kw in STD-168 全面审计 placeholder-inventory; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-07-comprehensive-audit gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

echo "${PREFIX} status=ok keywords=${KW_N}"
echo "doc-07-comprehensive-audit gate OK"
