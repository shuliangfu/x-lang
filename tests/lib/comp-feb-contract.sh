#!/usr/bin/env bash
# comp-feb-contract.sh — COMP-009 前端/后端接口契约共享辅助
#
# 校验边界符号在源码中存在，并可选检查 payload 类型名。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)"
BOUNDARY="${SHUX_FEB_CONTRACT_BOUNDARY:-$ROOT/tests/baseline/comp-feb-contract-boundary.tsv}"

# 在源码文件中查找符号定义或声明（function / extern function）。
comp_feb_contract_symbol_present() {
  local src="$1"
  local sym="$2"
  [ -f "$src" ] || return 1
  grep -qE "(function|extern function)[[:space:]]+${sym}[^A-Za-z0-9_]" "$src" 2>/dev/null \
    || grep -qE "^[a-zA-Z_].*\\b${sym}\\s*\\(" "$src" 2>/dev/null
}

# 解析 boundary TSV 中的 .sx/.c 路径（相对仓库根）。
comp_feb_contract_src_path() {
  local rel="$1"
  if [ -f "$ROOT/$rel" ]; then
    echo "$ROOT/$rel"
  else
    return 1
  fi
}

# 统计 boundary 表有效行数（不含注释与 min_*）。
comp_feb_contract_boundary_count() {
  local n=0
  while IFS=$'\t' read -r bid _rest; do
    [ -z "${bid:-}" ] && continue
    case "$bid" in \#*|min_*) continue ;; esac
    n=$((n + 1))
  done < "$BOUNDARY"
  echo "$n"
}
