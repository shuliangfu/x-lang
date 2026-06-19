#!/usr/bin/env bash
# ENG-002：质量门禁 manifest 与体积→质量迁移验收
#
# 1) eng-quality-gate-v1.md + matrix manifest
# 2) gate_script 存在；tier=Q ci_hard=yes 计数 ≥ min_quality_ci
# 3) ci-full-suite 不含 SHUX_SIZE_FAIL=1（体积 advisory）
# 4) bootstrap-bstrict-ci 含 symbol-integrity
# 5) run-size-shux-asm-gate.sh 默认 advisory
#
# 用法：./tests/run-eng-quality-gate-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_ENG_QUALITY_GATE_TSV:-tests/baseline/eng-quality-gate-matrix.tsv}"
MIN_QCI=8

echo "=== ENG-002: quality gate manifest ==="
for f in \
  analysis/eng-quality-gate-v1.md \
  "$MATRIX" \
  tests/run-ci-full-suite.sh \
  tests/run-bootstrap-bstrict-ci.sh \
  tests/run-size-shux-asm-gate.sh; do
  if [ ! -f "$f" ]; then
    echo "eng-quality-gate gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "eng-quality-gate manifest OK"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_quality_ci) MIN_QCI="$c2" ;;
  esac
done < "$MATRIX"

# ── matrix 行：脚本存在 + Q/ci 计数 ──
MISS=0
QCI=0
N=0
echo "=== ENG-002: gate matrix check ==="
while IFS=$'\t' read -r gate_id tier ci_hard script replaces notes; do
  [ -z "${gate_id:-}" ] && continue
  case "$gate_id" in \#*|min_quality_ci) continue ;; esac
  N=$((N + 1))
  if [ "$tier" = "T" ]; then
    continue
  fi
  path="$script"
  case "$path" in
    tests/*|compiler/*) ;;
    *) path="tests/$path" ;;
  esac
  if [ ! -f "$path" ]; then
    echo "eng-quality-gate FAIL: missing gate script $path ($gate_id)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  if [ "$tier" = "Q" ] && [ "$ci_hard" = "yes" ]; then
    QCI=$((QCI + 1))
  fi
done < "$MATRIX"

if [ "$MISS" -gt 0 ]; then
  echo "eng-quality-gate gate FAIL: missing=${MISS} scripts" >&2
  exit 1
fi
if [ "$QCI" -lt "$MIN_QCI" ]; then
  echo "eng-quality-gate gate FAIL: quality_ci=${QCI} < min_quality_ci=${MIN_QCI}" >&2
  exit 1
fi
echo "eng-quality-gate matrix OK (${N} rows, quality_ci=${QCI})"

# ── CI 不得 hard-fail 体积 ──
echo "=== ENG-002: size gate advisory policy ==="
if grep -q 'SHUX_SIZE_FAIL=1' tests/run-ci-full-suite.sh; then
  echo "eng-quality-gate gate FAIL: run-ci-full-suite.sh still uses SHUX_SIZE_FAIL=1" >&2
  exit 1
fi
if ! grep -q 'run-parser-thin-glue-symbol-integrity-gate.sh' tests/run-bootstrap-bstrict-ci.sh; then
  echo "eng-quality-gate gate FAIL: bootstrap-bstrict-ci missing symbol-integrity gate" >&2
  exit 1
fi
# size gate 默认 advisory：不得 CI+Linux 自动 SHUX_SIZE_FAIL
if grep -q '\[ -n "\${CI:-}" \]' tests/run-size-shux-asm-gate.sh 2>/dev/null; then
  echo "eng-quality-gate gate FAIL: run-size-shux-asm-gate.sh still auto-fails on CI" >&2
  exit 1
fi
echo "eng-quality-gate policy OK (size advisory, symbol-integrity in bstrict)"

echo "eng-quality-gate gate OK"
