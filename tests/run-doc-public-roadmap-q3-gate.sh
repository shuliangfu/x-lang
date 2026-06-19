#!/usr/bin/env bash
# DOC-013：2027-Q3 对外路线图刷新门禁
#
# 1) doc-public-roadmap-q3-v1.md + manifest 锚点
# 2) quarter=2027-Q3 三处对齐（doc / doc-public-roadmap.tsv / template）
# 3) 联动 DOC-005 run-doc-public-roadmap-gate.sh
#
# 用法：./tests/run-doc-public-roadmap-q3-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_DOC013_DOC:-analysis/doc-public-roadmap-q3-v1.md}"
ROADMAP="analysis/doc-public-roadmap-v1.md"
MANIFEST="${SHUX_DOC013_TSV:-tests/baseline/doc-public-roadmap-q3.tsv}"
DOC005_MANIFEST="tests/baseline/doc-public-roadmap.tsv"
TEMPLATE="tests/templates/doc-public-roadmap-quarter.txt"
LIB="tests/lib/doc-public-roadmap-q3.sh"
DOC005_GATE="tests/run-doc-public-roadmap-gate.sh"
QUARTER="2027-Q3"

# shellcheck source=tests/lib/doc-public-roadmap-q3.sh
. "$LIB"
# shellcheck source=tests/lib/doc-public-roadmap.sh
. tests/lib/doc-public-roadmap.sh

echo "=== DOC-013: Q3 roadmap refresh manifest ==="
for f in "$DOC" "$ROADMAP" "$MANIFEST" "$DOC005_MANIFEST" "$TEMPLATE" "$LIB" "$DOC005_GATE"; do
  if [ ! -f "$f" ]; then
    echo "doc-public-roadmap-q3 gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in 2027-Q3 Phase 3 quarterly; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "doc-public-roadmap-q3 gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

sym_miss="$(doc_roadmap_q3_check "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  doc_roadmap_q3_emit_report "fail" "$QUARTER" 0
  exit 1
fi

q_manifest="$(doc_roadmap_quarter_from_manifest "$DOC005_MANIFEST")"
if [ "$q_manifest" != "$QUARTER" ]; then
  echo "doc-public-roadmap-q3 gate FAIL: doc005 manifest quarter=$q_manifest want $QUARTER" >&2
  doc_roadmap_q3_emit_report "fail" "$QUARTER" 0
  exit 1
fi
if ! doc_roadmap_quarter_ok "$ROADMAP" "$QUARTER"; then
  echo "doc-public-roadmap-q3 gate FAIL: roadmap doc missing $QUARTER" >&2
  doc_roadmap_q3_emit_report "fail" "$QUARTER" 0
  exit 1
fi
if ! grep -qF "$QUARTER" "$TEMPLATE" 2>/dev/null; then
  echo "doc-public-roadmap-q3 gate FAIL: template missing $QUARTER" >&2
  doc_roadmap_q3_emit_report "fail" "$QUARTER" 0
  exit 1
fi
echo "doc-public-roadmap-q3 manifest OK (quarter=${QUARTER})"

echo "=== DOC-013: DOC-005 roadmap gate (delegated) ==="
chmod +x "$DOC005_GATE" tests/run-doc-public-roadmap.sh tests/lib/doc-public-roadmap.sh
if ! ./"$DOC005_GATE" >/tmp/doc_public_roadmap_q3_delegate.log 2>&1; then
  tail -15 /tmp/doc_public_roadmap_q3_delegate.log >&2 || true
  doc_roadmap_q3_emit_report "fail" "$QUARTER" 0
  exit 1
fi
grep -q 'doc-public-roadmap gate OK' /tmp/doc_public_roadmap_q3_delegate.log || {
  echo "doc-public-roadmap-q3 gate FAIL: DOC-005 gate did not OK" >&2
  doc_roadmap_q3_emit_report "fail" "$QUARTER" 0
  exit 1
}

doc_roadmap_q3_emit_report "ok" "$QUARTER" 1
echo "doc-public-roadmap-q3 gate OK"
