#!/usr/bin/env bash
# std-http-chunked.sh — STD-033 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_http_chunked_symbols_ok MOD_X CHUNKED_INC HTTP_C TSV
#   std_http_chunked_run_smoke XLANG_BIN X TAG
#   std_http_chunked_emit_report status check_ok run_ok skip
# 2026-08-26: report check=/run=/skip= (honesty; prefer asm runnable hard).
# PLATFORM: SHARED archaeology — must be sourced under bash (zsh `.` breaks local).

STD_HTTP_CHUNKED_PREFIX="${XLANG_STD_HTTP_CHUNKED_PREFIX:-xlang: [XLANG_STD_HTTP_CHUNKED]}"

# 校验 manifest；echo 缺失数，成功返回 0。
std_http_chunked_symbols_ok() {
  local mod_x="$1"
  local chunked_inc="$2"
  local http_c="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-http-chunked FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local target="${mod_path:-$chunked_inc}"
        case "$target" in
          compiler/seeds/runtime_http_glue.from_x.c) target="$http_c" ;;
        esac
        if ! grep -qF "$anchor" "$target" 2>/dev/null; then
          echo "std-http-chunked FAIL: missing '$anchor' in $target" >&2
          miss=$((miss + 1))
        fi
        ;;
      cross_ref)
        if [ ! -f "$mod_path" ]; then
          echo "std-http-chunked FAIL: missing $mod_path" >&2
          miss=$((miss + 1))
        elif ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-http-chunked FAIL: $mod_path missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|bench)
        if [ ! -f "$anchor" ]; then
          echo "std-http-chunked FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      section|script|gate|anchor|hook_script)
        # DOC ## 4. Gate / script anchors validated by the gate script.
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# Compile and run chunked smoke .x; expect exit 0.
# Prefer RUN_XLANG (after gate pins XLANG_LINK_XLANG) so Darwin does not
# silently remap asm→c. Falls back to direct XLANG_BIN -L . -o.
# PLATFORM: SHARED archaeology — product honesty path.
std_http_chunked_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_http_chunked_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-http-chunked FAIL: missing $src" >&2
    return 1
  fi
  if [ -n "${RUN_XLANG:-}" ]; then
    if ! $RUN_XLANG build -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-http-chunked FAIL: compile $src" >&2
      $RUN_XLANG build -L . "$src" -o "$exe" 2>&1 | tail -10 >&2 || true
      rm -f "$exe"
      return 1
    fi
  else
    if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
      echo "std-http-chunked FAIL: compile $src" >&2
      "$xlang" -L . "$src" 2>&1 | tail -8 >&2 || true
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
    echo "std-http-chunked FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行（honesty: check=/run=/skip=）。
std_http_chunked_emit_report() {
  local status="$1"
  local check_ok="$2"
  local run_ok="$3"
  local skip="$4"
  echo "${STD_HTTP_CHUNKED_PREFIX} status=${status} check=${check_ok} run=${run_ok} skip=${skip}"
}
