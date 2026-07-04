#!/usr/bin/env bash
# COMP-009：前端/后端接口契约 manifest 门禁
#
# 用法：./tests/run-comp-feb-contract-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP_FEB_CONTRACT_DOC:-analysis/comp-feb-contract-v1.md}"
MANIFEST="${SHUX_COMP_FEB_CONTRACT_MANIFEST:-tests/baseline/comp-feb-contract.tsv}"
BOUNDARY="${SHUX_FEB_CONTRACT_BOUNDARY:-tests/baseline/comp-feb-contract-boundary.tsv}"
MIN_LAYERS=6
MIN_BOUNDARIES=8
MIN_CASES=6

# shellcheck source=tests/lib/comp-feb-contract.sh
. tests/lib/comp-feb-contract.sh

echo "=== COMP-009: frontend/backend contract manifest ==="
for f in "$DOC" "$MANIFEST" "$BOUNDARY" \
  tests/lib/comp-feb-contract.sh tests/run-comp-feb-contract.sh \
  compiler/src/pipeline/pipeline.x compiler/pipeline_glue.c \
  tests/run-s3-pipeline-gate.sh analysis/doc-selfhost-architecture-v1.md; do
  if [ ! -f "$f" ]; then
    echo "comp-feb-contract gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_layers) MIN_LAYERS="$c2" ;;
    min_boundaries) MIN_BOUNDARIES="$c2" ;;
    min_cases) MIN_CASES="$c2" ;;
  esac
done < "$MANIFEST"

MIN_B_FROM_TABLE=0
while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_boundaries) MIN_B_FROM_TABLE="$c2" ;;
  esac
done < "$BOUNDARY"
if [ "${MIN_B_FROM_TABLE:-0}" -gt 0 ]; then
  MIN_BOUNDARIES="$MIN_B_FROM_TABLE"
fi

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-feb-contract FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-feb-contract FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ ! -f "$src" ]; then
        echo "comp-feb-contract FAIL: missing layer src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-feb-contract FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-feb-contract FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-feb-contract FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-feb-contract FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-feb-contract FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-feb-contract FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-feb-contract FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-feb-contract FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

BOUND_N="$(comp_feb_contract_boundary_count)"
while IFS=$'\t' read -r bid _layer _up _down sym _payload src; do
  [ -z "${bid:-}" ] && continue
  case "$bid" in \#*|min_*) continue ;; esac
  if ! grep -qF "$bid" "$DOC" 2>/dev/null; then
    echo "comp-feb-contract FAIL: doc missing boundary $bid" >&2
    MISS=$((MISS + 1))
  fi
  if [ ! -f "$src" ]; then
    echo "comp-feb-contract FAIL: boundary missing src $src" >&2
    MISS=$((MISS + 1))
  elif ! grep -qF "$sym" "$DOC" 2>/dev/null; then
    echo "comp-feb-contract FAIL: doc missing symbol $sym" >&2
    MISS=$((MISS + 1))
  fi
done < "$BOUNDARY"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-feb-contract gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$BOUND_N" -lt "$MIN_BOUNDARIES" ]; then
  echo "comp-feb-contract gate FAIL: boundaries=${BOUND_N} < min ${MIN_BOUNDARIES}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "comp-feb-contract gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in contract boundary frontend backend Module runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-feb-contract gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "comp-feb-contract gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-feb-contract manifest OK (layers=${LAYER_N} boundaries=${BOUND_N} cases=${CASE_N})"

chmod +x tests/run-comp-feb-contract.sh
./tests/run-comp-feb-contract.sh

echo "comp-feb-contract gate OK"
