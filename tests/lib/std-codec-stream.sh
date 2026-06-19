#!/usr/bin/env bash
# std-codec-stream.sh — STD-110 manifest 与烟测辅助

STD_CODEC_STREAM_PREFIX="${SHUX_STD110_CODEC_STREAM_PREFIX:-shux: [SHUX_STD110_CODEC_STREAM]}"

# 校验 manifest 中 api/file/smoke。
std_codec_stream_symbols_ok() {
  local mod_su="$1"
  local tsv="$2"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        if ! grep -qE "function ${anchor}\\(" "$mod_su" 2>/dev/null; then
          echo "std-codec-stream FAIL: missing api '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
      file|smoke|vectors)
        if [ ! -f "$anchor" ]; then
          echo "std-codec-stream FAIL: missing '$anchor'" >&2
          miss=$((miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  echo "$miss"
  [ "$miss" -eq 0 ]
}

# 编译并运行 .sx 流式烟测。
std_codec_stream_run_smoke() {
  local shux="$1"
  local src="$2"
  local tag="${3:-stream}"
  local exe="/tmp/shux_std_codec_stream_${tag}_$$"
  if ! "$shux" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-codec-stream FAIL: compile $src" >&2
    "$shux" -L . "$src" 2>&1 | tail -12 >&2 || true
    rm -f "$exe"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe"
  if [ "$ec" -ne 0 ]; then
    echo "std-codec-stream FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

std_codec_stream_emit_report() {
  local status="$1"
  local su_ok="$2"
  local skip="$3"
  echo "${STD_CODEC_STREAM_PREFIX} status=${status} su=${su_ok} skip=${skip}"
}
