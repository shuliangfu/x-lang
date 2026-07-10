#!/usr/bin/env bash
# std-http-methods.sh — STD-032 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_http_methods_symbols_ok MOD_X HTTP_C TSV
#   std_http_methods_run_smoke SHUX_BIN X TAG
#   std_http_methods_emit_report status methods_ok skip

STD_HTTP_METHODS_PREFIX="${SHUX_STD_HTTP_METHODS_PREFIX:-shux: [SHUX_STD_HTTP_METHODS]}"

# 校验 manifest symbol/file/api；echo 缺失数，成功返回 0。
std_http_methods_symbols_ok() {
  local mod_x="$1"
  local http_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-http-methods FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          compiler/src/asm/http/runtime_http_glue.inc) mod_path="$http_c" ;;
          *) mod_path="$mod_x" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-http-methods FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-http-methods FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .x（须已 ensure http.o）。
std_http_methods_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_http_methods_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-http-methods FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-http-methods FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -8 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-http-methods FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_http_methods_emit_report() {
  local status="$1"
  local methods_ok="$2"
  local skip="$3"
  echo "${STD_HTTP_METHODS_PREFIX} status=${status} methods=${methods_ok} skip=${skip}"
}
