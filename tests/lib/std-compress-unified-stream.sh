#!/usr/bin/env bash
# std-compress-unified-stream.sh — STD-122 manifest 与烟测辅助
#
# 用法（source 后）：
#   std_compress_unified_symbols_ok MOD_X TSV
#   std_compress_unified_run_smoke SHUX_BIN X TAG
#   std_compress_unified_emit_report status stream_ok skip

STD_COMPRESS_UNIFIED_PREFIX="${SHUX_STD122_COMPRESS_UNIFIED_PREFIX:-shux: [SHUX_STD122_COMPRESS_UNIFIED]}"

# 校验 manifest api/smoke/file；echo 缺失数。
std_compress_unified_symbols_ok() {
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
          echo "std-compress-unified-stream FAIL: missing api '$anchor' in $mod_x" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke)
        if [ ! -f "$anchor" ]; then
          echo "std-compress-unified-stream FAIL: missing file '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行烟测 .x（须已 rebuild compress.o with zlib）。
std_compress_unified_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/shux_std_compress_unified_${tag}_$$"
  if [ ! -f "$src" ]; then
    echo "std-compress-unified-stream FAIL: missing $src" >&2
    return 1
  fi
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-compress-unified-stream FAIL: compile $src" >&2
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
    echo "std-compress-unified-stream FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# 输出结构化报告行。
std_compress_unified_emit_report() {
  local status="$1"
  local stream_ok="$2"
  local skip="$3"
  echo "${STD_COMPRESS_UNIFIED_PREFIX} status=${status} stream=${stream_ok} skip=${skip}"
}
