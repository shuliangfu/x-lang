#!/usr/bin/env bash
# LANG-004：trait/接口约束 manifest 门禁
#
# 用法：./tests/run-lang-trait-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_LANG_TRAIT_DOC:-analysis/lang-trait-v1.md}"
MANIFEST="${SHUX_LANG_TRAIT_MANIFEST:-tests/baseline/lang-trait.tsv}"
TYPECK="${SHUX_LANG_TRAIT_TYPECK:-tests/baseline/lang-trait-typeck.tsv}"
MIN_LAYERS=6
MIN_CASES=3
MIN_RULES=4

# shellcheck source=tests/lib/lang-trait.sh
. tests/lib/lang-trait.sh

echo "=== LANG-004: trait interface manifest ==="
for f in "$DOC" "$MANIFEST" "$TYPECK" \
  tests/trait/main.x tests/trait/method_no_impl.x tests/trait/impl_missing_method.x \
  compiler/src/typeck/typeck.c compiler/src/parser/parser.c; do
  if [ ! -f "$f" ]; then
    echo "lang-trait gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_rules) MIN_RULES="$c2" ;;
  esac
done < "$TYPECK"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-trait FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-trait FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-trait FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-trait FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-trait FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-trait FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-trait FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-trait FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "lang-trait FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-trait FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

RULE_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$TYPECK")
RULE_HIT=0
while IFS=$'\t' read -r rule_id err_substr _pipe _status _notes; do
  [ -z "${rule_id:-}" ] && continue
  case "$rule_id" in \#*|min_*) continue ;; esac
  RULE_HIT=$((RULE_HIT + 1))
  if ! grep -qF "$err_substr" "$DOC" 2>/dev/null && ! grep -qF "$err_substr" compiler/src/typeck/typeck.c 2>/dev/null; then
    echo "lang-trait FAIL: typeck rule $rule_id missing substr $err_substr" >&2
    MISS=$((MISS + 1))
  fi
done < "$TYPECK"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "lang-trait gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "lang-trait gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$RULE_HIT" -lt "$MIN_RULES" ]; then
  echo "lang-trait gate FAIL: rules=${RULE_HIT} < min ${MIN_RULES}" >&2
  exit 1
fi

for kw in trait interface typeck constraint runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-trait gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "lang-trait gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "lang-trait manifest OK (layers=${LAYER_N} cases=${CASE_N} rules=${RULE_HIT})"

chmod +x tests/run-lang-trait.sh tests/run-trait.sh
./tests/run-lang-trait.sh

echo "lang-trait gate OK"
