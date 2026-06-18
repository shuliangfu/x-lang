#!/usr/bin/env bash
# STD-136：std 全模块 manifest/gate 全覆盖门禁
set -e
cd "$(dirname "$0")/.."
DOC="analysis/std-api-gate-v1.md"
REGISTRY="tests/baseline/std-api.tsv"
MATRIX="tests/baseline/stdlib-check-matrix.tsv"
LIB="tests/lib/std-api.sh"
MIN_MOD=60
. "$LIB"
for f in "$DOC" "$REGISTRY" "$LIB" "$MATRIX"; do
  [ -f "$f" ] || { echo "std-api gate FAIL: missing $f" >&2; exit 1; }
done
grep -qF STD-136 "$DOC" || { echo "std-api gate FAIL: doc" >&2; exit 1; }
while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_modules) MIN_MOD="$c2" ;; esac
done < "$REGISTRY"
matrix_miss="$(std_api_matrix_ok "$MATRIX" || true)"
[ "${matrix_miss:-0}" -eq 0 ] || exit 1
echo "std-api matrix cross-check OK"
COVERED=0
MISS=0
while IFS=$'\t' read -r module_id manifest mod_path kind sub_gate _notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in \#*|min_*|matrix_*|doc|gate) continue ;; esac
  if [ ! -f "$manifest" ]; then
    echo "std-api gate FAIL: missing manifest $manifest ($module_id)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  if [ ! -f "$mod_path" ]; then
    echo "std-api gate FAIL: missing mod $mod_path ($module_id)" >&2
    MISS=$((MISS + 1))
    continue
  fi
  if [ -n "${sub_gate:-}" ] && [ "$sub_gate" != "-" ]; then
    gate_path="tests/${sub_gate}"
    if [ ! -f "$gate_path" ]; then
      echo "std-api gate FAIL: missing gate $gate_path ($module_id)" >&2
      MISS=$((MISS + 1))
      continue
    fi
  fi
  COVERED=$((COVERED + 1))
done < "$REGISTRY"
if [ "$MISS" -gt 0 ]; then
  std_api_emit_report fail "$COVERED" "$MISS"
  exit 1
fi
if [ "$COVERED" -lt "$MIN_MOD" ]; then
  echo "std-api gate FAIL: covered=${COVERED} < min=${MIN_MOD}" >&2
  std_api_emit_report fail "$COVERED" 0
  exit 1
fi
std_api_emit_report ok "$COVERED" 0
echo "std-api gate OK (${COVERED} modules)"
