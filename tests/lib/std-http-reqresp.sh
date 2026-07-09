#!/usr/bin/env bash
# std-http-reqresp.sh — STD-HTTP-REQRESP manifest 与烟测辅助

STD_HTTP_REQRESP_PREFIX="${SHUX_STD_HTTP_REQRESP_PREFIX:-shux: [SHUX_STD_HTTP_REQRESP]}"

std_http_reqresp_symbols_ok() {
  local mod_x="$1"
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
          std/http/mod.x) mod_path="$mod_x" ;;
          compiler/src/asm/http/runtime_http_glue.c) mod_path="$http_c" ;;
          compiler/src/asm/http/http_reqresp.inc) mod_path="compiler/src/asm/http/http_reqresp.inc" ;;
          compiler/src/asm/http/hpack_huffman.inc.c) mod_path="compiler/src/asm/http/hpack_huffman.inc.c" ;;
          compiler/src/asm/http/flow.inc.c) mod_path="compiler/src/asm/http/flow.inc.c" ;;
          compiler/src/asm/http/hpack.inc.c) mod_path="compiler/src/asm/http/hpack.inc.c" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-http-reqresp FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_x" 2>/dev/null; then
          echo "std-http-reqresp FAIL: missing api $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      struct)
        if ! grep -qE "struct ${anchor}" "$mod_x" 2>/dev/null; then
          echo "std-http-reqresp FAIL: missing struct $anchor" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-http-reqresp FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

std_http_reqresp_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_http_reqresp_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-http-reqresp FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-http-reqresp FAIL: compile $src" >&2
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
    echo "std-http-reqresp FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_http_reqresp_emit_report() {
  local status="$1"
  local smoke_ok="$2"
  local skip="$3"
  echo "${STD_HTTP_REQRESP_PREFIX} status=${status} smoke=${smoke_ok} skip=${skip}"
}
