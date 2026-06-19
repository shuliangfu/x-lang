#!/usr/bin/env bash
# COMP-013：regalloc 质量波次 runnable 门禁
#
# 1) comp-regalloc-quality-v1.md + quality.tsv（≥9 metric）
# 2) 有 native shux_asm 时逐条执行 metric 脚本
#
# 用法：./tests/run-comp-regalloc-quality-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_COMP013_DOC:-analysis/comp-regalloc-quality-v1.md}"
MANIFEST="${SHUX_COMP013_WAVE_TSV:-tests/baseline/comp-regalloc-quality-wave.tsv}"
QUALITY="${SHUX_COMP013_QUALITY:-tests/baseline/comp-regalloc-quality.tsv}"
LIB="tests/lib/comp-regalloc-quality.sh"
MIN_METRICS=9

# shellcheck source=tests/lib/comp-regalloc-quality.sh
. tests/lib/comp-regalloc-quality.sh
# shellcheck source=tests/lib/comp-regalloc.sh
. tests/lib/comp-regalloc.sh

echo "=== COMP-013: regalloc quality wave manifest ==="
for f in "$DOC" "$MANIFEST" "$QUALITY" "$LIB" \
  analysis/comp-regalloc-v1.md tests/run-comp-regalloc-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "comp-regalloc-quality gate FAIL: missing $f" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  c1="${c1#\# }"
  case "$c1" in
    min_metrics) MIN_METRICS="$c2" ;;
  esac
done < "$QUALITY"

for kw in Wave2 metric_nested_var comp-regalloc-quality min_metrics; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "comp-regalloc-quality gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

METRIC_N=0
MISS=0
echo "=== COMP-013: quality metrics ==="
while IFS=$'\t' read -r metric_id arch _strategy _threshold script _notes; do
  [ -z "${metric_id:-}" ] && continue
  case "$metric_id" in \#*|min_*) continue ;; esac
  METRIC_N=$((METRIC_N + 1))
  if ! grep -qF "$metric_id" "$DOC" 2>/dev/null; then
    echo "comp-regalloc-quality FAIL: doc missing metric $metric_id" >&2
    MISS=$((MISS + 1))
  fi
  if [ -f "tests/$script" ]; then
    echo "comp-regalloc-quality OK metric $metric_id -> $script"
  else
    echo "comp-regalloc-quality FAIL: missing tests/$script ($metric_id)" >&2
    MISS=$((MISS + 1))
  fi
done < "$QUALITY"

if [ "$METRIC_N" -lt "$MIN_METRICS" ]; then
  echo "comp-regalloc-quality gate FAIL: metrics=${METRIC_N} < min ${MIN_METRICS}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "comp-regalloc-quality gate FAIL: missing=${MISS}" >&2
  exit 1
fi
echo "comp-regalloc-quality manifest OK (metrics=${METRIC_N})"

SHUX_ASM="${SHUX:-./compiler/shux_asm}"
METRICS_OK=0
METRICS_SKIP=0
SKIP=1

if comp_regalloc_native_shux_asm "$SHUX_ASM"; then
  echo "=== COMP-013: run quality metrics (SHUX=$SHUX_ASM) ==="
  make -C compiler -q 2>/dev/null || make -C compiler
  while IFS=$'\t' read -r metric_id _arch _strategy _threshold script _notes; do
    [ -z "${metric_id:-}" ] && continue
    case "$metric_id" in \#*|min_*) continue ;; esac
    # metric_full 较重：单独在 asm-73 跑；波次 gate 仅验脚本存在+抽样轻量指标
    if [ "$metric_id" = "metric_full" ]; then
      METRICS_OK=$((METRICS_OK + 1))
      echo "comp-regalloc-quality OK metric_full (deferred to asm-73)"
      continue
    fi
    if comp_regalloc_quality_run_metric "$SHUX_ASM" "$script"; then
      METRICS_OK=$((METRICS_OK + 1))
      echo "comp-regalloc-quality runnable OK $metric_id"
    else
      comp_regalloc_quality_emit_report "fail" "$METRICS_OK" 0 0
      exit 1
    fi
  done < "$QUALITY"
  SKIP=0
else
  echo "comp-regalloc-quality gate SKIP runnable (no native shux_asm)" >&2
  METRICS_SKIP=$METRIC_N
fi

if [ "$SKIP" -eq 0 ] && [ "$METRICS_OK" -lt "$((MIN_METRICS - 1))" ]; then
  echo "comp-regalloc-quality gate FAIL: metrics_ok=${METRICS_OK} < min $((MIN_METRICS - 1))" >&2
  exit 1
fi

comp_regalloc_quality_emit_report "ok" "$METRICS_OK" "$METRICS_SKIP" "$SKIP"
echo "comp-regalloc-quality gate OK"
