#!/usr/bin/env bash
# std-channel-select.sh — STD-098 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_channel_select_symbols_ok MOD_X CHANNEL_C TSV
#   std_channel_select_run_smoke XLANG_BIN X TAG
#   std_channel_select_emit_report status check_ok run_ok skip
# 2026-08-26: report check=/run=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_CHANNEL_SELECT_PREFIX="${XLANG_STD_CHANNEL_SELECT_PREFIX:-xlang: [XLANG_STD_CHANNEL_SELECT]}"

# 校验 manifest symbol/api；echo 缺失数。
std_channel_select_symbols_ok() {
  local mod_x="$1"
  local channel_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-channel-select FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/channel/channel_glue.c|compiler/seeds/runtime_channel_glue.from_x.c) mod_path="$channel_c" ;;
          *) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-channel-select FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-channel-select FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor)
        # DOC ## 4. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run a select smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_channel_select_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_channel_sel_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-channel-select FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-channel-select FAIL: compile $src" >&2
      $RUN_XLANG build -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-channel-select FAIL: compile $src" >&2
      "$xlang" -L . "$src" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-channel-select FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行（honesty: check=/run=/skip=）。
std_channel_select_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_CHANNEL_SELECT_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
