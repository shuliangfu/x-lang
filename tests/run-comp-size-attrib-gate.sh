#!/usr/bin/env bash
# COMP-010：编译产物体积归因 manifest 门禁
#
# 用法：./tests/run-comp-size-attrib-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP_SIZE_ATTRIB_DOC:-analysis/comp-size-attrib-v1.md}"
MANIFEST="${SHUX_COMP_SIZE_ATTRIB_MANIFEST:-tests/baseline/comp-size-attrib.tsv}"
MATRIX="${SHUX_SIZE_ATTRIB_MATRIX:-tests/baseline/comp-size-attrib-matrix.tsv}"
MIN_LAYERS=6
MIN_ARTIFACTS=8
MIN_CASES=3

# shellcheck source=tests/lib/comp-size-attrib.sh
. tests/lib/comp-size-attrib.sh

echo "=== COMP-010: size attribution manifest ==="
for f in "$DOC" "$MANIFEST" "$MATRIX" \
  tests/lib/comp-size-attrib.sh tests/run-comp-size-attrib.sh \
  tests/run-size-shux-asm-gate.sh tests/baseline/shux-asm-size.tsv \
  tests/run-size-baseline.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-size-attrib gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_artifacts) MIN_ARTIFACTS="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_artifacts) MIN_ARTIFACTS="$c2" ;;
  esac
done < "$MATRIX"

MISS=0
LAYER_N=0
CASE_N=0
ART_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-size-attrib FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-size-attrib FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-size-attrib FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-size-attrib FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-size-attrib FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-size-attrib FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-size-attrib FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-size-attrib FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-size-attrib FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-size-attrib FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

while IFS=$'\t' read -r art_id _kind _path _policy _notes; do
  [ -z "${art_id:-}" ] && continue
  case "$art_id" in \#*|min_*) continue ;; esac
  ART_N=$((ART_N + 1))
  if ! grep -qF "$art_id" "$DOC" 2>/dev/null; then
    echo "comp-size-attrib FAIL: doc missing artifact $art_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-size-attrib gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$ART_N" -lt "$MIN_ARTIFACTS" ]; then
  echo "comp-size-attrib gate FAIL: artifacts=${ART_N} < min ${MIN_ARTIFACTS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "comp-size-attrib gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in attribution distribution size report runnable binary; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-size-attrib gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "comp-size-attrib gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-size-attrib manifest OK (layers=${LAYER_N} artifacts=${ART_N} cases=${CASE_N})"

chmod +x tests/run-comp-size-attrib.sh
./tests/run-comp-size-attrib.sh

echo "comp-size-attrib gate OK"
