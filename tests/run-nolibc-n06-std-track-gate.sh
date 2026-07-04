#!/usr/bin/env bash
# NL-06 v1：freestanding std 首批发 track 门禁（manifest + F-01 委托 + bootstrap track）。
#
# 用法：./tests/run-nolibc-n06-std-track-gate.sh
# 环境：
#   SHUX_NOLIBC_N06_FAIL=1              — 失败时硬退出
#   SHUX_NOLIBC_N06_MANIFEST_ONLY=1     — 仅 manifest（跳过 F-01 委托）
set -e
cd "$(dirname "$0")/.."

FAIL=${SHUX_NOLIBC_N06_FAIL:-0}
DOC="analysis/phase-f-n06-v1.md"
MANIFEST="tests/baseline/nolibc-n06-freestanding-replacements.tsv"
STD_C_GATE="tests/run-std-c-inventory-gate.sh"

die() {
  echo "nolibc-n06 gate FAIL: $*" >&2
  [ "$FAIL" = "1" ] && exit 1
  exit 0
}

echo "=== NL-06: freestanding std track (first batch v1) ==="
[ -f "$DOC" ] || die "missing $DOC"
grep -q 'NL-06 v1' "$DOC" || die "doc missing NL-06 v1 marker"
[ -f "$MANIFEST" ] || die "missing $MANIFEST"

# shellcheck source=tests/lib/nolibc-n06-std-track.sh
. tests/lib/nolibc-n06-std-track.sh

if ! nolibc_n06_audit_manifest "$MANIFEST"; then
  die "NL-06 freestanding replacements manifest audit failed"
fi

x_n=$(nolibc_n06_count_x_replacements "$MANIFEST")
leg_n=$(nolibc_n06_count_legacy_c "$MANIFEST")
f01_total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' tests/baseline/std-c-inventory.tsv 2>/dev/null)
f01_total=${f01_total:-97}
echo "nolibc-n06: x_replacements=${x_n} legacy_c=${leg_n} (F-01 total=${f01_total})"

if [ "${SHUX_NOLIBC_N06_MANIFEST_ONLY:-0}" = "1" ]; then
  echo "nolibc-n06 gate OK (manifest only; x=${x_n} legacy=${leg_n})"
  exit 0
fi

# F-01 委托：禁止新增 .c（track；低于 baseline 时 inventory gate 仍 OK）
if [ -f "$STD_C_GATE" ]; then
  echo "=== NL-06: delegate run-std-c-inventory-gate (F-01) ==="
  chmod +x "$STD_C_GATE"
  if ! SHUX_STD_C_INVENTORY_FAIL="$FAIL" "$STD_C_GATE"; then
    die "F-01 std-c-inventory sub-gate failed"
  fi
fi

echo "nolibc-n06 gate OK (freestanding std track v1; compiler bootstrap .c link track-only → NL-07 v2)"
