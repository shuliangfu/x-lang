#!/usr/bin/env bash
# core-str-find-split.sh — STD-131 manifest 与烟测辅助

CORE_STR_FIND_SPLIT_PREFIX="${SHUX_STD131_CORE_STR_FIND_SPLIT_PREFIX:-shux: [SHUX_STD131_CORE_STR_FIND_SPLIT]}"

# 校验 manifest 条目。
core_str_find_split_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor
  while IFS=$'\t' read -r item_id kind anchor _rest; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}" "$mod_su" 2>/dev/null; then
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

# 编译并运行 .sx 烟测。
core_str_find_split_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_core_str_find_split_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "core-str-find-split FAIL: compile $src" >&2
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  [ "$ec" -eq 0 ]
}

# 输出 gate 报告。
core_str_find_split_emit_report() {
  echo "${CORE_STR_FIND_SPLIT_PREFIX} status=$1 su=$2 skip=$3"
}
