#!/usr/bin/env bash
# BOOT-012：自举性能回归 manifest 门禁
#
# 1) boot-perf-regression-v1.md + bootstrap-perf-matrix + compile-dogfood + registry
# 2) bootstrap_compiler 三 case 须在 dogfood TSV
# 3) CI / pre-push 接线审计
# 4) hook：run-perf-compile-dogfood-gate.sh
#
# 用法：./tests/run-bootstrap-perf-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHU_BOOT_PERF_MATRIX:-tests/baseline/bootstrap-perf-matrix.tsv}"
DOGFOOD="${SHU_PERF_COMPILE_BASELINE:-tests/baseline/compile-dogfood.tsv}"
REG="${SHU_PERF_BASELINE_REGISTRY:-tests/baseline/perf-baseline-registry.tsv}"
MIN_BOOT=3

echo "=== BOOT-012: bootstrap perf manifest ==="
for f in \
  analysis/boot-perf-regression-v1.md \
  analysis/perf-compile-dogfood-v1.md \
  "$MATRIX" \
  "$DOGFOOD" \
  "$REG" \
  tests/run-perf-compile-dogfood-gate.sh \
  tests/run-ci-full-suite.sh \
  .github/workflows/ci.yml; do
  if [ ! -f "$f" ]; then
    echo "bootstrap-perf gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "bootstrap-perf manifest OK"

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_bootstrap_compiler_cases) MIN_BOOT="$c2" ;; esac
done < "$MATRIX"

# ── bootstrap_compiler case ∈ dogfood ──
BOOT_N=0
MISS=0
echo "=== BOOT-012: bootstrap_compiler vs compile-dogfood ==="
while IFS=$'\t' read -r case_id tier ci_hard hook notes; do
  [ -z "${case_id:-}" ] && continue
  case "$case_id" in \#*|min_*) continue ;; esac
  [ "$tier" = "bootstrap_compiler" ] || continue
  BOOT_N=$((BOOT_N + 1))
  if ! awk -F'\t' -v c="$case_id" '$1==c && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$DOGFOOD"; then
    echo "bootstrap-perf FAIL: compile-dogfood missing case $case_id" >&2
    MISS=$((MISS + 1))
  fi
done < "$MATRIX"

if [ "$BOOT_N" -lt "$MIN_BOOT" ]; then
  echo "bootstrap-perf gate FAIL: bootstrap_compiler=${BOOT_N} < min ${MIN_BOOT}" >&2
  exit 1
fi
if [ "$MISS" -gt 0 ]; then
  echo "bootstrap-perf gate FAIL: dogfood missing=${MISS}" >&2
  exit 1
fi
echo "bootstrap-perf dogfood OK (${BOOT_N} bootstrap_compiler cases)"

# ── registry 须含 compile-dogfood ──
if ! awk -F'\t' '$1=="compile-dogfood" && $1 !~ /^#/ { found=1; exit } END { exit !found }' "$REG"; then
  echo "bootstrap-perf gate FAIL: perf-baseline-registry missing compile-dogfood" >&2
  exit 1
fi
echo "bootstrap-perf registry OK"

# ── CI 接线 ──
echo "=== BOOT-012: CI wiring audit ==="
if ! grep -q 'run-perf-compile-dogfood-gate.sh' tests/run-ci-full-suite.sh; then
  echo "bootstrap-perf gate FAIL: ci-full-suite missing compile dogfood gate" >&2
  exit 1
fi
if ! grep -q 'run-ci-full-suite.sh' .github/workflows/ci.yml; then
  echo "bootstrap-perf gate FAIL: ci.yml missing run-ci-full-suite.sh" >&2
  exit 1
fi
if ! grep -q 'run-ci-full-suite.sh' .github/workflows/ci-nightly.yml 2>/dev/null; then
  echo "bootstrap-perf gate FAIL: ci-nightly.yml missing run-ci-full-suite.sh" >&2
  exit 1
fi
if ! grep -q 'run-perf-p1-gate.sh' tests/run-pre-push-p0.sh; then
  echo "bootstrap-perf gate FAIL: pre-push-p0 missing perf P1 gate" >&2
  exit 1
fi
echo "bootstrap-perf CI wiring OK"

# ── hook：PERF-004 dogfood gate ──
echo "=== BOOT-012: compile dogfood hook (PERF-004) ==="
chmod +x tests/run-perf-compile-dogfood-gate.sh
./tests/run-perf-compile-dogfood-gate.sh

echo "bootstrap-perf gate OK"
