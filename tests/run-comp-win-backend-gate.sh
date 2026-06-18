#!/usr/bin/env bash
# COMP-011：Windows 目标后端 manifest 门禁
#
# 用法：./tests/run-comp-win-backend-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP_WIN_BACKEND_DOC:-analysis/comp-win-backend-v1.md}"
MANIFEST="${SHU_COMP_WIN_BACKEND_MANIFEST:-tests/baseline/comp-win-backend.tsv}"
MATRIX="${SHU_WIN_BACKEND_MATRIX:-tests/baseline/comp-win-backend-matrix.tsv}"
MIN_LAYERS=6
MIN_CASES=6

# shellcheck source=tests/lib/comp-win-backend.sh
. tests/lib/comp-win-backend.sh

echo "=== COMP-011: Windows backend manifest ==="
for f in "$DOC" "$MANIFEST" "$MATRIX" \
  tests/lib/comp-win-backend.sh tests/run-comp-win-backend.sh \
  compiler/src/asm/platform/coff.su compiler/src/asm/platform/README.md \
  tests/asm/windows_min.su tests/run-asm.sh tests/baseline/ci-platform-matrix.tsv; do
  if [ ! -f "$f" ]; then
    echo "comp-win-backend gate FAIL: missing $f" >&2
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
        echo "comp-win-backend FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-win-backend FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ ! -f "$src" ]; then
        echo "comp-win-backend FAIL: missing layer src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-win-backend FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "comp-win-backend FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-win-backend FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-win-backend FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-win-backend FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-win-backend FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-win-backend FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-win-backend FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-win-backend FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-win-backend FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

CASE_M=0
while IFS=$'\t' read -r case_id sample _rest; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  CASE_M=$((CASE_M + 1))
  if ! grep -qF "$case_id" "$DOC" 2>/dev/null; then
    echo "comp-win-backend FAIL: doc missing matrix $case_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-win-backend gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt 2 ]; then
  echo "comp-win-backend gate FAIL: manifest cases=${CASE_N} < 2" >&2
  exit 1
fi
if [ "$CASE_M" -lt "$MIN_CASES" ]; then
  echo "comp-win-backend gate FAIL: matrix cases=${CASE_M} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in windows backend COFF runnable report sample; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-win-backend gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if ! grep -qF 'use_coff_o' compiler/src/ast/ast.su 2>/dev/null; then
  echo "comp-win-backend gate FAIL: ast.su missing use_coff_o" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "comp-win-backend gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-win-backend manifest OK (layers=${LAYER_N} matrix=${CASE_M})"

chmod +x tests/run-comp-win-backend.sh
./tests/run-comp-win-backend.sh

echo "comp-win-backend gate OK"
