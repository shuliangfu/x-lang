#!/usr/bin/env bash
# TYPE-005: zero-cost abstraction manifest + runnable gate (honesty soft→硬绿).
#
# Honesty: soft SKIP→OK when no native + prefer-c + soft auto-make + fossil
# top-level DOC / bench/loop_i32.x / codegen.c retired. Prefer product
# xlang_asm; pin XLANG_LINK_XLANG. Explicit bad XLANG / missing native =
# hard die. DOC authority = archive/type. Report run=/obs=/skip=.
#
# Usage: ./tests/run-type-zero-cost-gate.sh
# wave honesty (2026-08-28): DOC → analysis/archive/type/;
# fossil benches → r01_/m03_/r10_/a01_*; codegen.c retired → codegen.x.
# PLATFORM: SHARED archaeology.
set -euo pipefail
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. tests/lib/ci-host.sh

DOC="${XLANG_TYPE_ZC_DOC:-analysis/archive/type/type-zero-cost-v1.md}"
MANIFEST="${XLANG_TYPE_ZC_MANIFEST:-tests/baseline/type-zero-cost.tsv}"
BENCH="${XLANG_TYPE_ZC_BENCH:-tests/baseline/type-zero-cost-bench.tsv}"
MIN_LAYERS=6
MIN_CASES=4
MIN_BENCHES=6
PREFIX="${XLANG_TYPE_ZC_PREFIX:-xlang: [XLANG_TYPE_ZERO_COST]}"

RUN_OK=0
OBS=0
SKIP=0

# shellcheck source=tests/lib/type-zero-cost.sh
. tests/lib/type-zero-cost.sh

die() {
  echo "type-zero-cost gate FAIL: $*" >&2
  echo "${PREFIX} status=fail run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
  exit 1
}

ok_report() {
  echo "${PREFIX} status=ok run=${RUN_OK} obs=${OBS} skip=${SKIP} host=$(ci_host_summary)"
}

echo "=== TYPE-005: zero-cost abstraction manifest ==="
if [ -f analysis/type-zero-cost-v1.md ]; then
  die "top-level DOC resurrected (live = archive/type/)"
fi
if [ -f compiler/src/codegen/codegen.c ]; then
  die "codegen.c resurrected (live = codegen.x)"
fi
for fossil in bench/loop_i32.x bench/mem_copy.x bench/struct_param.x bench/call_boundary.x; do
  if [ -f "$fossil" ]; then
    die "fossil bench resurrected: $fossil (live = r01_/m03_/r10_/a01_*)"
  fi
done

for f in "$DOC" "$MANIFEST" "$BENCH" \
  analysis/archive/type/type-linear-v1-rfc.md \
  analysis/archive/type/type-region-v1-rfc.md \
  analysis/archive/lang/lang-generic-v1.md \
  bench/r01_loop_i32.x bench/m03_mem_copy.x bench/r10_struct_param.x bench/a01_call_boundary.x \
  bench/generic_id_i32.x tests/typeck/linear/move_ok.x \
  compiler/src/codegen/codegen.x \
  tests/run-bcmp-gate.sh; do
  if [ ! -f "$f" ]; then
    die "missing $f"
  fi
done
if ! grep -qE '^## Gate' "$DOC"; then
  die "doc missing ## Gate section"
fi

for kw in zero cost abstraction copy runnable report; do
  if ! grep -qiF "$kw" "$DOC" 2>/dev/null; then
    die "doc missing keyword $kw"
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
while IFS=$'\t' read -r bench_id x_file _rest; do
  [ -z "${bench_id:-}" ] && continue
  case "$bench_id" in \#*|min_*) continue ;; esac
  BENCH_N=$((BENCH_N + 1))
  if ! grep -qF "$bench_id" "$DOC" 2>/dev/null; then
    echo "type-zero-cost FAIL: doc missing bench $bench_id" >&2
    MISS=$((MISS + 1))
  fi
  if ! type_zero_cost_bench_x "$x_file" >/dev/null 2>&1; then
    echo "type-zero-cost FAIL: missing bench x $x_file" >&2
    MISS=$((MISS + 1))
  fi
done < "$BENCH"

if [ "$LAYER_N" -lt "$MIN_LAYERS" ]; then
  die "layers=${LAYER_N} < min ${MIN_LAYERS}"
fi
if [ "$CASE_N" -lt "$MIN_CASES" ]; then
  die "cases=${CASE_N} < min ${MIN_CASES}"
fi
if [ "$BENCH_N" -lt "$MIN_BENCHES" ]; then
  die "benches=${BENCH_N} < min ${MIN_BENCHES}"
fi
if [ "$MISS" -gt 0 ]; then
  die "missing=${MISS}"
fi
echo "type-zero-cost manifest OK (layers=${LAYER_N} cases=${CASE_N} benches=${BENCH_N})"

chmod +x tests/run-type-zero-cost.sh
set +e
out=$(./tests/run-type-zero-cost.sh 2>&1)
ec=$?
set -e
printf '%s\n' "$out"
# Propagate runner counters from status line when present.
if printf '%s\n' "$out" | grep -qE 'status=ok.*run='; then
  RUN_OK=$(printf '%s\n' "$out" | sed -nE 's/.*run=([0-9]+).*/\1/p' | tail -1)
  OBS=$(printf '%s\n' "$out" | sed -nE 's/.*obs=([0-9]+).*/\1/p' | tail -1)
  SKIP=$(printf '%s\n' "$out" | sed -nE 's/.*skip=([0-9]+).*/\1/p' | tail -1)
  RUN_OK=${RUN_OK:-0}
  OBS=${OBS:-0}
  SKIP=${SKIP:-0}
fi
if [ "$ec" -ne 0 ]; then
  die "runnable residual (ec=$ec)"
fi

ok_report
echo "type-zero-cost gate OK"
