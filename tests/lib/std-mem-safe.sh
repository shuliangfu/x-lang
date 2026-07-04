#!/usr/bin/env bash
# std-mem-safe.sh — STD-144 manifest 与烟测辅助

STD_MEM_SAFE_PREFIX="${SHUX_STD144_MEM_SAFE_PREFIX:-shux: [SHUX_STD144_MEM_SAFE]}"

# 校验 manifest；echo 缺失数。
std_mem_safe_symbols_ok() {
  local mod_x="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-mem-safe FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      smoke|gate|script)
        if [ ! -f "$anchor" ]; then
          echo "std-mem-safe FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section)
        if ! grep -qF "$anchor" "analysis/std-mem-safe-v1.md" 2>/dev/null; then
          echo "std-mem-safe FAIL: missing section '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# .x 烟测（x pipeline 暂不能稳定链 std.io.core，typeck 通过即 OK）。
std_mem_safe_run_smoke() {
  local shux="$1"
  local src="$2"
  if ! "$shux" check -L . "$src" >/dev/null 2>&1; then
    echo "std-mem-safe FAIL: typeck $src" >&2
    "$shux" check -L . "$src" 2>&1 | tail -10 >&2 || true
    return 1
  fi
  return 0
}

std_mem_safe_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_MEM_SAFE_PREFIX} status=${status} x=${su_ok} skip=${skip}"
}
