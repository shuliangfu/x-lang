#!/usr/bin/env bash
# core-debug-assert-extend.sh — CORE-012 assert type-extend manifest helpers.
# Honesty: emit_report uses run=/obs=/skip= (soft SKIP→OK / soft auto-make retired).
# Designed success score = 0 (tests/debug/assert_extend.x).
#
# Usage (after source):
#   core_debug_assert_extend_symbols_ok DEBUG_X TSV
#   core_debug_assert_extend_emit_report status run_ok obs skip
#   core_debug_assert_extend_run_smoke XLANG SRC  (standalone helper)

CORE_DEBUG_ASSERT_EXTEND_PREFIX="${XLANG_CORE_DEBUG_ASSERT_EXTEND_PREFIX:-xlang: [XLANG_CORE_DEBUG_ASSERT_EXTEND]}"

# 校验 manifest 中 symbol 锚点；echo 缺失数，成功返回 0。
core_debug_assert_extend_symbols_ok() {
  local debug_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        local target="${mod_path:-$debug_x}"
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "core-debug-assert-extend FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile+run assert_extend smoke. Prefer unique temp out; expect exit 0.
# Kept for standalone callers; gate uses RUN_XLANG build + hard-fail path.
core_debug_assert_extend_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_core_debug_assert_extend_$$"
  if ! "$xlang" -L . "$src" -o "$exe" 2>&1; then
    echo "core-debug-assert-extend FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "core-debug-assert-extend FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report: run= hard product; obs= check residual; skip= platform N/A.
core_debug_assert_extend_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_DEBUG_ASSERT_EXTEND_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
