#!/usr/bin/env bash
# 高效版：自举前必须清单 §三→§九（shux-c + stage1 S7 + FAST 跳过 §六）
#
# 用法：./tests/run-checklist-fast.sh
# Docker（建议 6g 内存）：docker run -t --rm --platform linux/amd64 -m 6g ...
if [ -z "${SHUX_STDBUF_WRAPPED:-}" ] && command -v stdbuf >/dev/null 2>&1; then
  export SHUX_STDBUF_WRAPPED=1
  exec stdbuf -oL -eL bash "$0" "$@"
fi

set -euo pipefail
cd "$(dirname "$0")/.."

chmod +x ./compiler/shux-c ./compiler/shux_asm_stage1 2>/dev/null || true
chmod +x ./tests/*.sh ./tests/lib/*.sh 2>/dev/null || true

export SHUX="${SHUX:-./compiler/shux-c}"
export SHUX_MINIMAL_CC_LINK=1
export SHUX_P0_SKIP_STAGE1="${SHUX_P0_SKIP_STAGE1:-0}"
export SHUX_P0_GATE_O_TIMEOUT="${SHUX_P0_GATE_O_TIMEOUT:-60}"
export SHUX_L9_SKIP_O="${SHUX_L9_SKIP_O:-0}"
export SHUX_S7_TYPECK_TIMEOUT="${SHUX_S7_TYPECK_TIMEOUT:-90}"
export SHUX_P0_GATE_O_HEARTBEAT=10
export SHUX_CHECKLIST_ALLOW_WARN=1
export SHUX_CHECKLIST_STOP_ON_FAIL=0
export SHUX_CHECKLIST_FAST=1
export SHUX_S7_OPTIONAL_SKIP=0
export SHUX_BOOTSTRAP_FRESH_SEED_SKIP=0

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

gate_progress "checklist FAST 开始 (SHUX=$SHUX)"
gate_progress "预计 ~1 分钟（FAST skip §六/§9.1；S7 含 fs/heap stage1；L9/C5 -o 各 ≤60s）"
exec ./tests/run-checklist-sequence.sh
