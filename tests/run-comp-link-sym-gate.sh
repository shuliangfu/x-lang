#!/usr/bin/env bash
# COMP-008：链接符号冲突诊断 manifest 门禁
#
# 用法：./tests/run-comp-link-sym-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP_LINK_SYM_DOC:-analysis/comp-link-sym-v1.md}"
MANIFEST="${SHUX_COMP_LINK_SYM_MANIFEST:-tests/baseline/comp-link-sym.tsv}"
PATTERNS="${SHUX_LINK_SYM_PATTERNS:-tests/baseline/comp-link-sym-patterns.tsv}"
CASES="${SHUX_LINK_SYM_CASES:-tests/baseline/comp-link-sym-cases.tsv}"
MIN_LAYERS=6
MIN_CASES=6

# shellcheck source=tests/lib/comp-link-sym.sh
. tests/lib/comp-link-sym.sh

echo "=== COMP-008: link symbol conflict manifest ==="
for f in "$DOC" "$MANIFEST" "$PATTERNS" "$CASES" \
  tests/lib/comp-link-sym.sh tests/run-comp-link-sym.sh \
  compiler/scripts/relink_shux_asm_strict_glue.sh \
  tests/run-bootstrap-stage-diag-gate.sh tests/run-wpo-strict-link-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-link-sym gate FAIL: missing $f" >&2
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
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$CASES"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-link-sym FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-link-sym FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ ! -f "$src" ]; then
        echo "comp-link-sym FAIL: missing layer src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-link-sym FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-link-sym FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-link-sym FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-link-sym FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-link-sym FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-link-sym FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-link-sym FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-link-sym FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-link-sym gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "comp-link-sym gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in conflict attribution duplicate undefined report runnable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-link-sym gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "comp-link-sym gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-link-sym manifest OK (layers=${LAYER_N} cases=${CASE_N})"

chmod +x tests/run-comp-link-sym.sh
./tests/run-comp-link-sym.sh

echo "comp-link-sym gate OK"
