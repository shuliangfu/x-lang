#!/usr/bin/env bash
# core-str-find-split.sh — STD-131 find/split manifest helpers.
# Honesty: emit_report uses run=/obs=/skip= (soft SKIP→OK / soft auto-make retired).
# Designed success score = 0 (tests/str/find_split.x).

CORE_STR_FIND_SPLIT_PREFIX="${XLANG_STD131_CORE_STR_FIND_SPLIT_PREFIX:-xlang: [XLANG_STD131_CORE_STR_FIND_SPLIT]}"

# 校验 manifest 条目。
core_str_find_split_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_x" 2>/dev/null; then
          echo "core-str-find-split FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "core-str-find-split FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile+run find/split smoke. Prefer unique temp out; expect exit 0.
# Kept for standalone callers; gate uses RUN_XLANG build + hard-fail path.
core_str_find_split_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_core_str_find_split_$$"
  if ! "$xlang" -L . "$src" -o "$exe" 2>&1; then
    echo "core-str-find-split FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "core-str-find-split FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report: run= hard product; obs= check residual; skip= platform N/A.
core_str_find_split_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${CORE_STR_FIND_SPLIT_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
