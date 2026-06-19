#!/usr/bin/env bash
# ENG-003：跨平台 CI 矩阵 manifest 门禁
#
# 验证 ci-platform-matrix.tsv 与 workflow 文件一致；不启动 GHA。
# 用法：./tests/run-eng-crossplatform-ci-gate.sh
set -e
cd "$(dirname "$0")/.."

MATRIX="${SHUX_CI_PLATFORM_MATRIX:-tests/baseline/ci-platform-matrix.tsv}"

echo "=== ENG-003: cross-platform CI manifest ==="
for f in \
  analysis/eng-crossplatform-ci-v1.md \
  "$MATRIX" \
  .github/workflows/ci.yml \
  .github/workflows/ci-nightly.yml \
  tests/run-ci-full-suite.sh \
  tests/run-portable-suite.sh \
  tests/lib/ci-host.sh; do
  if [ ! -f "$f" ]; then
    echo "eng-crossplatform-ci gate FAIL: missing $f" >&2
    exit 1
  fi
done
echo "eng-crossplatform-ci manifest OK"

# nightly 须含 schedule
if ! grep -qE 'schedule:|cron:' .github/workflows/ci-nightly.yml; then
  echo "eng-crossplatform-ci gate FAIL: ci-nightly.yml missing schedule" >&2
  exit 1
fi
if ! grep -q 'run-ci-full-suite.sh' .github/workflows/ci-nightly.yml; then
  echo "eng-crossplatform-ci gate FAIL: ci-nightly.yml must call run-ci-full-suite.sh" >&2
  exit 1
fi
echo "eng-crossplatform-ci nightly workflow OK"

FAILS=0
N=0
echo "=== ENG-003: platform matrix vs workflows ==="
while IFS=$'\t' read -r pid wf job runner entry tier notes; do
  [ -z "${pid:-}" ] && continue
  case "$pid" in \#*) continue ;; esac
  N=$((N + 1))
  wf_path=".github/workflows/${wf}"
  if [ ! -f "$wf_path" ]; then
    echo "eng-crossplatform-ci FAIL: missing workflow $wf_path ($pid)" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  # GHA job id（ci.yml 顶层 job 为两空格缩进）
  if ! grep -qF "  ${job}:" "$wf_path"; then
    echo "eng-crossplatform-ci FAIL: job '${job}' not in $wf_path ($pid)" >&2
    FAILS=$((FAILS + 1))
  fi
  if [ ! -f "tests/${entry}" ] && [ ! -f "$entry" ]; then
    echo "eng-crossplatform-ci FAIL: missing entry tests/${entry} ($pid)" >&2
    FAILS=$((FAILS + 1))
  fi
done < "$MATRIX"

# PR ci.yml 三平台核心 job 硬要求
for req in linux mac windows; do
  if ! grep -qF "  ${req}:" .github/workflows/ci.yml; then
    echo "eng-crossplatform-ci FAIL: ci.yml missing required job $req" >&2
    FAILS=$((FAILS + 1))
  fi
done

if [ "$FAILS" -gt 0 ]; then
  echo "eng-crossplatform-ci gate FAIL: ${FAILS} issue(s) (${N} matrix rows)" >&2
  exit 1
fi
echo "eng-crossplatform-ci matrix OK (${N} rows)"

echo "eng-crossplatform-ci gate OK"
