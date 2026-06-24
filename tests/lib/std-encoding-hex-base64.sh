#!/usr/bin/env bash
# std-encoding-hex-base64.sh — STD-040 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_encoding_hex_b64_symbols_ok MOD_SX ENCODING_C TSV
#   std_encoding_hex_b64_run_smoke SHUX_BIN SX TAG
#   std_encoding_hex_b64_emit_report status hex_ok b64_ok main_ok skip

STD_ENCODING_HEX_B64_PREFIX="${SHUX_STD_ENCODING_HEX_B64_PREFIX:-shux: [SHUX_STD_ENCODING_HEX_B64]}"

# 校验 manifest symbol/api；echo 缺失数。
std_encoding_hex_b64_symbols_ok() {
  local mod_sx="$1"
  local encoding_c="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_sx" 2>/dev/null; then
          echo "std-encoding-hex-b64 FAIL: missing api '$anchor' in $mod_sx" >&2
          miss=$((miss + 1))
        fi
        ;;
      symbol)
        case "$mod_path" in
          std/encoding/encoding.c|std/encoding/encoding.sx) mod_path="$encoding_c" ;;
          *) mod_path="$mod_sx" ;;
        esac
        if ! grep -qF "$anchor" "$mod_path" 2>/dev/null; then
          echo "std-encoding-hex-b64 FAIL: missing '$anchor' in $mod_path" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-encoding-hex-b64 FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .sx。
std_encoding_hex_b64_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_encoding_hb_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-encoding-hex-b64 FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-encoding-hex-b64 FAIL: compile $src" >&2
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
    echo "std-encoding-hex-b64 FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_encoding_hex_b64_emit_report() {
  local status="$1"
  local hex_ok="$2"
  local b64_ok="$3"
  local main_ok="$4"
  local skip="$5"
  echo "${STD_ENCODING_HEX_B64_PREFIX} status=${status} hex=${hex_ok} b64=${b64_ok} main=${main_ok} skip=${skip}"
}
