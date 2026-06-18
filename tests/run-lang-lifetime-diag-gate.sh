#!/usr/bin/env bash
# LANG-008：生命周期错误友好化 manifest 门禁
#
# 用法：./tests/run-lang-lifetime-diag-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_LANG_LIFETIME_DIAG_DOC:-analysis/lang-lifetime-diag-v1.md}"
MANIFEST="${SHU_LANG_LIFETIME_DIAG_MANIFEST:-tests/baseline/lang-lifetime-diag.tsv}"
MATRIX="${SHU_LANG_LIFETIME_DIAG_CASES:-tests/baseline/lang-lifetime-diag-cases.tsv}"
MIN_LAYERS=6
MIN_CASES=4

# shellcheck source=tests/lib/lang-lifetime-diag.sh
. tests/lib/lang-lifetime-diag.sh

echo "=== LANG-008: lifetime diagnostic manifest ==="
for f in "$DOC" "$MANIFEST" "$MATRIX" \
  analysis/type-region-v1-rfc.md \
  compiler/src/lsp/lsp_diag.c compiler/src/typeck/typeck.c \
  tests/typeck/slice_lifetime/region_assign_escape.su; do
  if [ ! -f "$f" ]; then
    echo "lang-lifetime-diag gate FAIL: missing $f" >&2
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

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-lifetime-diag FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "lang-lifetime-diag FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "lang-lifetime-diag FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "lang-lifetime-diag FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "lang-lifetime-diag FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

MATRIX_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$MATRIX")
while IFS=$'\t' read -r case_id file substr want_line _notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  if ! grep -qF "$case_id" "$DOC" 2>/dev/null; then
    echo "lang-lifetime-diag FAIL: doc missing matrix case $case_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "lang-lifetime-diag gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "lang-lifetime-diag gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MATRIX_N" -lt "$MIN_CASES" ]; then
  echo "lang-lifetime-diag gate FAIL: matrix=${MATRIX_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in lifetime diagnostic friendly source runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "lang-lifetime-diag gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "lang-lifetime-diag gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "lang-lifetime-diag manifest OK (layers=${LAYER_N} cases=${CASE_N} matrix=${MATRIX_N})"

chmod +x tests/run-lang-lifetime-diag.sh
./tests/run-lang-lifetime-diag.sh

echo "lang-lifetime-diag gate OK"
