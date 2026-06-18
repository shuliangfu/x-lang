#!/usr/bin/env bash
# LANG-001：语法版本化 feature gate manifest 门禁
#
# 用法：./tests/run-lang-feature-gate-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_LANG_FEATURE_DOC:-analysis/lang-feature-gate-v1.md}"
MANIFEST="${SHU_LANG_FEATURE_MANIFEST:-tests/baseline/lang-feature-gate.tsv}"
CATALOG="${SHU_LANG_FEATURE_CATALOG:-tests/baseline/lang-feature-catalog.tsv}"
MIN_GATES=6
MIN_CASES=2
MIN_SYMBOLS=3

# shellcheck source=tests/lib/lang-feature-gate.sh
. tests/lib/lang-feature-gate.sh

echo "=== LANG-001: feature gate manifest ==="
for f in "$DOC" "$MANIFEST" "$CATALOG" docs/01-关键字.md \
  compiler/src/runtime.c scripts/shu-lang-edition.sh \
  tests/lang-feature/edition_stable.su tests/lang-feature/feature_match.su; do
  if [ ! -f "$f" ]; then
    echo "lang-feature-gate gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_gates) MIN_GATES="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_symbols) MIN_SYMBOLS="$c2" ;;
  esac
done < "$CATALOG"

MISS=0
GATE_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-feature-gate FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    gates)
      GATE_N=$((GATE_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-feature-gate FAIL: doc missing gate $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      if [ ! -f "$src" ]; then
        echo "lang-feature-gate FAIL: missing $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$src" 2>/dev/null; then
        echo "lang-feature-gate FAIL: $anchor not in $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    docs)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-feature-gate FAIL: missing doc $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-feature-gate FAIL: $path missing $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-feature-gate FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-feature-gate FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-feature-gate FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-feature-gate FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "lang-feature-gate FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-feature-gate FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

SYM_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$CATALOG")
if [ "$GATE_N" -lt "$MIN_GATES" ]; then
  echo "lang-feature-gate gate FAIL: gates=${GATE_N} < min ${MIN_GATES}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "lang-feature-gate gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$SYM_N" -lt "$MIN_SYMBOLS" ]; then
  echo "lang-feature-gate gate FAIL: symbols=${SYM_N} < min ${MIN_SYMBOLS}" >&2
  exit 1
fi

for kw in feature gate grayscale runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-feature-gate gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "lang-feature-gate gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "lang-feature-gate manifest OK (gates=${GATE_N} cases=${CASE_N} symbols=${SYM_N})"

chmod +x scripts/shu-lang-edition.sh tests/run-lang-feature-gate.sh
./tests/run-lang-feature-gate.sh

echo "lang-feature-gate gate OK"
