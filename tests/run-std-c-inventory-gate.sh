#!/usr/bin/env bash
# F-01: std/core handwritten .c inventory (Phase F clearance baseline).
#
# Usage: ./tests/run-std-c-inventory-gate.sh
#        XLANG_STD_C_INVENTORY_UPDATE=1 ./tests/run-std-c-inventory-gate.sh
# 2026-08-26: Honesty — hard-fail when total > baseline (no soft
# die→exit0). Soft XLANG_STD_C_INVENTORY_FAIL retired as a gate switch;
# env still accepted as no-op for callers that export it. Baseline must
# track live disk (UPDATE when .c removed); stale high ceiling was
# portable-false-green (could add new .c under old 17 while actual=8).
# Report std=/core=/total=/baseline=/skip=.
# PLATFORM: SHARED archaeology.
set -e
cd "$(dirname "$0")/.."
# shellcheck source=tests/lib/ci-host.sh
. "$(dirname "$0")/lib/ci-host.sh"

BASELINE="${XLANG_STD_C_INVENTORY_TSV:-tests/baseline/std-c-inventory.tsv}"
UPDATE=${XLANG_STD_C_INVENTORY_UPDATE:-0}
TMP="/tmp/xlang_std_c_inventory.$$.tsv"
PREFIX="xlang: [XLANG_STD_C_INVENTORY]"

collect_c_files() {
  find std core -type f -name '*.c' 2>/dev/null | LC_ALL=C sort
}

die() {
  echo "std-c-inventory-gate FAIL: $*" >&2
  echo "${PREFIX} status=fail std=${std_count:-0} core=${core_count:-0} total=${total:-0} baseline=${base_total:--} skip=${SKIP:-0} host=$(ci_host_summary)"
  exit 1
}

SKIP=1
std_count=$(find std -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
core_count=$(find core -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
total=$((std_count + core_count))

echo "=== F-01: std/core handwritten .c inventory (honesty) ==="
echo "std-c-inventory-gate: std/**/*.c=${std_count} core/**/*.c=${core_count} total=${total}"

{
  echo "# F-01 std/core handwritten .c inventory (完全自举清场基线)"
  echo "# 列：path"
  echo "# 更新：XLANG_STD_C_INVENTORY_UPDATE=1 ./tests/run-std-c-inventory-gate.sh"
  printf 'summary_std_c\t%s\n' "$std_count"
  printf 'summary_core_c\t%s\n' "$core_count"
  printf 'summary_total_c\t%s\n' "$total"
  collect_c_files | while IFS= read -r p; do
    [ -n "$p" ] && printf 'file\t%s\n' "$p"
  done
} >"$TMP"

if [ "$UPDATE" = "1" ]; then
  mv "$TMP" "$BASELINE"
  SKIP=0
  echo "std-c-inventory-gate: updated $BASELINE (total=${total})"
  echo "${PREFIX} status=ok std=${std_count} core=${core_count} total=${total} baseline=${total} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

if [ ! -f "$BASELINE" ]; then
  mv "$TMP" "$BASELINE"
  SKIP=0
  echo "std-c-inventory-gate: created baseline $BASELINE (total=${total})"
  echo "${PREFIX} status=ok std=${std_count} core=${core_count} total=${total} baseline=${total} skip=${SKIP} host=$(ci_host_summary)"
  exit 0
fi

rm -f "$TMP" 2>/dev/null || true

base_std=$(awk -F'\t' '$1=="summary_std_c" { print $2; exit }' "$BASELINE")
base_core=$(awk -F'\t' '$1=="summary_core_c" { print $2; exit }' "$BASELINE")
base_total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$BASELINE")
base_std=${base_std:-0}
base_core=${base_core:-0}
base_total=${base_total:-0}

if [ "$total" -gt "$base_total" ] 2>/dev/null; then
  echo "std-c-inventory-gate FAIL: total ${total} > baseline ${base_total} (new .c added; stage F requires .x migration)" >&2
  collect_c_files | comm -13 <(awk -F'\t' '$1=="file" { print $2 }' "$BASELINE" | LC_ALL=C sort) - | head -20 >&2 || true
  die "total ${total} > baseline ${base_total}"
fi

if [ "$total" -lt "$base_total" ] 2>/dev/null; then
  # Ceiling still high after removals — not a fail, but honesty requires
  # UPDATE so new .c cannot hide under the stale high baseline.
  # PLATFORM: SHARED archaeology.
  die "total ${total} < baseline ${base_total} (stale high ceiling; run XLANG_STD_C_INVENTORY_UPDATE=1)"
fi

SKIP=0
echo "std-c-inventory-gate OK (std=${std_count} core=${core_count} total=${total}; baseline ${base_total})"
echo "${PREFIX} status=ok std=${std_count} core=${core_count} total=${total} baseline=${base_total} skip=${SKIP} host=$(ci_host_summary)"
exit 0
