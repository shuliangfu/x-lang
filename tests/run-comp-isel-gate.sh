#!/usr/bin/env bash
# COMP-006：指令选择优化 manifest 门禁
#
# 用法：./tests/run-comp-isel-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP_ISEL_DOC:-analysis/comp-isel-v1.md}"
MANIFEST="${SHUX_COMP_ISEL_MANIFEST:-tests/baseline/comp-isel.tsv}"
BENCH="${SHUX_COMP_ISEL_BENCH:-tests/baseline/comp-isel-bench.tsv}"
MIN_LAYERS=6
MIN_CASES=8
MIN_BENCHES=9

# shellcheck source=tests/lib/comp-isel.sh
. tests/lib/comp-isel.sh

echo "=== COMP-006: instruction selection manifest ==="
for f in "$DOC" "$MANIFEST" "$BENCH" \
  compiler/src/asm/peephole.sx compiler/src/asm/backend.sx \
  tests/asm/binop_var_fast.sx tests/asm/binop_index_lit_fast.sx \
  tests/bench/loop_i32.sx tests/run-bcmp-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-isel gate FAIL: missing $f" >&2
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
    min_benches) MIN_BENCHES="$c2" ;;
  esac
done < "$BENCH"

MISS=0
LAYER_N=0
CASE_N=0
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    section)
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-isel FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "comp-isel FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-isel FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "comp-isel FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "comp-isel FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null \
        && ! grep -qF "$(basename "$src")" analysis/comp-isel-p0-v1.md 2>/dev/null; then
        echo "comp-isel FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "comp-isel FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-isel FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "comp-isel FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "comp-isel FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "comp-isel FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null \
        && ! grep -qF "$(basename "$anchor")" analysis/comp-isel-p0-v1.md 2>/dev/null; then
        echo "comp-isel FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

BENCH_N=0
while IFS=$'\t' read -r bench_id sx_file _rest; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*) continue ;; esac
  BENCH_N=$((BENCH_N + 1))
  if ! grep -qF "$bench_id" "$DOC" 2>/dev/null \
    && ! grep -qF "$bench_id" analysis/comp-isel-p0-v1.md 2>/dev/null; then
    echo "comp-isel FAIL: doc missing bench $bench_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! comp_isel_bench_path "$sx_file" >/dev/null 2>&1; then
    echo "comp-isel FAIL: missing bench sx $sx_file" >&2
    MISS=$((MISS + 1))
  fi
done < "$BENCH"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "comp-isel gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "comp-isel gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  echo "comp-isel gate FAIL: benches=${BENCH_N} < min ${MIN_BENCHES}" >&2
  exit 1
fi

for kw in instruction selection peephole microbench runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-isel gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "comp-isel gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-isel manifest OK (layers=${LAYER_N} cases=${CASE_N} benches=${BENCH_N})"

chmod +x tests/run-comp-isel.sh
./tests/run-comp-isel.sh

echo "comp-isel gate OK"
