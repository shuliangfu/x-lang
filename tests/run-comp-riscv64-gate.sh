#!/usr/bin/env bash
# COMP-012：riscv64 回归 manifest 门禁
#
# 用法：./tests/run-comp-riscv64-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_COMP_RISCV64_DOC:-analysis/comp-riscv64-v1.md}"
MANIFEST="${SHU_COMP_RISCV64_MANIFEST:-tests/baseline/comp-riscv64.tsv}"
MATRIX="${SHU_RISCV64_MATRIX:-tests/baseline/comp-riscv64-matrix.tsv}"
MIN_LAYERS=6
MIN_CASES=6

# shellcheck source=tests/lib/comp-riscv64.sh
. tests/lib/comp-riscv64.sh

echo "=== COMP-012: riscv64 regression manifest ==="
for f in "$DOC" "$MANIFEST" "$MATRIX" \
  tests/lib/comp-riscv64.sh tests/run-comp-riscv64.sh \
  compiler/src/asm/arch/riscv64.su compiler/src/asm/arch/riscv64_enc.su \
  compiler/src/asm/backend.su tests/asm/riscv64_min.su tests/run-asm.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-riscv64 gate FAIL: missing $f" >&2
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
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-riscv64 FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-riscv64 FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      if [ ! -f "$src" ]; then
        echo "comp-riscv64 FAIL: missing layer src $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-riscv64 FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "comp-riscv64 FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      if [ ! -f "$src" ]; then
        echo "comp-riscv64 FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "comp-riscv64 FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-riscv64 FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-riscv64 FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-riscv64 FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-riscv64 FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-riscv64 FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-riscv64 FAIL: doc missing hook $anchor" >&2
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
    echo "comp-riscv64 FAIL: doc missing matrix $case_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ "$sample" != "run-asm.sh" ] && ! comp_riscv64_sample_path "$sample" >/dev/null 2>&1; then
    echo "comp-riscv64 FAIL: matrix missing sample $sample" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-riscv64 gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_M" -lt "$MIN_CASES" ]; then
  echo "comp-riscv64 gate FAIL: matrix cases=${CASE_M} < min ${MIN_CASES}" >&2
  exit 1
fi

for kw in riscv64 regression ELF runnable report stable; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-riscv64 gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if ! grep -q 'ta == 2' compiler/src/asm/backend.su 2>/dev/null; then
  echo "comp-riscv64 gate FAIL: backend.su missing riscv64 dispatch" >&2
  exit 1
fi

if [ "$MISS" -gt 0 ]; then
  echo "comp-riscv64 gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-riscv64 manifest OK (layers=${LAYER_N} matrix=${CASE_M})"

if [ "${SHU_COMP_RISCV64_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "comp-riscv64 gate OK (manifest only)"
  exit 0
fi

chmod +x tests/run-comp-riscv64.sh
./tests/run-comp-riscv64.sh

echo "comp-riscv64 gate OK"
