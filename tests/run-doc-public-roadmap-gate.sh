#!/usr/bin/env bash
# DOC-005：对外路线图 manifest 门禁
#
# 1) doc-public-roadmap-v1.md 必需章节与交叉引用
# 2) 季度版本与 template 对齐
# 3) runner 烟测 + SHU_DOC_ROADMAP 报告
#
# 用法：./tests/run-doc-public-roadmap-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_DOC_ROADMAP_DOC:-analysis/doc-public-roadmap-v1.md}"
MANIFEST="${SHU_DOC_ROADMAP_MANIFEST:-tests/baseline/doc-public-roadmap.tsv}"
TEMPLATE="tests/templates/doc-public-roadmap-quarter.txt"
LIB="tests/lib/doc-public-roadmap.sh"
RUNNER="tests/run-doc-public-roadmap.sh"
MIN_SEC=8
MIN_XREF=5
PREFIX="shu: [SHU_DOC_ROADMAP]"

# shellcheck source=tests/lib/doc-public-roadmap.sh
. tests/lib/doc-public-roadmap.sh

echo "=== DOC-005: public roadmap manifest ==="
for f in "$DOC" "$MANIFEST" "$TEMPLATE" "$LIB" "$RUNNER" NEXT.md docs/README.md; do
  if [ ! -f "$f" ]; then
    echo "doc-public-roadmap gate FAIL: missing $f" >&2
    exit 1
  fi
done

QUARTER="$(doc_roadmap_quarter_from_manifest "$MANIFEST")"

for kw in quarterly public SHU_DOC_ROADMAP runnable report; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-public-roadmap gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done
if ! grep -qF "$QUARTER" "$DOC" 2>/dev/null; then
  echo "doc-public-roadmap gate FAIL: doc missing quarter '$QUARTER'" >&2
  exit 1
fi

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_sections) MIN_SEC="$c2" ;;
    min_cross_refs) MIN_XREF="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
SEC=0
XREF=0
while IFS=$'\t' read -r item_id kind anchor notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|quarter_anchor) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-public-roadmap FAIL: missing section '$anchor' ($item_id)" >&2
        MISS=$((MISS + 1))
      else
        SEC=$((SEC + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "doc-public-roadmap FAIL: missing cross-ref $anchor" >&2
        MISS=$((MISS + 1))
      else
        XREF=$((XREF + 1))
        if ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
          echo "doc-public-roadmap FAIL: doc missing ref $anchor" >&2
          MISS=$((MISS + 1))
        fi
      fi
      ;;
    file)
      if [ ! -f "$anchor" ]; then
        echo "doc-public-roadmap FAIL: missing file $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-public-roadmap FAIL: doc missing file ref $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    template)
      if [ ! -f "$anchor" ]; then
        echo "doc-public-roadmap FAIL: missing template $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "doc-public-roadmap FAIL: doc missing template ref" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="tests/$anchor"
      if [ ! -f "$path" ]; then
        echo "doc-public-roadmap FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "doc-public-roadmap FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$SEC" -lt "$MIN_SEC" ]; then
  echo "doc-public-roadmap gate FAIL: sections=${SEC} < min ${MIN_SEC}" >&2
  exit 1
fi
if [ "$XREF" -lt "$MIN_XREF" ]; then
  echo "doc-public-roadmap gate FAIL: cross_refs=${XREF} < min ${MIN_XREF}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "doc-public-roadmap gate FAIL: missing=${MISS}" >&2
  exit 1
fi

if ! doc_roadmap_quarter_ok "$DOC" "$QUARTER"; then
  echo "doc-public-roadmap gate FAIL: quarter mismatch want $QUARTER" >&2
  exit 1
fi
if ! grep -qF "$QUARTER" "$TEMPLATE" 2>/dev/null; then
  echo "doc-public-roadmap gate FAIL: template quarter" >&2
  exit 1
fi
echo "doc-public-roadmap manifest OK (sections=${SEC}, cross_refs=${XREF}, quarter=${QUARTER})"

echo "=== DOC-005: runnable report ==="
chmod +x "$RUNNER" "$LIB"
if ! ./"$RUNNER" 2>&1 | tee /tmp/doc_public_roadmap_smoke.log; then
  echo "doc-public-roadmap gate FAIL: runner" >&2
  exit 1
fi
grep -qF "$PREFIX" /tmp/doc_public_roadmap_smoke.log || {
  echo "doc-public-roadmap gate FAIL: missing report prefix" >&2
  exit 1
}
grep -q 'doc-public-roadmap OK' /tmp/doc_public_roadmap_smoke.log || {
  echo "doc-public-roadmap gate FAIL: runner did not OK" >&2
  exit 1
}
echo "doc-public-roadmap gate OK"
