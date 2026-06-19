#!/usr/bin/env bash
# STBL-001：全模块 Tier-S manifest 注册表门禁
#
# 验收：≥25 个 std 子模块在注册表中有 baseline TSV，且符号锚点存在。
#
# 用法：./tests/run-stbl-001-tier-s-gate.sh
set -e
cd "$(dirname "$0")/.."

DOC="${SHUX_STBL_TIER_S_DOC:-analysis/stbl-tier-s-registry-v1.md}"
REGISTRY="${SHUX_STBL_TIER_S_TSV:-tests/baseline/stbl-tier-s-registry.tsv}"
LIB="tests/lib/stbl-tier-s-registry.sh"
MIN_MOD=25

# shellcheck source=tests/lib/stbl-tier-s-registry.sh
. "$LIB"

echo "=== STBL-001: Tier-S manifest registry ==="
for f in "$DOC" "$REGISTRY" "$LIB"; do
  if [ ! -f "$f" ]; then
    echo "stbl-tier-s gate FAIL: missing $f" >&2
    exit 1
  fi
done

for kw in Tier-S registry min_modules std.io std.heap; do
  if ! grep -qF "$kw" "$DOC" 2>/dev/null; then
    echo "stbl-tier-s gate FAIL: doc missing '$kw'" >&2
    exit 1
  fi
done

while IFS=$'\t' read -r c1 c2 _rest; do
  case "$c1" in min_modules) MIN_MOD="$c2" ;; esac
done < "$REGISTRY"

COVERED=0
SYM_MISS=0
echo "=== STBL-001: module manifest sweep (min=${MIN_MOD}) ==="
while IFS=$'\t' read -r module_id manifest mod_path kind _notes; do
  [ -z "${module_id:-}" ] && continue
  case "$module_id" in
    \#*|min_*|doc|gate) continue ;;
  esac
  if [ ! -f "$manifest" ]; then
    echo "stbl-tier-s gate FAIL: missing manifest $manifest ($module_id)" >&2
    stbl_tier_s_emit_report "fail" "$COVERED" 1
    exit 1
  fi
  if [ ! -f "$mod_path" ]; then
    echo "stbl-tier-s gate FAIL: missing mod $mod_path ($module_id)" >&2
    stbl_tier_s_emit_report "fail" "$COVERED" 1
    exit 1
  fi
  miss="$(stbl_tier_s_validate_module "$mod_path" "$manifest" "$kind" || true)"
  if [ "${miss:-0}" -gt 0 ]; then
    SYM_MISS=$((SYM_MISS + miss))
    echo "stbl-tier-s gate FAIL: ${module_id} sym_miss=${miss}" >&2
    stbl_tier_s_emit_report "fail" "$COVERED" "$SYM_MISS"
    exit 1
  fi
  COVERED=$((COVERED + 1))
  echo "  OK ${module_id} (${kind})"
done < "$REGISTRY"

if [ "$COVERED" -lt "$MIN_MOD" ]; then
  echo "stbl-tier-s gate FAIL: covered=${COVERED} < min=${MIN_MOD}" >&2
  stbl_tier_s_emit_report "fail" "$COVERED" 0
  exit 1
fi

stbl_tier_s_emit_report "ok" "$COVERED" 0
echo "stbl-tier-s gate OK (${COVERED} modules)"
