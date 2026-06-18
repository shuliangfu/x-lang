#!/usr/bin/env bash
# CORE-014：core 全模块 manifest 门禁
#
# 验收：11 个 core 模块在注册表中有 manifest，符号锚点存在，专项 gate 脚本存在。
#
# 用法：./tests/run-core-api-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHU_CORE_API_DOC:-analysis/core-api-gate-v1.md}"
REGISTRY="${SHU_CORE_API_TSV:-tests/baseline/core-api.tsv}"
MATRIX="${SHU_CORE_API_MATRIX:-tests/baseline/stdlib-check-matrix.tsv}"
LIB="tests/lib/core-api.sh"
MIN_MOD=11

# shellcheck source=tests/lib/core-api.sh
. "$LIB"

echo "=== CORE-014: core manifest registry ==="
for f in "$DOC" "$REGISTRY" "$LIB" "$MATRIX"; do
  if [ ! -f "$f" ]; then
    echo "core-api gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in min_modules core.types core.debug stdlib-check-matrix; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "core-api gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in
    min_modules) MIN_MOD="$c2" ;;
  esac
done < "$REGISTRY"

matrix_miss="$(core_api_matrix_ok "$MATRIX" || true)"
if [ "${matrix_miss:-0}" -gt 0 ]; then
  core_api_emit_report "fail" 0 "$matrix_miss" 0
  echo "core-api gate FAIL: matrix_miss=${matrix_miss}" >&2
  exit 1
fi
echo "core-api matrix cross-check OK"

COVERED=0
SYM_MISS=0
GATE_MISS=0
echo "=== CORE-014: module manifest sweep (min=${MIN_MOD}) ==="
while IFS=$'\t' read -r module_id manifest mod_path kind sub_gate _notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in
    \#*|min_*|matrix_*|doc|gate) continue ;;
  esac
  if [ ! -f "$manifest" ]; then
    echo "core-api gate FAIL: missing manifest $manifest ($module_id)" >&2
    core_api_emit_report "fail" "$COVERED" 1 0
    exit 1
  fi
  if [ ! -f "$mod_path" ]; then
    echo "core-api gate FAIL: missing mod $mod_path ($module_id)" >&2
    core_api_emit_report "fail" "$COVERED" 1 0
    exit 1
  fi
  miss="$(core_api_validate_module "$mod_path" "$manifest" "$kind" || true)"
  if [ "${miss:-0}" -gt 0 ]; then
    SYM_MISS=$((SYM_MISS + miss))
    echo "core-api gate FAIL: ${module_id} sym_miss=${miss}" >&2
    core_api_emit_report "fail" "$COVERED" "$SYM_MISS" 0
    exit 1
  fi
  if [ -n "${sub_gate:-}" ] && [ "$sub_gate" != "-" ]; then
    gate_path="tests/${sub_gate}"
    if [ ! -f "$gate_path" ]; then
      GATE_MISS=$((GATE_MISS + 1))
      echo "core-api gate FAIL: missing sub_gate $gate_path ($module_id)" >&2
      core_api_emit_report "fail" "$COVERED" 0 "$GATE_MISS"
      exit 1
    fi
  fi
  COVERED=$((COVERED + 1))
  echo "  OK ${module_id} (${kind})"
done < "$REGISTRY"

if [ "$COVERED" -lt "$MIN_MOD" ]; then
  echo "core-api gate FAIL: covered=${COVERED} < min=${MIN_MOD}" >&2
  core_api_emit_report "fail" "$COVERED" 0 0
  exit 1
fi

core_api_emit_report "ok" "$COVERED" 0 0
echo "core-api gate OK (${COVERED} modules)"
