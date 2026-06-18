#!/usr/bin/env bash
# COMP-009：前端/后端接口契约边界烟测
#
# 用法：./tests/run-comp-feb-contract.sh
set -e
cd "$(dirname "$0")/.."

# shellcheck source=tests/lib/comp-feb-contract.sh
. tests/lib/comp-feb-contract.sh

BOUNDARY="${SHU_FEB_CONTRACT_BOUNDARY:-tests/baseline/comp-feb-contract-boundary.tsv}"

echo "=== COMP-009: FEB contract boundary smoke ==="
FAILS=0
while IFS=$'\t' read -r bid layer upstream downstream sym payload src; do
  [ -z "${bid:-}" ] && continue
  case "$bid" in \#*|min_*) continue ;; esac
  path="$(comp_feb_contract_src_path "$src" 2>/dev/null || true)"
  if [ -z "$path" ]; then
    echo "comp-feb-contract FAIL: missing src $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  if ! comp_feb_contract_symbol_present "$path" "$sym"; then
    echo "comp-feb-contract FAIL: $sym not in $src" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  # payload 中首个类型名须在源码或 RFC 相邻模块出现（粗校验 data contract）。
  first_type="${payload%%,*}"
  first_type="${first_type// /}"
  if [ -n "$first_type" ] && ! grep -qF "$first_type" "$path" 2>/dev/null; then
  if ! grep -qF "$first_type" "analysis/comp-feb-contract-v1.md" 2>/dev/null; then
    echo "comp-feb-contract FAIL: payload type $first_type missing for $bid" >&2
    FAILS=$((FAILS + 1))
    continue
  fi
  fi
  echo "comp-feb-contract OK $bid ($sym)"
done < "$BOUNDARY"

if [ "$FAILS" -gt 0 ]; then
  echo "comp-feb-contract FAIL: ${FAILS} boundary(ies)" >&2
  exit 1
fi
echo "comp-feb-contract OK"
