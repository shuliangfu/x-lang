#!/usr/bin/env bash
# TYPE-003：借用规则冲突诊断 manifest 门禁
#
# 用法：./tests/run-type-borrow-conflict-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_TYPE_BORROW_DOC:-analysis/type-borrow-conflict-v1.md}"
MANIFEST="${SHU_TYPE_BORROW_MANIFEST:-tests/baseline/type-borrow-conflict.tsv}"
MATRIX="${SHU_TYPE_BORROW_CASES:-tests/baseline/type-borrow-conflict-cases.tsv}"
MIN_LAYERS=6
MIN_CASES=6

# shellcheck source=tests/lib/type-borrow-conflict.sh
. tests/lib/type-borrow-conflict.sh

echo "=== TYPE-003: borrow conflict manifest ==="
for f in "$DOC" "$MANIFEST" "$MATRIX" \
  analysis/type-linear-v1-rfc.md analysis/type-region-v1-rfc.md \
  compiler/src/typeck/typeck.c \
  tests/typeck/borrow/fp_linear_two_bindings_ok.su; do
  if [ ! -f "$f" ]; then
    echo "type-borrow-conflict gate FAIL: missing $f" >&2
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
        echo "type-borrow-conflict FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "type-borrow-conflict FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "type-borrow-conflict FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "type-borrow-conflict FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "type-borrow-conflict FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "type-borrow-conflict FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "type-borrow-conflict FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-borrow-conflict FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "type-borrow-conflict FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-borrow-conflict FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

MATRIX_N=$(awk -F'\t' '$1 !~ /^#/ && NF>=2 { n++ } END { print n+0 }' "$MATRIX")
while IFS=$'\t' read -r case_id file _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  if ! grep -qF "$case_id" "$DOC" 2>/dev/null; then
    echo "type-borrow-conflict FAIL: doc missing matrix case $case_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "type-borrow-conflict gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "type-borrow-conflict gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$MATRIX_N" -lt "$MIN_CASES" ]; then
  echo "type-borrow-conflict gate FAIL: matrix=${MATRIX_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in borrow conflict false positive runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "type-borrow-conflict gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "type-borrow-conflict gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "type-borrow-conflict manifest OK (layers=${LAYER_N} cases=${CASE_N} matrix=${MATRIX_N})"

chmod +x tests/run-type-borrow-conflict.sh
./tests/run-type-borrow-conflict.sh

echo "type-borrow-conflict gate OK"
