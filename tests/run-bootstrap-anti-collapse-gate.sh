#!/usr/bin/env bash
# run-bootstrap-anti-collapse-gate.sh — 自举塌陷门禁（W3 gold 子段）
#
# 在 gen1/gen2 与 A-09 之后运行，确保未静默复制 pinned seed / 旧 shux 冒充 strict 产物。
#
# 用法（仓库根）：
#   ./tests/run-bootstrap-anti-collapse-gate.sh
#   SHUX_BOOTSTRAP_ANTI_COLLAPSE_FAIL=1 ./tests/run-bootstrap-anti-collapse-gate.sh
#
# 环境：
#   SHUX_BOOTSTRAP_ANTI_COLLAPSE_SKIP=1 — 完全跳过

set -euo pipefail
cd "$(dirname "$0")/.."

if [ "${SHUX_BOOTSTRAP_ANTI_COLLAPSE_SKIP:-0}" = "1" ]; then
  echo "bootstrap-anti-collapse-gate: SKIP"
  exit 0
fi

# shellcheck source=tests/lib/bootstrap-anti-collapse.sh
source tests/lib/bootstrap-anti-collapse.sh

STAGE1="${1:-compiler/shux_asm_stage1}"
STAGE2="${2:-compiler/shux_asm2}"
SEED="${3:-compiler/shux}"

echo "bootstrap-anti-collapse-gate: checking collapse ..."
bootstrap_anti_collapse_check "$STAGE1" "$STAGE2" "$SEED"
echo "bootstrap-anti-collapse-gate OK"
