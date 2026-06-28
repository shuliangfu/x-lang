#!/usr/bin/env bash
# 自举前必须清单 — 按 §三→§九 逐节跑 gate（实时输出 + 默认 shux-c）
#
# 用法：./tests/run-checklist-sequence.sh
# 环境：
#   SHUX_CHECKLIST_FROM=3   起始节（默认 3）
#   SHUX_CHECKLIST_TO=9     结束节（默认 9）
#   SHUX_CHECKLIST_ALLOW_WARN=1  WARN/SKIP 不导致总 exit 1（默认 1）
#   SHUX=./compiler/shux-c  可覆盖编译器
if [ -z "${SHUX_STDBUF_WRAPPED:-}" ] && command -v stdbuf >/dev/null 2>&1; then
  export SHUX_STDBUF_WRAPPED=1
  exec stdbuf -oL -eL bash "$0" "$@"
fi

set -euo pipefail
cd "$(dirname "$0")/.."

FROM="${SHUX_CHECKLIST_FROM:-3}"
TO="${SHUX_CHECKLIST_TO:-9}"
ALLOW="${SHUX_CHECKLIST_ALLOW_WARN:-1}"

export SHUX_MINIMAL_CC_LINK="${SHUX_MINIMAL_CC_LINK:-1}"
export SHUX_P0_SKIP_STAGE1="${SHUX_P0_SKIP_STAGE1:-1}"
export SHUX_P0_GATE_O_HEARTBEAT="${SHUX_P0_GATE_O_HEARTBEAT:-15}"
export SHUX_P0_GATE_O_TIMEOUT="${SHUX_P0_GATE_O_TIMEOUT:-120}"

# shellcheck source=tests/lib/gate-progress.sh
source tests/lib/gate-progress.sh
# shellcheck source=tests/lib/p0-gate-shux.sh
source tests/lib/p0-gate-shux.sh

if [ -z "${SHUX:-}" ] && seed="$(p0_gate_default_seed 2>/dev/null || true)" && [ -n "$seed" ]; then
  export SHUX="$seed"
  gate_progress "默认 SHUX=$SHUX（seed 优先，避 stage1 OOM）"
fi

TOTAL_FAIL=0
for n in $(seq "$FROM" "$TO"); do
  echo ""
  echo "################################################################"
  gate_progress "顺序跑 §$n / $FROM..$TO"
  echo "################################################################"
  set +e
  SHUX_CHECKLIST_SECTION="$n" \
    SHUX_CHECKLIST_ALLOW_WARN="$ALLOW" \
    SHUX_CHECKLIST_STOP_ON_FAIL=0 \
    ./tests/run-bootstrap-checklist-gate.sh
  ec=$?
  set -e
  if [ "$ec" -ne 0 ]; then
    gate_progress "§$n 未全绿 (exit=$ec)"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
  else
    gate_progress "§$n 本节 OK"
  fi
done

echo ""
gate_progress "顺序跑完成: $((TO - FROM + 1)) 节, FAIL节=$TOTAL_FAIL"
if [ "$TOTAL_FAIL" -gt 0 ] && [ "$ALLOW" != "1" ]; then
  exit 1
fi
exit 0
