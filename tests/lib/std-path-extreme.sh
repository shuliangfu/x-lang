#!/usr/bin/env bash
# std-path-extreme.sh — STD-140 manifest 与烟测辅助

STD_PATH_EXTREME_PREFIX="${SHUX_STD140_PATH_EXTREME_PREFIX:-shux: [SHUX_STD140_PATH_EXTREME]}"

# 校验 manifest 中 api/file/smoke 锚点；echo 缺失数。
std_path_extreme_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-path-extreme FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|section)
        if [ "$kind" = "section" ]; then
          if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
            echo "std-path-extreme FAIL: missing section '$anchor' in $mod_path" >&2
            miss=$((miss + 1))
          fi
        elif [ ! -f "$anchor" ]; then
          echo "std-path-extreme FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 校验向量 TSV 最少行数。
std_path_extreme_vectors_ok() {
  local tsv="$1"
  local min_rows="${2:-8}"
  local n=0
  while IFS= read -r _line; do
    case "$_line" in \#*|"") continue ;; esac
    n=$((n + 1))
  done < "$tsv"
  if [ "$n" -lt "$min_rows" ]; then
    echo "std-path-extreme FAIL: vectors $n < min $min_rows" >&2
    return 1
  fi
  return 0
}

# 编译并运行 extreme_clean 烟测。
std_path_extreme_run_smoke() {
  local shux="$1"
  local src="$2"
  local exe="/tmp/shux_std_path_extreme_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-path-extreme FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-path-extreme FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_path_extreme_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_PATH_EXTREME_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
