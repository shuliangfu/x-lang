#!/usr/bin/env bash
# BOOT-005：自举失败分类清单 manifest 门禁
#
# 1) boot-failure-taxonomy-v1.md + taxonomy + patterns + repro + fixtures
# 2) 每 failure_type 的 pattern_ids 存在于 stage-patterns
# 3) repro_case 存在于 bootstrap-repro.tsv
# 4) 覆盖率 ≥ min_coverage_pct
# 5) hook：run-bootstrap-stage-diag-gate.sh
#
# 用法：./tests/run-bootstrap-failure-taxonomy-gate.sh
set -e
cd "$(dirname "$0")/.."

TAX="${SHU_BOOT_FAILURE_TAXONOMY:-tests/baseline/bootstrap-failure-taxonomy.tsv}"
PATTERNS="${SHU_BOOT_STAGE_PATTERNS:-tests/baseline/bootstrap-stage-patterns.tsv}"
REPRO="${SHU_BOOT_REPRO_MATRIX:-tests/baseline/bootstrap-repro.tsv}"
FIXTURES="${SHU_BOOT_STAGE_FIXTURES:-tests/baseline/bootstrap-stage-diag-fixtures.tsv}"
MIN_PCT=95
MIN_TYPES=20

echo "=== BOOT-005: failure taxonomy manifest ==="
for f in \
  analysis/boot-failure-taxonomy-v1.md \
  analysis/boot-stage-diag-v1.md \
  "$TAX" \
  "$PATTERNS" \
  "$REPRO" \
  "$FIXTURES" \
  tests/run-bootstrap-stage-diag-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "bootstrap-failure-taxonomy gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "bootstrap-failure-taxonomy manifest OK"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_coverage_pct) MIN_PCT="$c2" ;;
    min_historical_types) MIN_TYPES="$c2" ;;
  esac
done < "$TAX"

# pattern_id 是否在 patterns 表
pattern_exists() {
  local pid="$1"
  awk -F'\t' -v p="$pid" '$1==p && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$PATTERNS"
}

# repro_case 是否在 repro 矩阵
repro_exists() {
  local rid="$1"
  awk -F'\t' -v r="$rid" '$1==r && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$REPRO"
}

# fixture_id 是否在 fixtures 表（非空时）
fixture_exists() {
  local fid="$1"
  [ -z "$fid" ] && return 0
  awk -F'\t' -v f="$fid" '$1==f && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$FIXTURES"
}

TOTAL=0
COVERED=0
MISS=0
echo "=== BOOT-005: taxonomy coverage ==="
while IFS=$'\t' read -r ft_id category stage patterns repro fixture notes; do
  [ -z "${ft_id:-}" ] && continue
  case "$ft_id" in \#*|min_*) continue ;; esac
  TOTAL=$((TOTAL + 1))
  type_ok=1

  if ! repro_exists "$repro"; then
    echo "bootstrap-failure-taxonomy FAIL: unknown repro $repro ($ft_id)" >&2
    MISS=$((MISS + 1))
    type_ok=0
  fi
  if [ -n "${fixture:-}" ] && [ "$fixture" != "-" ] && ! fixture_exists "$fixture"; then
    echo "bootstrap-failure-taxonomy FAIL: unknown fixture $fixture ($ft_id)" >&2
    MISS=$((MISS + 1))
    type_ok=0
  fi

  IFS=',' read -r -a pids <<< "${patterns:-}"
  for pid in "${pids[@]}"; do
    pid="${pid#"${pid%%[![:space:]]*}"}"
    pid="${pid%"${pid##*[![:space:]]}"}"
    [ -z "$pid" ] && continue
    if ! pattern_exists "$pid"; then
      echo "bootstrap-failure-taxonomy FAIL: unknown pattern $pid ($ft_id)" >&2
      MISS=$((MISS + 1))
      type_ok=0
    fi
  done

  if [ "$type_ok" -eq 1 ]; then
    COVERED=$((COVERED + 1))
    echo "bootstrap-failure-taxonomy OK $ft_id ($stage/$repro)"
  fi
done < "$TAX"

if [ "$TOTAL" -lt "$MIN_TYPES" ]; then
  echo "bootstrap-failure-taxonomy gate FAIL: types=${TOTAL} < min ${MIN_TYPES}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "bootstrap-failure-taxonomy gate FAIL: errors=${MISS}" >&2
  exit 1
fi

PCT=$((COVERED * 100 / TOTAL))
if [ "$PCT" -lt "$MIN_PCT" ]; then
  echo "bootstrap-failure-taxonomy gate FAIL: coverage=${PCT}% < min ${MIN_PCT}% (${COVERED}/${TOTAL})" >&2
  exit 1
fi
echo "bootstrap-failure-taxonomy coverage OK (${COVERED}/${TOTAL} = ${PCT}%)"

echo "=== BOOT-005: stage-diag hook ==="
chmod +x tests/run-bootstrap-stage-diag-gate.sh
./tests/run-bootstrap-stage-diag-gate.sh

echo "bootstrap-failure-taxonomy gate OK"
