#!/usr/bin/env bash
# BOOT-013：std/core 全模块 check 矩阵 runner
#
# 用法：./tests/run-stdlib-check-matrix.sh
set -e
cd "$(dirname "$0")/.."

MANIFEST="${SHU_STDLIB_CHECK_TSV:-tests/baseline/stdlib-check-matrix.tsv}"

# shellcheck source=tests/lib/stdlib-check-matrix.sh
. tests/lib/stdlib-check-matrix.sh

echo "=== BOOT-013: stdlib check matrix ==="

SHU_BIN=""
if ! SHU_BIN="$(stdlib_cm_resolve_shu 2>/dev/null)"; then
  stdlib_cm_emit_report "skip" 0 0 0 1
  echo "stdlib-check-matrix SKIP (no shu)" >&2
  exit 0
fi

make -C compiler -q shu-c 2>/dev/null || make -C compiler shu-c 2>/dev/null || make -C compiler -q 2>/dev/null || make -C compiler

CORE_OK=0
STD_OK=0
FAIL=0

while IFS=$'\t' read -r item_id kind anchor layer _notes; do
  [ -z "${item_id:-}" ] && continue
  case "$item_id" in \#*|min_*|read_path|matrix|report|lib|runner|gate) continue ;; esac
  case "$kind" in
    module)
      if stdlib_cm_check_module "$SHU_BIN" "$anchor"; then
        case "$layer" in
          core) CORE_OK=$((CORE_OK + 1)) ;;
          std) STD_OK=$((STD_OK + 1)) ;;
        esac
      else
        echo "stdlib-check-matrix FAIL: $anchor" >&2
        FAIL=$((FAIL + 1))
      fi
      ;;
  esac
done < "$MANIFEST"

if [ "$FAIL" -gt 0 ]; then
  stdlib_cm_emit_report "fail" "$CORE_OK" "$STD_OK" "$FAIL" 0
  echo "stdlib-check-matrix FAIL" >&2
  exit 1
fi

stdlib_cm_emit_report "ok" "$CORE_OK" "$STD_OK" 0 0
echo "stdlib-check-matrix OK"
