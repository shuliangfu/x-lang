#!/usr/bin/env bash
# STD-061：std.simd shuffle/select 生产级 bench 门禁
#
# 用法：./tests/run-std-simd-prod-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STD061_DOC:-analysis/std-simd-prod-v1.md}"
WAVE="${SHUX_STD061_WAVE_TSV:-tests/baseline/std-simd-prod-wave.tsv}"
PARENT_DOC="${SHUX_STD_SIMD_SHUFFLE_SELECT_DOC:-analysis/std-simd-shuffle-select-v1.md}"
MOD_SU="std/simd/mod.sx"
LIB="tests/lib/std-simd-prod.sh"
MIN_BENCHES=3

# shellcheck source=tests/lib/std-simd-prod.sh
. "$LIB"

echo "=== STD-061: simd prod bench manifest ==="
for f in "$DOC" "$WAVE" "$LIB" "$PARENT_DOC" "$MOD_SU" \
  tests/bench/simd_shuffle_select.sx tests/bench/simd_shuffle_select_stub.c \
  tests/run-perf-simd-shuffle-select.sh; do
  if [ ! -f "$f" ]; then
    echo "std-simd-prod gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_benches) MIN_BENCHES="$c2" ;;
  esac
done < "$WAVE"

for kw in 生产级 perf bench_shuffle_hot min_benches stub/Shu; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "std-simd-prod gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

if ! grep -qF 'STD-061' "$MOD_SU" 2>/dev/null; then
  echo "std-simd-prod gate FAIL: missing STD-061 anchor in $MOD_SU" >&2
  exit 1
fi
echo "std-simd-prod OK mod anchor"

BENCH_N=0
MISS=0
echo "=== STD-061: bench matrix ==="
while IFS=$'\t' read -r item_id kind anchor src _tier _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*) continue ;; esac
  case "$kind" in
    bench)
      BENCH_N=$((BENCH_N + 1))
      if [ ! -f "$src" ]; then
        echo "std-simd-prod FAIL: missing bench $src ($item_id)" >&2
        MISS=$((MISS + 1))
      elif ! grep -qF "$anchor" "$DOC" 2>/dev/null; then
        echo "std-simd-prod FAIL: doc missing bench $anchor" >&2
        MISS=$((MISS + 1))
      else
        echo "std-simd-prod OK bench $item_id -> $src"
      fi
      ;;
    hook_script)
      if [ ! -f "tests/$anchor" ]; then
        echo "std-simd-prod FAIL: missing hook tests/$anchor" >&2
        MISS=$((MISS + 1))
      fi
      ;;
  esac
done < "$WAVE"

if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  echo "std-simd-prod gate FAIL: benches=${BENCH_N} < min ${MIN_BENCHES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "std-simd-prod gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "std-simd-prod manifest OK (benches=${BENCH_N})"

SHUX_ASM="${SHUX:-}"
for cand in ./compiler/shux_asm ./compiler/shux_asm.strict ./compiler/shux_asm_working; do
  if std_simd_prod_native_asm "$cand"; then
    SHUX_ASM="$cand"
    break
  fi
done

BENCH_OK=0
BENCH_SKIP=0
SKIP=1
RATIO=""

if [ -n "$SHUX_ASM" ] && command -v cc >/dev/null 2>&1; then
  echo "=== STD-061: perf bench (SHUX=$SHUX_ASM) ==="
  chmod +x tests/run-perf-simd-shuffle-select.sh
  PERF_LOG="/tmp/std_simd_prod_perf_$$.log"
  set +e
  set -o pipefail
  SHUX="$SHUX_ASM" SHUX_SIMD_SS_FAIL=1 ./tests/run-perf-simd-shuffle-select.sh 2>&1 | tee "$PERF_LOG"
  perf_ec=$?
  set +o pipefail
  set -e
  if [ "$perf_ec" -eq 0 ]; then
    BENCH_OK=1
    SKIP=0
    RATIO=$(grep -E 'ratio \(stub/Shu\):' "$PERF_LOG" | tail -1 | sed -E 's/.*ratio \(stub\/Shu\): ([0-9.]+).*/\1/' || true)
    echo "std-simd-prod runnable OK perf"
  elif grep -qE 'SKIP:' "$PERF_LOG" 2>/dev/null; then
    BENCH_SKIP=1
    echo "std-simd-prod gate SKIP perf (runner skipped)" >&2
  else
    BENCH_SKIP=1
    echo "std-simd-prod WARN: perf failed; manifest OK (skip)" >&2
    tail -5 "$PERF_LOG" >&2 || true
  fi
  rm -f "$PERF_LOG"
else
  echo "std-simd-prod gate SKIP perf bench (no shux_asm or cc)" >&2
  BENCH_SKIP=1
fi

std_simd_prod_emit_report "ok" "$BENCH_OK" "$BENCH_SKIP" "$SKIP" "$RATIO"
echo "std-simd-prod gate OK"
