#!/usr/bin/env bash
# std-codec-buffer-reuse.sh — STD-139 manifest helpers (codec↔bytes buffer reuse).
#
# Usage (after source):
#   std_codec_buffer_reuse_symbols_ok CODEC_X BYTES_X TSV
#   std_codec_buffer_reuse_run_smoke XLANG SRC
#   std_codec_buffer_reuse_emit_report status run obs skip
# PLATFORM: SHARED archaeology — must be sourced under bash.

STD_CODEC_BR_PREFIX="${XLANG_STD139_CODEC_BUFFER_REUSE_PREFIX:-xlang: [XLANG_STD139_CODEC_BUFFER_REUSE]}"

# Validate manifest api/file/smoke/script anchors across codec + bytes mods.
# Echo miss count; return 0 when miss=0.
std_codec_buffer_reuse_symbols_ok() {
  local codec_x="$1"
  local bytes_x="$2"
  local tsv="$3"
  local miss=0
  local item_id kind anchor mod_path
  while IFS=$'\t' read -r item_id kind anchor mod_path _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in \#*|min_*) continue ;; esac
    case "$kind" in
      api)
        local x="$codec_x"
        if [ "$mod_path" = "std/bytes/mod.x" ]; then
          x="$bytes_x"
        fi
        if ! grep -qE "function ${anchor}\\(" "$x" 2>/dev/null; then
          echo "std-codec-buffer-reuse FAIL: missing api '$anchor' in $x" >&2
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

# Compile and run buffer_reuse smoke (F-04 v7+: codec→gzip via .x + -lz).
# Tip product UNDEF for std_codec_* is gate-obs (not this helper's soft OK).
std_codec_buffer_reuse_run_smoke() {
  local xlang="$1"
  local src="$2"
  local exe="/tmp/xlang_std_codec_br_$$"
  if ! "$xlang" -L . "$src" -o "$exe" >/dev/null 2>&1; then
    echo "std-codec-buffer-reuse FAIL: compile $src" >&2
    "$xlang" -L . "$src" -o "$exe" 2>&1 | tail -12 >&2 || true
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

# Structured report line (honesty: run=/obs=/skip=; check / tip UNDEF = obs).
std_codec_buffer_reuse_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_CODEC_BR_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
