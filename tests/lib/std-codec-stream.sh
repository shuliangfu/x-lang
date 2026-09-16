#!/usr/bin/env bash
# std-codec-stream.sh — STD-110 manifest helpers (compress/base64 stream adapters).
#
# Usage (after source):
#   std_codec_stream_symbols_ok MOD_X TSV
#   std_codec_stream_run_smoke XLANG SRC [TAG]
#   std_codec_stream_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.

STD_CODEC_STREAM_PREFIX="${XLANG_STD110_CODEC_STREAM_PREFIX:-xlang: [XLANG_STD110_CODEC_STREAM]}"

# Validate manifest api/file/smoke/vectors anchors.
# Echo miss count; return 0 when miss=0.
std_codec_stream_symbols_ok() {
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

# Compile and run .x stream smoke. Prefer XLANG_LINK_XLANG pinned to product asm.
# Tip product UNDEF for std_codec_* is gate-obs (not this helper's soft OK).
std_codec_stream_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-stream}"
  local exe="/tmp/xlang_std_codec_stream_${tag}_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-codec-stream FAIL: compile $src" >&2
    "$xlang" -L . "$src" 2>&1 | tail -12 >&2 || true
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

# Structured report line (honesty: run=/obs=/skip=; check / tip UNDEF = obs).
std_codec_stream_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CODEC_STREAM_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
