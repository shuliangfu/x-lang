#!/usr/bin/env bash
# std-http-server-pool.sh — STD-107 manifest 与烟测辅助

STD_HTTP_SERVER_POOL_PREFIX="${SHUX_STD107_HTTP_SERVER_POOL_PREFIX:-shux: [SHUX_STD107_HTTP_SERVER_POOL]}"

# 校验 manifest 中 api/symbol/file。
std_http_server_pool_symbols_ok() {
  local mod_sx="$1"
  local http_c="$2"
  local pool_inc="$3"
  local tsv="$4"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-http-server-pool FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        local path="$mod_path"
        if [ "$path" = "compiler/src/asm/http/runtime_http_glue.c" ]; then path="$http_c"; fi
        if [ "$path" = "compiler/src/asm/http/http_server_pool.inc.c" ]; then path="$pool_inc"; fi
        if ! grep -qF "$anchor" "$path" 2>/dev/null; then
          echo "std-http-server-pool FAIL: missing '$anchor' in $path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-http-server-pool FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 烟测。
std_http_server_pool_run_sx_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-pool}"
  local exe="/tmp/shux_std_http_sp_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-http-server-pool FAIL: compile $src" >&2
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
    echo "std-http-server-pool FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# C 烟测：server_pool_smoke_ok.c + runtime_http_glue.o（符号均在胶层 TU）。
std_http_server_pool_run_c_smoke() {
  local _http_c="$1"
  local src="tests/http/server_pool_smoke_ok.c"
  local out="/tmp/shux_std_http_server_pool_$$"
  local glue_o="compiler/runtime_http_glue.o"
  if [ ! -f "$glue_o" ]; then
    echo "std-http-server-pool FAIL: missing $glue_o" >&2
    return 1
  fi
  if ! cc -std=c11 -O1 -o "$out" "$src" "$glue_o" 2>/dev/null; then
    echo "std-http-server-pool FAIL: compile C smoke" >&2
    return 1
  fi
  set +e
  "$out" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$out"
  if [ "$ec" -ne 0 ]; then
    echo "std-http-server-pool FAIL: C smoke exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_http_server_pool_emit_report() {
  local status="$1"
  local c_ok="$2"
  local su_ok="$3"
  local skip="$4"
  echo "${STD_HTTP_SERVER_POOL_PREFIX} status=${status} c=${c_ok} sx=${su_ok} skip=${skip}"
}
