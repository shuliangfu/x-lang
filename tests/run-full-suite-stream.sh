#!/usr/bin/env bash
# run-full-suite-stream.sh — Linux x86_64 全量回归流式入口（阶段 G phase0-stream）
#
# 各 Tier 经 progress-run.sh 实时 tee，避免长命令看似卡住。
# 用法（仓库根）：
#   ./tests/run-full-suite-stream.sh
#   SHUX_FULL_SUITE_SKIP_CI=1 ./tests/run-full-suite-stream.sh   # 跳过 Tier 5（数小时）
#
# 环境：
#   SHUX_FULL_SUITE_SKIP_CI=1 — 不跑 run-ci-full-suite.sh
#   SHUX_FULL_SUITE_SKIP_BSTRICT_CI=1 — 不跑 run-bootstrap-bstrict-ci.sh（Tier 4）
#   SHUX_PROGRESS_TIMEOUT_SEC — 传给 progress-run（单 Tier 超时）
#   SHUX_BUILD_ASM_TIMEOUT — build_shux_asm 外层超时（默认 3600）

set -euo pipefail
cd "$(dirname "$0")/.."

PROGRESS="./tests/lib/progress-run.sh"
LOG_DIR="${SHUX_FULL_SUITE_LOG_DIR:-/tmp/shux-full-suite-$$}"
mkdir -p "$LOG_DIR"

# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

progress_suite() {
  echo "[$(date +%H:%M:%S)] full-suite $*"
}

die() {
  echo "run-full-suite-stream FAIL: $*" >&2
  exit 1
}

require_linux_x86() {
  if [ "$(ci_host_os)" != "Linux" ] || ! ci_is_x86_64_host; then
    die "primary platform is Linux x86_64 (host=$(ci_host_summary)); use run-ci-full-suite.sh for other hosts"
  fi
}

run_tier() {
  local label="$1"
  local log="$2"
  shift 2
  chmod +x "$PROGRESS"
  progress_suite "── Tier: $label ──"
  "$PROGRESS" "$label" "$log" -- "$@"
}

require_linux_x86

if [ ! -x compiler/shux ] && [ ! -f compiler/shux ]; then
  progress_suite "seed shux missing; building make -C compiler OPT=1 all ..."
  make -C compiler OPT=1 all
fi

ulimit -s 65532 2>/dev/null || ulimit -s 16384 2>/dev/null || ulimit -s hard 2>/dev/null || true

export SHUX_BUILD_ASM_TIMEOUT="${SHUX_BUILD_ASM_TIMEOUT:-3600}"

progress_suite "START log_dir=$LOG_DIR host=$(ci_host_summary)"

# Tier 1：B-strict 日常发布链
run_tier "T1 bootstrap-driver-bstrict" "$LOG_DIR/t1-bstrict.log" \
  make -C compiler bootstrap-driver-bstrict

# Tier 2：Stage2 SHA256 金标准（须 Tier 1 产物）
run_tier "T2 d03 stage2 hash" "$LOG_DIR/t2-d03.log" \
  env SHUX_D03_FAIL=1 ./tests/run-d03-stage2-hash-gate.sh

# Tier 3：E-soft 编译器 C 软退役审计
run_tier "T3 e-soft retire" "$LOG_DIR/t3-e-soft.log" \
  env SHUX_E_SOFT_FAIL=1 ./tests/run-e-soft-retire-gate.sh

# Tier 4：B-strict CI 聚合（含 run-all-bstrict 等）
if [ -z "${SHUX_FULL_SUITE_SKIP_BSTRICT_CI:-}" ]; then
  run_tier "T4 bootstrap-bstrict-ci" "$LOG_DIR/t4-bstrict-ci.log" \
    ./tests/run-bootstrap-bstrict-ci.sh
else
  progress_suite "SKIP Tier 4 (SHUX_FULL_SUITE_SKIP_BSTRICT_CI=1)"
fi

# Tier 5：CI 全量（Linux x86_64 Tier A）
if [ -z "${SHUX_FULL_SUITE_SKIP_CI:-}" ]; then
  run_tier "T5 ci-full-suite" "$LOG_DIR/t5-ci-full.log" \
    env CI=1 SHUX_CI_NO_SKIP=1 ./tests/run-ci-full-suite.sh
else
  progress_suite "SKIP Tier 5 (SHUX_FULL_SUITE_SKIP_CI=1)"
fi

progress_suite "OK — all tiers passed; logs in $LOG_DIR"
