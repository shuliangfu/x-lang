#!/usr/bin/env bash
# ENG-001：性能 baseline 版本化治理门禁
#
# 1) perf-baseline-registry.tsv manifest（path / gate / version 格式）
# 2) 可选 SHU_ENG_BASELINE_DIFF_CHECK=1：baseline 变更须 bump registry version
#
# 用法：./tests/run-eng-baseline-governance-gate.sh
set -e
cd "$(dirname "$0")/.."

REG="${SHU_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"

# shellcheck source=tests/lib/perf-baseline-governance.sh
. tests/lib/perf-baseline-governance.sh

echo "=== ENG-001: perf baseline governance manifest ==="
for f in \
  analysis/eng-baseline-governance-v1.md \
  "$REG" \
  tests/templates/eng-baseline-change-checklist.txt \
  tests/lib/perf-baseline-governance.sh; do
  if [ ! -f "$f" ]; then
    echo "eng-baseline-governance gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "eng-baseline-governance manifest OK"

perf_baseline_registry_validate "$REG"

if [ "${SHU_ENG_BASELINE_DIFF_CHECK:-0}" = "1" ]; then
  echo "=== ENG-001: baseline diff vs version bump ==="
  perf_baseline_diff_requires_version_bump
fi

echo "eng-baseline-governance gate OK"
