#!/usr/bin/env bash
# STD-154：std.db.sqlite 文档与 docs/07 统一门禁
#
# 用法：./tests/run-std-sqlite-docs-sync-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="analysis/std-sqlite-docs-sync-v1.md"
MANIFEST="tests/baseline/std-sqlite-docs-sync-manifest.tsv"
DOC07="docs/07-内置与标准库.md"
README_SQLITE="std/db/sqlite/README.md"
README_STD="std/README.md"
LIB="tests/lib/std-sqlite-docs-sync.sh"

# shellcheck source=tests/lib/std-sqlite-docs-sync.sh
. "$LIB"

echo "=== STD-154: sqlite docs sync manifest ==="
for f in "$DOC" "$MANIFEST" "$LIB" "$DOC07" "$README_SQLITE" "$README_STD"; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-docs-sync gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-154 prepare_cached pool_acquire DB_NOT_IMPL sqlite-o-stub; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-docs-sync gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF "sqlite-o-stub" "$README_SQLITE" 2>/dev/null; then
  echo "std-sqlite-docs-sync gate FAIL: std/db/sqlite/README missing sqlite-o-stub" >&2
  exit 1
fi

sym_miss="$(std_sqlite_docs_sync_symbols_ok "$DOC07" "$README_SQLITE" "$README_STD" "$MANIFEST" || true)"
if [ "${sym_miss:-0}" -gt 0 ]; then
  std_sqlite_docs_sync_emit_report "fail" "${sym_miss:-0}" 0
  exit 1
fi

if ! std_sqlite_docs_sync_forbidden_ok "$DOC07"; then
  std_sqlite_docs_sync_emit_report "fail" 1 0
  exit 1
fi

echo "std-sqlite-docs-sync registry OK"
std_sqlite_docs_sync_emit_report "ok" 0 0
echo "std-sqlite-docs-sync gate OK"
