#!/usr/bin/env bash
# STBL-002：std/README 与实现同步门禁
#
# 用法：./tests/run-stbl-readme-sync-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STBL_README_DOC:-analysis/stbl-readme-sync-v1.md}"
MANIFEST="${SHUX_STBL_README_TSV:-tests/baseline/stbl-readme-sync.tsv}"
README="std/README.md"
PREFIX="shux: [SHUX_STBL_README]"

# shellcheck source=tests/lib/stbl-readme-sync.sh
. tests/lib/stbl-readme-sync.sh

echo "=== STBL-002: std README sync manifest ==="
for f in "$DOC" "$MANIFEST" "$README"; do
  if [ ! -f "$f" ]; then
    echo "stbl-readme-sync gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in runnable STBL-002 scheduler.c spawn_simple; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "stbl-readme-sync gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

forbid_miss="$(stbl_readme_forbidden_ok "$README" "$MANIFEST" || true)"
anchor_miss="$(stbl_readme_anchors_ok "$README" "$MANIFEST" || true)"

if [ "${forbid_miss:-0}" -gt 0 ] || [ "${anchor_miss:-0}" -gt 0 ]; then
  stbl_readme_emit_report "fail" "${forbid_miss:-0}" "${anchor_miss:-0}"
  echo "stbl-readme-sync gate FAIL" >&2
  exit 1
fi

stbl_readme_emit_report "ok" 0 0
echo "stbl-readme-sync manifest OK"
echo "stbl-readme-sync gate OK"
