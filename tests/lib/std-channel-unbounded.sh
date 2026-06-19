#!/usr/bin/env bash
# std-channel-unbounded.sh — STD-044 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_channel_unbounded_symbols_ok MOD_SU CHANNEL_C TSV
#   std_channel_unbounded_run_smoke SHUX_BIN SU TAG
#   std_channel_unbounded_emit_report status unbounded_ok main_ok skip

STD_CHANNEL_UNBOUNDED_PREFIX="${SHUX_STD_CHANNEL_UNBOUNDED_PREFIX:-shux: [SHUX_STD_CHANNEL_UNBOUNDED]}"

# 校验 manifest symbol/api；echo 缺失数。
std_channel_unbounded_symbols_ok() {
  local mod_su="$1"
  local channel_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-channel-unbounded FAIL: missing api '$anchor' in $mod_su" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/channel/channel.c) mod_path="$channel_c" ;;
          *) mod_path="$mod_su" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-channel-unbounded FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-channel-unbounded FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .sx。
std_channel_unbounded_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_channel_ub_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-channel-unbounded FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-channel-unbounded FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -10 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-channel-unbounded FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_channel_unbounded_emit_report() {
  local status="$1"
  local unbounded_ok="$2"
  local main_ok="$3"
  local skip="$4"
  echo "${STD_CHANNEL_UNBOUNDED_PREFIX} status=${status} unbounded=${unbounded_ok} main=${main_ok} skip=${skip}"
}
