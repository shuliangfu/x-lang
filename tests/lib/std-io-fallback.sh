#!/usr/bin/env bash
# std-io-fallback.sh — STD-026: three-platform read/write fallback matrix helpers
#
# Usage (after source):
#   std_io_fallback_manifest_ok DOC README TSV
#   std_io_fallback_run_smoke XLANG_BIN smoke_x tag
#   std_io_fallback_emit_report status run obs skip
#
# Authority after io.c retirement: std/io/backend.x + sync.x + win32.x + mod.x.
# TSV code/matrix rows use src= live file; code_anchor grepped there (not deleted io.c).
# 2026-08-29: leftover `$RUN_XLANG build` / bootstrap-link wrap retired.
# PLATFORM: SHARED archaeology.

STD_IO_FALLBACK_PREFIX="${XLANG_STD_IO_FALLBACK_PREFIX:-xlang: [XLANG_STD_IO_FALLBACK]}"

# Validate manifest: matrix/doc/code/readme/symbol anchors; echo "matrix_miss code_miss".
# @param doc archive DOC
# @param readme std/io/README.md
# @param tsv baseline TSV (src column = live file for code/matrix)
std_io_fallback_manifest_ok() {
  local doc="$1"
  local readme="$2"
  local tsv="$3"
  local matrix_miss=0
  local code_miss=0
  local matrix_n=0
  local min_matrix=8
  local item_id kind doc_anchor code_anchor src _notes
  while IFS=$'\t' read -r item_id kind doc_anchor code_anchor src _notes; do
    [ -z "${item_id:-}" ] && continue
    case "$item_id" in
      \#*) continue ;;
      min_matrix_rows)
        if [ -n "${doc_anchor:-}" ]; then
          min_matrix="$doc_anchor"
        fi
        continue
        ;;
    esac
    case "$kind" in
      section)
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-io-fallback FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        ;;
      readme)
        if ! grep -qF "$doc_anchor" "$readme" 2>/dev/null; then
          echo "std-io-fallback FAIL: README missing '$doc_anchor' ($item_id)" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        ;;
      code)
        if [ ! -f "$src" ]; then
          echo "std-io-fallback FAIL: missing live file $src ($item_id)" >&2
          code_miss=$((code_miss + 1))
        elif ! grep -qF "$code_anchor" "$src" 2>/dev/null; then
          echo "std-io-fallback FAIL: $src missing '$code_anchor' ($item_id)" >&2
          code_miss=$((code_miss + 1))
        fi
        ;;
      matrix)
        matrix_n=$((matrix_n + 1))
        if ! grep -qF "$doc_anchor" "$doc" 2>/dev/null; then
          echo "std-io-fallback FAIL: doc missing '$doc_anchor' ($item_id)" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        if [ ! -f "$src" ]; then
          echo "std-io-fallback FAIL: missing live file $src ($item_id)" >&2
          code_miss=$((code_miss + 1))
        elif ! grep -qF "$code_anchor" "$src" 2>/dev/null; then
          echo "std-io-fallback FAIL: $src missing '$code_anchor' ($item_id)" >&2
          code_miss=$((code_miss + 1))
        fi
        ;;
      symbol)
        if ! grep -qE "function ${code_anchor}\\(" "$src" 2>/dev/null; then
          echo "std-io-fallback FAIL: missing function ${code_anchor} in $src" >&2
          matrix_miss=$((matrix_miss + 1))
        fi
        ;;
    esac
  done < "$tsv"
  if [ "$matrix_n" -lt "$min_matrix" ]; then
    echo "std-io-fallback FAIL: matrix_rows=${matrix_n} < min ${min_matrix}" >&2
    matrix_miss=$((matrix_miss + 1))
  fi
  echo "${matrix_miss} ${code_miss}"
  [ "$matrix_miss" -eq 0 ] && [ "$code_miss" -eq 0 ]
}

# Compile and run smoke .x; expect exit 0.
# Product path is `"$xlang" -L . src -o` (refuse leftover `$RUN_XLANG build`
# / bootstrap-link wrap remap). Gate pins XLANG_LINK_XLANG for hooks.
# PLATFORM: SHARED archaeology — product honesty path.
std_io_fallback_run_smoke() {
  local xlang="$1"
  local src="$2"
  local tag="${3:-smoke}"
  local exe="/tmp/xlang_std_io_fallback_${tag}_$$"
  local log="/tmp/xlang_std_io_fallback_build_${tag}_$$.log"
  if [ ! -f "$src" ]; then
    echo "std-io-fallback FAIL: missing $src" >&2
    return 1
  fi
  # Refuse leftover `$RUN_XLANG` remap / bootstrap-link wrap.
  # PLATFORM: SHARED
  if ! "$xlang" -L . "$src" -o "$exe" >"$log" 2>&1; then
    echo "std-io-fallback FAIL: compile $src" >&2
    tail -12 "$log" 2>/dev/null >&2 || true
    rm -f "$exe" "$log"
    return 1
  fi
  set +e
  "$exe" >/dev/null 2>&1
  local ec=$?
  set -e
  rm -f "$exe" "$log"
  if [ "$ec" -ne 0 ]; then
    echo "std-io-fallback FAIL: run $src exit=$ec" >&2
    return 1
  fi
  return 0
}

# Structured report line (honesty: run=/obs=/skip=).
# Manifest matrix/code/readme stay hard die before smoke; check = obs.
std_io_fallback_emit_report() {
  local status="$1"
  local run_ok="$2"
  local obs="$3"
  local skip="$4"
  echo "${STD_IO_FALLBACK_PREFIX} status=${status} run=${run_ok} obs=${obs} skip=${skip}"
}
