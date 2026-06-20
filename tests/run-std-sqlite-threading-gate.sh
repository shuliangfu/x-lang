#!/usr/bin/env bash
# STD-138：std.db.sqlite 跨线程连接语义文档门禁
#
# 用法：./tests/run-std-sqlite-threading-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD138_DOC:-analysis/std-sqlite-threading-v1.md}"
MANIFEST="${SHUX_STD138_TSV:-tests/baseline/std-sqlite-threading.tsv}"
README="std/db/sqlite/README.md"

STD_DB_THREADING_PREFIX="${SHUX_STD138_PREFIX:-shux: [SHUX_STD138_DB_THREADING]}"

echo "=== STD-138: sqlite threading manifest ==="
for f in "$DOC" "$MANIFEST" "$README" analysis/std-sqlite-pool-v1.md; do
  if [ ! -f "$f" ]; then
    echo "std-sqlite-threading gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in STD-138 DbConn pool_acquire last_error; do
  if ! grep -qF -- "$kw" "$DOC" 2>/dev/null; then
    echo "std-sqlite-threading gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

MISS=0
while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    readme)
      if ! grep -qF "跨线程" "$anchor" 2>/dev/null; then
        echo "std-sqlite-threading FAIL: README missing 跨线程 section" >&2
        MISS=$((MISS + 1))
      fi
      if ! grep -qF "std-sqlite-threading-v1.md" "$anchor" 2>/dev/null; then
        echo "std-sqlite-threading FAIL: README missing threading doc link" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "std-sqlite-threading FAIL: missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$MISS" -gt 0 ]; then
  echo "${STD_DB_THREADING_PREFIX} status=fail doc=0 readme=0"
  exit 1
fi

echo "${STD_DB_THREADING_PREFIX} status=ok doc=1 readme=1"
echo "std-sqlite-threading gate OK"
