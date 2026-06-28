#!/usr/bin/env bash
# std-http-h2.sh — STD-HTTP-H2 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_http_h2_symbols_ok MOD_SX HTTP_C TSV
#   std_http_h2_run_smoke SHUX_BIN SX TAG
#   std_http_h2_emit_report status wire_ok client_ok network_ok flow_ok skip

STD_HTTP_H2_PREFIX="${SHUX_STD_HTTP_H2_PREFIX:-shux: [SHUX_STD_HTTP_H2]}"

# 校验 manifest symbol/file；echo 缺失数。
std_http_h2_symbols_ok() {
  local mod_sx="$1"
  local http_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      symbol)
        case "$mod_path" in
          std/http/mod.sx) mod_path="$mod_sx" ;;
          compiler/src/asm/http/runtime_http_glue.c) mod_path="$http_c" ;;
          compiler/src/asm/http/http2.inc.c) mod_path="compiler/src/asm/http/http2.inc.c" ;;
          compiler/src/asm/http/hpack.inc.c) mod_path="compiler/src/asm/http/hpack.inc.c" ;;
          compiler/src/asm/http/hpack_dyn.inc.c) mod_path="compiler/src/asm/http/hpack_dyn.inc.c" ;;
          compiler/src/asm/http/client.inc.c) mod_path="compiler/src/asm/http/client.inc.c" ;;
          compiler/src/asm/http/network.inc.c) mod_path="compiler/src/asm/http/network.inc.c" ;;
          compiler/src/asm/http/flow.inc.c) mod_path="compiler/src/asm/http/flow.inc.c" ;;
          compiler/src/asm/http/flow_state.inc.c) mod_path="compiler/src/asm/http/flow_state.inc.c" ;;
          compiler/src/asm/http/flow_recv.inc.c) mod_path="compiler/src/asm/http/flow_recv.inc.c" ;;
          compiler/src/asm/http/push_h2c.inc.c) mod_path="compiler/src/asm/http/push_h2c.inc.c" ;;
          compiler/src/asm/http/push_fetch.inc.c) mod_path="compiler/src/asm/http/push_fetch.inc.c" ;;
          compiler/src/asm/http/network.inc.c) mod_path="compiler/src/asm/http/network.inc.c" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-http-h2 FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-http-h2 FAIL: missing api $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-http-h2 FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .sx。
std_http_h2_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_http_h2_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-http-h2 FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-http-h2 FAIL: compile $src" >&2
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
    echo "std-http-h2 FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_http_h2_emit_report() {
  local status="$1"
  local wire_ok="$2"
  local client_ok="$3"
  local network_ok="$4"
  local flow_ok="$5"
  local skip="$6"
  echo "${STD_HTTP_H2_PREFIX} status=${status} wire=${wire_ok} client=${client_ok} network=${network_ok} flow=${flow_ok} skip=${skip}"
}
