#!/usr/bin/env bash
# DOC-005：对外路线图季度 runner
#
# 校验文档当季版本与 manifest 一致，并输出 SHUX_DOC_ROADMAP 报告。
#
# 用法：./tests/run-doc-public-roadmap.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_DOC_ROADMAP_DOC:-analysis/doc-public-roadmap-v1.md}"
MANIFEST="${SHUX_DOC_ROADMAP_MANIFEST:-tests/baseline/doc-public-roadmap.tsv}"
TEMPLATE="tests/templates/doc-public-roadmap-quarter.txt"

# shellcheck source=tests/lib/doc-public-roadmap.sh
. tests/lib/doc-public-roadmap.sh

echo "=== DOC-005: public roadmap quarterly check ==="

QUARTER="$(doc_roadmap_quarter_from_manifest "$MANIFEST")"
SEC=0
XREF=0
FAIL=0

while IFS=$'\t' read -r item_id kind anchor _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|quarter_anchor) continue ;; esac
  case "$kind" in
    section)
      if grep -qF "$anchor" "$DOC" 2>/dev/null; then
        SEC=$((SEC + 1))
      else
        echo "doc-public-roadmap FAIL: missing section $anchor" >&2
        FAIL=$((FAIL + 1))
      fi
      ;;
    cross_ref)
      if [ -f "$anchor" ] && grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        XREF=$((XREF + 1))
      else
        echo "doc-public-roadmap FAIL: bad cross-ref $anchor" >&2
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if ! doc_roadmap_quarter_ok "$DOC" "$QUARTER"; then
  echo "doc-public-roadmap FAIL: doc missing quarter $QUARTER" >&2
  FAIL=$((FAIL + 1))
fi

if [ -f "$TEMPLATE" ] && ! grep -qF "$QUARTER" "$TEMPLATE" 2>/dev/null; then
  echo "doc-public-roadmap FAIL: template missing quarter $QUARTER" >&2
  FAIL=$((FAIL + 1))
fi

if [ "$FAIL" -gt 0 ]; then
  doc_roadmap_emit_report "fail" "$QUARTER" "$SEC" "$XREF"
  echo "doc-public-roadmap FAIL" >&2
  exit 1
fi

doc_roadmap_emit_report "ok" "$QUARTER" "$SEC" "$XREF"
echo "doc-public-roadmap OK"
