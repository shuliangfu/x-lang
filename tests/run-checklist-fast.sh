#!/usr/bin/env bash
# 高效版：自举前必须清单 §三→§九（xlang-c + stage1 S7 + FAST 跳过 §六）
#
# 用法：./tests/run-checklist-fast.sh
# Docker（建议 6g 内存）：docker run -t --rm --platform linux/amd64 -m 6g ...
if [ -z "${XLANG_STDBUF_WRAPPED:-}" ] && command -v stdbuf >/dev/null 2>&1; then
  export XLANG_STDBUF_WRAPPED=1
  exec stdbuf -oL -eL bash "$0" "$@"
fi

set -euo pipefail
cd "$(dirname "$0")/.."

chmod +x ./compiler/xlang-c ./compiler/xlang_asm_stage1 2>/dev/null || true
chmod +x ./tests/*.sh ./tests/lib/*.sh 2>/dev/null || true

export XLANG="${XLANG:-./compiler/xlang-c}"
export XLANG_MINIMAL_CC_LINK=1
export XLANG_P0_SKIP_STAGE1="${XLANG_P0_SKIP_STAGE1:-1}"
export XLANG_P0_GATE_O_TIMEOUT="${XLANG_P0_GATE_O_TIMEOUT:-60}"
export XLANG_L9_SKIP_O="${XLANG_L9_SKIP_O:-0}"
export XLANG_S7_TYPECK_TIMEOUT="${XLANG_S7_TYPECK_TIMEOUT:-90}"
export XLANG_P0_GATE_O_HEARTBEAT=10
export XLANG_CHECKLIST_ALLOW_WARN=1
export XLANG_CHECKLIST_STOP_ON_FAIL=0
export XLANG_CHECKLIST_FAST=1
export XLANG_S7_OPTIONAL_SKIP=0
export XLANG_BOOTSTRAP_FRESH_SEED_SKIP=0

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh

gate_progress "checklist FAST 开始 (XLANG=$XLANG)"
gate_progress "预计 ~1 分钟（FAST skip §六/§9.1；S7 含 fs/heap stage1；L9/C5 -o 各 ≤60s）"
exec ./tests/run-checklist-sequence.sh
