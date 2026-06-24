#!/usr/bin/env bash
# TYPE-005：零成本抽象 manifest 门禁
#
# 用法：./tests/run-type-zero-cost-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_TYPE_ZC_DOC:-analysis/type-zero-cost-v1.md}"
MANIFEST="${SHUX_TYPE_ZC_MANIFEST:-tests/baseline/type-zero-cost.tsv}"
BENCH="${SHUX_TYPE_ZC_BENCH:-tests/baseline/type-zero-cost-bench.tsv}"
MIN_LAYERS=6
MIN_CASES=4
MIN_BENCHES=6

# shellcheck source=tests/lib/type-zero-cost.sh
. tests/lib/type-zero-cost.sh

echo "=== TYPE-005: zero-cost abstraction manifest ==="
for f in "$DOC" "$MANIFEST" "$BENCH" \
  analysis/type-linear-v1-rfc.md analysis/type-region-v1-rfc.md \
  tests/bench/{loop_i32,mem_copy,struct_param,call_boundary}.sx \
  tests/bench/generic_id_i32.sx tests/typeck/linear/move_ok.sx \
  tests/run-bcmp-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "type-zero-cost gate FAIL: missing $f" >&2
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
        echo "type-zero-cost FAIL: doc missing section $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    layers)
      LAYER_N=$((LAYER_N + 1))
      if ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "type-zero-cost FAIL: doc missing layer $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    symbol)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "type-zero-cost FAIL: missing $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$path" 2>/dev/null; then
        echo "type-zero-cost FAIL: $anchor not in $path" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    case)
      CASE_N=$((CASE_N + 1))
      if [ ! -f "$src" ]; then
        echo "type-zero-cost FAIL: missing case $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$src")" "$DOC" 2>/dev/null; then
        echo "type-zero-cost FAIL: doc missing case $src" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_ref)
      if [ ! -f "$src" ]; then
        echo "type-zero-cost FAIL: missing hook $src" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-zero-cost FAIL: doc missing hook $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    script)
      path="${src:-$anchor}"
      if [ ! -f "$path" ]; then
        echo "type-zero-cost FAIL: missing script $path" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-zero-cost FAIL: doc missing script $anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "type-zero-cost FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$(basename "$anchor")" "$DOC" 2>/dev/null; then
        echo "type-zero-cost FAIL: doc missing hook $anchor" >&2
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
  if ! grep -qF "$bench_id" "$DOC" 2>/dev/null; then
    echo "type-zero-cost FAIL: doc missing bench $bench_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! type_zero_cost_bench_sx "$sx_file" >/dev/null 2>&1; then
    echo "type-zero-cost FAIL: missing bench sx $sx_file" >&2
    MISS=$((MISS + 1))
  fi
done < "$BENCH"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  echo "type-zero-cost gate FAIL: layers=${LAYER_N} < min ${MIN_LAYERS}" >&2
  exit 1
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  echo "type-zero-cost gate FAIL: cases=${CASE_N} < min ${MIN_CASES}" >&2
  exit 1
fi
if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  echo "type-zero-cost gate FAIL: benches=${BENCH_N} < min ${MIN_BENCHES}" >&2
  exit 1
fi

for kw in zero cost abstraction copy runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    echo "type-zero-cost gate FAIL: doc missing keyword $kw" >&2
    exit 1
  fi
done

if [ "$MISS" -gt 0 ]; then
  echo "type-zero-cost gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "type-zero-cost manifest OK (layers=${LAYER_N} cases=${CASE_N} benches=${BENCH_N})"

chmod +x tests/run-type-zero-cost.sh
./tests/run-type-zero-cost.sh

echo "type-zero-cost gate OK"
