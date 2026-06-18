#!/usr/bin/env bash
# CORE-015：core/README 与 docs/07 同步门禁
#
# 用法：./tests/run-core-readme-sync-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_CORE_README_DOC:-analysis/core-readme-sync-v1.md}"
MANIFEST="${SHU_CORE_README_TSV:-tests/baseline/core-readme-sync.tsv}"
README="core/README.md"
DOC07="docs/07-内置与标准库.md"

# shellcheck source=tests/lib/core-readme-sync.sh
. tests/lib/core-readme-sync.sh

echo "=== CORE-015: core README / docs/07 sync ==="
for f in "$DOC" "$MANIFEST" "$README" "$DOC07"; do
  if [ ! -f "$f" ]; then
    echo "core-readme-sync gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in CORE-014 run-core-api-gate core.iterator; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-readme-sync gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

forbid_miss="$(core_readme_forbidden_ok "$README" "$DOC07" "$MANIFEST" || true)"
split="$(core_readme_anchor_miss_split "$README" "$DOC07" "$MANIFEST")"
readme_miss="${split%% *}"
doc_miss="${split#* }"
anchor_miss=$((readme_miss + doc_miss))

if [ "${forbid_miss:-0}" -gt 0 ] || [ "${anchor_miss:-0}" -gt 0 ]; then
  core_readme_emit_report "fail" "${forbid_miss:-0}" "$readme_miss" "$doc_miss"
  echo "core-readme-sync gate FAIL" >&2
  exit 1
fi

core_readme_emit_report "ok" 0 0 0
echo "core-readme-sync manifest OK"
echo "core-readme-sync gate OK"
