#!/usr/bin/env bash
# std-bytes-arena.sh — STD-155 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_bytes_arena_symbols_ok MOD_SU TSV
#   std_bytes_arena_run_smoke SHU_BIN SU
#   std_bytes_arena_emit_report status su_ok skip

STD155_PREFIX="${SHU_STD155_BYTES_ARENA_PREFIX:-shu: [SHU_STD155_BYTES_ARENA]}"

# 校验 manifest；echo 缺失数。
std_bytes_arena_symbols_ok() {
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
          echo "std-bytes-arena FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qF "$anchor" "$mod_su" 2>/dev/null; then
          echo "std-bytes-arena FAIL: missing '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script|gate)
        if [ ! -f "$anchor" ]; then
          echo "std-bytes-arena FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-bytes-arena-v1.md" 2>/dev/null; then
          echo "std-bytes-arena FAIL: missing section '$anchor' in RFC" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .su 烟测。
std_bytes_arena_run_smoke() {
  local shu="$1"
  local src="$2"
  local exe="/tmp/shu_std155_bytes_arena_$$"
  if [ ! -f "$src" ]; then
    echo "std-bytes-arena FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shu" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-bytes-arena FAIL: compile $src" >&2
    "$shu" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-bytes-arena FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_bytes_arena_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD155_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
