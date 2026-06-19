#!/usr/bin/env bash
# TOOL-008：依赖锁定 manifest 门禁
#
# 用法：./tests/run-tool-deps-lock-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TOOL_DEPS_LOCK_DOC:-analysis/tool-deps-lock-v1.md}"
MANIFEST="${SHUX_TOOL_DEPS_LOCK_MANIFEST:-tests/baseline/tool-deps-lock.tsv}"
PKG_TSV=tests/fixtures/pkgmgr/shux.pkg.tsv
LOCK_TSV=tests/fixtures/pkgmgr/shux.pkg.lock.tsv
MIN_RULES=6
MIN_LOCKED=2

# shellcheck source=tests/lib/tool-deps-lock.sh
. tests/lib/tool-deps-lock.sh

echo "=== TOOL-008: deps lock manifest ==="
for f in "$DOC" "$MANIFEST" "$PKG_TSV" "$LOCK_TSV" \
  scripts/shux-deps-lock.sh scripts/shux-deps-verify.sh analysis/tool-pkgmgr-v1.md; do
  if [ ! -f "$f" ]; then
    echo "tool-deps-lock gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
    min_locked) MIN_LOCKED="$c2" ;;
  esac
done < "$MANIFEST"

MISS=0
RULE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-deps-lock FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    rules)
      RULE_N=$((RULE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "tool-deps-lock FAIL: doc missing rule $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    cross_ref)
      if [ ! -f "$anchor" ]; then
        echo "tool-deps-lock FAIL: missing cross $anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "TOOL-008" "$anchor" 2>/dev/null; then
        echo "tool-deps-lock FAIL: $anchor missing TOOL-008 ref" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    file)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-deps-lock FAIL: missing file $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "tool-deps-lock FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-deps-lock FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "tool-deps-lock FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "tool-deps-lock FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

LOCKED_N=$(grep -c '^locked' "$LOCK_TSV" 2>/dev/null || echo 0)
if [ "$RULE_N" -lt "$MIN_RULES" ]; then
  echo "tool-deps-lock gate FAIL: rules=${RULE_N} < min ${MIN_RULES}" >&2
  exit 1
fi
if [ "$LOCKED_N" -lt "$MIN_LOCKED" ]; then
  echo "tool-deps-lock gate FAIL: locked=${LOCKED_N} < min ${MIN_LOCKED}" >&2
  exit 1
fi

for kw in lock reproducible replay sha256 runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "tool-deps-lock gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "tool-deps-lock gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "tool-deps-lock manifest OK (rules=${RULE_N} locked=${LOCKED_N})"

chmod +x scripts/shux-deps-lock.sh scripts/shux-deps-verify.sh tests/run-deps-lock.sh
./tests/run-deps-lock.sh

echo "tool-deps-lock gate OK"
