#!/usr/bin/env bash
# F-01：全仓库 std/core 手写 .c 存量盘点与回归门禁（完全自举阶段 F 清场基线）。
# 用法：./tests/run-std-c-inventory-gate.sh
# 环境：SHUX_STD_C_INVENTORY_FAIL=1 超过 baseline 时硬失败
#       SHUX_STD_C_INVENTORY_UPDATE=1 刷新 tests/baseline/std-c-inventory.tsv
set -e
cd "$(dirname "$0")/.."

BASELINE="${SHUX_STD_C_INVENTORY_TSV:-tests/baseline/std-c-inventory.tsv}"
FAIL=${SHUX_STD_C_INVENTORY_FAIL:-0}
UPDATE=${SHUX_STD_C_INVENTORY_UPDATE:-0}
TMP="/tmp/shux_std_c_inventory.$$.tsv"

# 收集 std/ 与 core/ 下全部 .c（含 .inc.c），相对仓库根路径。
collect_c_files() {
  find std core -type f -name '*.c' 2>/dev/null | LC_ALL=C sort
}

std_count=$(find std -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
core_count=$(find core -type f -name '*.c' 2>/dev/null | wc -l | tr -d ' ')
total=$((std_count + core_count))

echo "std-c-inventory-gate: std/**/*.c=${std_count} core/**/*.c=${core_count} total=${total}"

{
  echo "# F-01 std/core handwritten .c inventory (完全自举清场基线)"
  echo "# 列：path"
  echo "# 更新：SHUX_STD_C_INVENTORY_UPDATE=1 ./tests/run-std-c-inventory-gate.sh"
  printf 'summary_std_c\t%s\n' "$std_count"
  printf 'summary_core_c\t%s\n' "$core_count"
  printf 'summary_total_c\t%s\n' "$total"
  collect_c_files | while IFS= read -r p; do
    [ -n "$p" ] && printf 'file\t%s\n' "$p"
  done
} >"$TMP"

if [ "$UPDATE" = "1" ]; then
  mv "$TMP" "$BASELINE"
  echo "std-c-inventory-gate: updated $BASELINE (total=${total})"
  exit 0
fi

if [ ! -f "$BASELINE" ]; then
  mv "$TMP" "$BASELINE"
  echo "std-c-inventory-gate: created baseline $BASELINE (total=${total})"
  exit 0
fi

rm -f "$TMP" 2>/dev/null || true

base_std=$(awk -F'\t' '$1=="summary_std_c" { print $2; exit }' "$BASELINE")
base_core=$(awk -F'\t' '$1=="summary_core_c" { print $2; exit }' "$BASELINE")
base_total=$(awk -F'\t' '$1=="summary_total_c" { print $2; exit }' "$BASELINE")
base_std=${base_std:-104}
base_core=${base_core:-4}
base_total=${base_total:-108}

if [ "$total" -gt "$base_total" ] 2>/dev/null; then
  echo "std-c-inventory-gate FAIL: total ${total} > baseline ${base_total} (new .c added; stage F requires .x migration)" >&2
  collect_c_files | comm -13 <(awk -F'\t' '$1=="file" { print $2 }' "$BASELINE" | LC_ALL=C sort) - | head -20 >&2 || true
  [ "$FAIL" = "1" ] && exit 1
  exit 0
fi

if [ "$total" -lt "$base_total" ] 2>/dev/null; then
  echo "std-c-inventory-gate OK (total=${total} < baseline ${base_total}; .c removed — run SHUX_STD_C_INVENTORY_UPDATE=1 to refresh)"
  exit 0
fi

echo "std-c-inventory-gate OK (std=${std_count} core=${core_count} total=${total}; baseline ${base_total})"
exit 0
