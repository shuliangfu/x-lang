#!/usr/bin/env bash
# std-codec-buffer-reuse.sh — STD-139 manifest 与烟测辅助

STD_CODEC_BR_PREFIX="${SHUX_STD139_CODEC_BUFFER_REUSE_PREFIX:-shux: [SHUX_STD139_CODEC_BUFFER_REUSE]}"

# 遍历 manifest 校验 api/file/smoke 锚点。
std_codec_buffer_reuse_symbols_ok() {
  local codec_su="$1"
  local bytes_su="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        local su="$codec_su"
        if [ "$mod_path" = "std/bytes/mod.sx" ]; then
          su="$bytes_su"
        fi
        if ! grep -qE "function ${anchor}\\(" "$su" 2>/dev/null; then
          echo "std-codec-buffer-reuse FAIL: missing api '$anchor' in $su" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|script)
        if [ ! -f "$anchor" ]; then
          echo "std-codec-buffer-reuse FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 buffer_reuse 烟测（须链 std/compress/compress.o 解析 codec→gzip 符号）。
std_codec_buffer_reuse_run_smoke() {
  local shux="$1"
  local src="$2"
  local compress_o="${3:-std/compress/compress.o}"
  local exe="/tmp/shux_std_codec_br_$$"
  if ! "$shux" -L . "$src" -o "$exe" "$compress_o" >/dev/null 2>&1; then
    echo "std-codec-buffer-reuse FAIL: compile $src" >&2
    "$shux" -L . "$src" -o "$exe" "$compress_o" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-codec-buffer-reuse FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_codec_buffer_reuse_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_CODEC_BR_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
